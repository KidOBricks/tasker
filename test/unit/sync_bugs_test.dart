import 'dart:async';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_sync/data/local/app_database.dart';
import 'package:task_calendar_sync/data/repositories/task_repository.dart';
import 'package:task_calendar_sync/data/services/auth_service.dart';
import 'package:task_calendar_sync/data/services/database_service.dart';
import 'package:task_calendar_sync/data/services/server_config.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/state/app_state.dart';
import 'package:task_calendar_sync/state/auth_state.dart';

String _fakeJwt(String userId) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
  final payload = base64Url
      .encode(utf8.encode(json.encode({
        'id': userId,
        'type': 'auth',
        'exp': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return '$header.$payload.sig';
}

Map<String, dynamic> _pbList(List<Map<String, dynamic>> items) => {
      'page': 1,
      'perPage': 1000,
      'totalItems': items.length,
      'items': items,
    };

void main() {
  test('subsequent cloud sync updates TasksNotifier when remote marks task completed', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = TaskRepository(db);
    await repo.loadForUser('u1', email: 'u1@example.com');

    var remoteStatus = 'pending';
    var remoteCompletedAt = '';
    var remoteUpdated = '2026-11-18T21:10:00.000Z';

    final client = MockClient((req) async {
      if (req.url.path == '/api/collections/tasks/records' && req.method == 'GET') {
        return http.Response(
          json.encode(_pbList([
            {
              'id': 'pb_t1',
              'user': 'u1',
              'clientId': 't1',
              'title': 'Phone task',
              'categoryId': 'all',
              'baseImportance': 2,
              'effectiveImportance': 2,
              'status': remoteStatus,
              'isOverdue': false,
              'clientCreatedAt': '2026-11-18T21:09:00.000Z',
              'completedAt': remoteCompletedAt,
              'clientUpdatedAt': remoteUpdated,
              'attachmentPaths': [],
              'subtasks': [],
            },
          ])),
          200,
        );
      }
      return http.Response(json.encode(_pbList([])), 200);
    });

    final pb = PocketBase('https://example.invalid', httpClientFactory: () => client);
    pb.authStore.save(
      _fakeJwt('u1'),
      RecordModel({'id': 'u1', 'email': 'u1@example.com', 'displayName': 'User'}),
    );
    final authService = AuthService(pb, ServerConfig(prefs));
    final dbService = DatabaseService(pb, db, repo);
    addTearDown(dbService.dispose);

    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        authServiceProvider.overrideWithValue(authService),
        databaseServiceProvider.overrideWithValue(dbService),
      ],
    );
    addTearDown(container.dispose);

    // Keep tasksProvider actively watched like the UI does.
    final sub = container.listen(tasksProvider, (_, _) {});
    addTearDown(sub.close);

    await dbService.performCloudSync(userId: 'u1');
    await pumpEventQueue();
    expect(container.read(tasksProvider).single.isCompleted, isFalse);

    // Remote device completes the task -> second cloud sync runs.
    remoteStatus = 'completed';
    remoteCompletedAt = '2026-11-18T21:12:00.000Z';
    remoteUpdated = '2026-11-18T21:12:00.000Z';

    await dbService.performCloudSync(userId: 'u1');
    await pumpEventQueue();

    expect(container.read(tasksProvider).single.isCompleted, isTrue);
    expect(container.read(sectionedTasksProvider).levelTasks.values.expand((e) => e), isEmpty);
  });

  test('saveTasks only enqueues added or changed tasks into syncOutbox', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = TaskRepository(db);
    await repo.loadForUser('u1');

    final t1 = TaskItem(
      id: 't1',
      userId: 'u1',
      title: 'First',
      baseImportance: 1,
      effectiveImportance: 1,
      createdAt: DateTime.utc(2026, 11, 18, 21, 0),
    );
    final t2 = TaskItem(
      id: 't2',
      userId: 'u1',
      title: 'Second',
      baseImportance: 2,
      effectiveImportance: 2,
      createdAt: DateTime.utc(2026, 11, 18, 21, 1),
    );

    await repo.saveTasks([t1, t2]);
    await db.delete(db.syncOutbox).go();

    // Mutate only t2 (mark in_progress), leaving t1 unchanged (even if effectiveImportance differs).
    await repo.saveTasks([
      t1.copyWith(effectiveImportance: 3),
      t2.copyWith(status: TaskStatus.inProgress, inProgressAt: DateTime.utc(2026, 11, 18, 21, 5)),
    ]);

    final queued = await db.select(db.syncOutbox).get();
    expect(queued.map((o) => o.recordKey).toList(), ['t2']);
  });

  test('concurrent mutation during active sync queues follow-up sync instead of dropping push', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = TaskRepository(db);
    await repo.loadForUser('u1');

    final initialTask = TaskItem(
      id: 't1',
      userId: 'u1',
      title: 'Concurrent task',
      baseImportance: 2,
      effectiveImportance: 2,
      createdAt: DateTime.utc(2026, 11, 18, 21, 0),
    );
    await repo.saveTasks([initialTask]);
    await db.delete(db.syncOutbox).go();

    final firstPullStarted = Completer<void>();
    final allowFirstPullFinish = Completer<void>();
    var tasksGetCount = 0;
    final patchedStatuses = <String>[];

    final client = MockClient((req) async {
      if (req.url.path == '/api/collections/tasks/records' && req.method == 'GET') {
        if (req.url.queryParameters['perPage'] == '1') {
          return http.Response(
            json.encode(_pbList([
              {'id': 'pb_t1', 'clientId': 't1'},
            ])),
            200,
          );
        }
        tasksGetCount++;
        if (tasksGetCount == 1) {
          firstPullStarted.complete();
          await allowFirstPullFinish.future;
        }
        return http.Response(
          json.encode(_pbList([
            {
              'id': 'pb_t1',
              'user': 'u1',
              'clientId': 't1',
              'title': 'Concurrent task',
              'categoryId': 'all',
              'baseImportance': 2,
              'effectiveImportance': 2,
              'status': patchedStatuses.isNotEmpty ? patchedStatuses.last : 'pending',
              'isOverdue': false,
              'clientCreatedAt': '2026-11-18T21:00:00.000Z',
              'clientUpdatedAt': '2026-11-18T21:01:00.000Z',
              'attachmentPaths': [],
              'subtasks': [],
            },
          ])),
          200,
        );
      }
      if (req.url.path == '/api/collections/tasks/records/pb_t1' && req.method == 'PATCH') {
        final body = json.decode(req.body) as Map<String, dynamic>;
        patchedStatuses.add(body['status']?.toString() ?? '');
        return http.Response(json.encode({'id': 'pb_t1', ...body}), 200);
      }
      return http.Response(json.encode(_pbList([])), 200);
    });

    final pb = PocketBase('https://example.invalid', httpClientFactory: () => client);
    pb.authStore.save(_fakeJwt('u1'), RecordModel({'id': 'u1'}));
    final dbService = DatabaseService(pb, db, repo);
    addTearDown(dbService.dispose);

    final firstSync = dbService.performCloudSync(userId: 'u1');
    await firstPullStarted.future;

    // While first sync is mid-pull, user completes the task and triggers background sync.
    await repo.saveTasks([
      initialTask.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.utc(2026, 11, 18, 21, 1, 0, 500),
      ),
    ]);
    final secondSync = dbService.performCloudSync(userId: 'u1');

    allowFirstPullFinish.complete();
    await Future.wait([firstSync, secondSync]);
    await pumpEventQueue();

    expect(patchedStatuses, contains('completed'));
    expect(repo.getTasks().single.isCompleted, isTrue);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });

  test('markCompleted finishes parent task even when subtasks were unchecked', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = TaskRepository(db);
    await repo.loadForUser('u1');
    final pb = PocketBase(
      'https://example.invalid',
      httpClientFactory: () => MockClient((_) async => http.Response(json.encode(_pbList([])), 200)),
    );
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        authServiceProvider.overrideWithValue(AuthService(pb, ServerConfig(prefs))),
        databaseServiceProvider.overrideWithValue(DatabaseService(pb, db, repo)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.notifier).addTask(
      title: 'Parent with subtasks',
      categoryId: 'all',
      baseImportance: 2,
      subtasks: const [
        SubtaskItem(id: 's1', title: 'Step 1', baseImportance: 2, isCompleted: false),
      ],
    );
    final taskId = container.read(tasksProvider).single.id;

    await container.read(tasksProvider.notifier).markCompleted(taskId);
    final after = container.read(tasksProvider).single;
    expect(after.isCompleted, isTrue);
    expect(after.subtasks.single.isCompleted, isTrue);
  });

  test('fresh signIn preserves remote profile and categories without overwriting defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = TaskRepository(db);
    final mutatingRequests = <String>[];

    final client = MockClient((req) async {
      if (req.url.path == '/api/realtime') {
        return http.Response('not found in test', 404);
      }
      if (req.url.path == '/api/collections/users/auth-with-password' && req.method == 'POST') {
        return http.Response(
          json.encode({
            'token': _fakeJwt('u1'),
            'record': {
              'id': 'u1',
              'email': 'u1@example.com',
              'displayName': 'Cloud Name',
              'role': 'user',
            },
          }),
          200,
        );
      }
      if (req.method == 'POST' || req.method == 'PATCH') {
        mutatingRequests.add('${req.method} ${req.url.path}');
        return http.Response(json.encode({'id': 'pb_mut'}), 200);
      }
      if (req.url.path == '/api/collections/categories/records' && req.method == 'GET') {
        return http.Response(
          json.encode(_pbList([
            {
              'id': 'pb_c1',
              'user': 'u1',
              'clientId': 'custom',
              'name': 'Custom Cloud',
              'colorValue': 0xFF3CA89C,
              'iconName': 'work',
              'sortOrder': 0,
              'clientUpdatedAt': '2026-11-18T20:00:00.000Z',
            },
          ])),
          200,
        );
      }
      if (req.url.path == '/api/collections/user_profiles/records' && req.method == 'GET') {
        return http.Response(
          json.encode(_pbList([
            {
              'id': 'pb_p1',
              'user': 'u1',
              'displayName': 'Cloud Name',
              'notifyPriorMinutes': 45,
              'clientUpdatedAt': '2026-11-18T20:00:00.000Z',
            },
          ])),
          200,
        );
      }
      return http.Response(json.encode(_pbList([])), 200);
    });

    final pb = PocketBase('https://example.invalid', httpClientFactory: () => client);
    final authService = AuthService(pb, ServerConfig(prefs));
    final dbService = DatabaseService(pb, db, repo);
    addTearDown(dbService.dispose);

    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        authServiceProvider.overrideWithValue(authService),
        databaseServiceProvider.overrideWithValue(dbService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).signIn('u1@example.com', 'secret');
    expect(mutatingRequests, isEmpty);
    expect(repo.getProfile().notifyPriorMinutes, 45);
    expect(repo.getCategories().single.name, 'Custom Cloud');
  });
}
