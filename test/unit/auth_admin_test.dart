import 'dart:convert';
import 'package:drift/native.dart';
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
import 'package:task_calendar_sync/domain/models/user_account.dart';

String _makeTestJwt({String id = 'user_1'}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
  final payload = base64Url
      .encode(utf8.encode(json.encode({
        'id': id,
        'type': 'auth',
        'exp': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return '$header.$payload.sig';
}

void main() {
  group('ServerConfig, Drift Isolation, AuthService & Sync Unit Tests', () {
    late SharedPreferences prefs;
    late AppDatabase db;
    late TaskRepository repo;
    late ServerConfig serverConfig;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      serverConfig = ServerConfig(prefs);
      db = AppDatabase(NativeDatabase.memory());
      repo = TaskRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('ServerConfig normalizes and persists server URLs', () async {
      expect(serverConfig.serverUrl, 'http://127.0.0.1:8090');
      await serverConfig.setServerUrl('https://129-146-10-20.sslip.io///');
      expect(serverConfig.serverUrl, 'https://129-146-10-20.sslip.io');
      expect(serverConfig.hasCustomServerUrl, isTrue);
    });

    test('TaskRepository enforces Drift per-user tenant isolation and queues SyncOutbox', () async {
      await repo.loadForUser('u_alice', email: 'alice@example.com', displayName: 'Alice');
      await repo.saveTasks([
        TaskItem(
          id: 'task_a1',
          userId: 'u_alice',
          title: 'Alice private task',
          categoryId: 'work',
          baseImportance: 2,
          effectiveImportance: 2,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      expect(repo.getTasks().map((t) => t.title), ['Alice private task']);

      final aliceOutbox = await (db.select(db.syncOutbox)..where((o) => o.userId.equals('u_alice'))).get();
      expect(aliceOutbox.any((o) => o.collectionName == 'tasks' && o.recordKey == 'task_a1'), isTrue);

      // Switch tenant -> Alice's data must not appear under Bob
      await repo.loadForUser('u_bob', email: 'bob@example.com', displayName: 'Bob');
      expect(repo.getTasks(), isEmpty);

      // Switch back -> Alice's Drift data reloads intact
      await repo.loadForUser('u_alice', email: 'alice@example.com', displayName: 'Alice');
      expect(repo.getTasks().map((t) => t.title), ['Alice private task']);
    });

    test('AuthService authenticates active users and blocks suspended accounts', () async {
      var suspendedFlag = false;
      final token = _makeTestJwt(id: 'u_123');
      final mockClient = MockClient((req) async {
        if (req.url.path == '/api/collections/users/auth-with-password') {
          return http.Response(
            json.encode({
              'token': token,
              'record': {
                'id': 'u_123',
                'collectionId': 'users',
                'collectionName': 'users',
                'email': 'sarah@example.com',
                'displayName': 'Sarah Chen',
                'role': 'user',
                'suspended': suspendedFlag,
                'created': '2026-01-01 00:00:00.000Z',
                'updated': '2026-01-01 00:00:00.000Z',
              },
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });

      final pb = PocketBase('https://1-2-3-4.sslip.io', httpClientFactory: () => mockClient);
      final authService = AuthService(pb, serverConfig);

      final user = await authService.signIn('sarah@example.com', 'password123');
      expect(user.id, 'u_123');
      expect(user.displayName, 'Sarah Chen');
      expect(user.role, UserRole.user);
      expect(authService.isAuthenticated, isTrue);

      await authService.signOut();
      expect(authService.isAuthenticated, isFalse);

      // Suspended user should be rejected and session cleared
      suspendedFlag = true;
      await expectLater(
        () => authService.signIn('sarah@example.com', 'password123'),
        throwsA(isA<Exception>()),
      );
      expect(authService.isAuthenticated, isFalse);
    });

    test('DatabaseService pushes outbox writes and pulls remote tasks cleanly', () async {
      final token = _makeTestJwt(id: 'u_alice');
      final pushedBodies = <Map<String, dynamic>>[];

      final mockClient = MockClient((req) async {
        if (req.url.path == '/api/collections/tasks/records' && req.method == 'POST') {
          pushedBodies.add(json.decode(req.body) as Map<String, dynamic>);
          return http.Response(
            json.encode({
              'id': 'pb_task_1',
              'collectionId': 'tasks',
              'collectionName': 'tasks',
              ...pushedBodies.last,
            }),
            200,
          );
        }
        if (req.url.path == '/api/collections/tasks/records' && req.method == 'GET') {
          final hasFilter = req.url.queryParameters['filter']?.contains('clientId') ?? false;
          if (hasFilter) {
            return http.Response(json.encode({'page': 1, 'perPage': 1, 'totalItems': 0, 'items': []}), 200);
          }
          return http.Response(
            json.encode({
              'page': 1,
              'perPage': 500,
              'totalItems': 1,
              'items': [
                {
                  'id': 'pb_remote_2',
                  'collectionId': 'tasks',
                  'collectionName': 'tasks',
                  'user': 'u_alice',
                  'clientId': 'remote_task_2',
                  'title': 'Synced from OCI',
                  'description': 'From server',
                  'categoryId': 'work',
                  'baseImportance': 3,
                  'effectiveImportance': 3,
                  'status': 'pending',
                  'isOverdue': false,
                  'clientCreatedAt': '2026-01-01T10:00:00Z',
                  'clientUpdatedAt': '2026-01-02T10:00:00Z',
                }
              ],
            }),
            200,
          );
        }
        if (req.method == 'GET' && req.url.path.startsWith('/api/collections/')) {
          return http.Response(json.encode({'page': 1, 'perPage': 500, 'totalItems': 0, 'items': []}), 200);
        }
        if (req.method == 'POST' && req.url.path.startsWith('/api/collections/')) {
          return http.Response(json.encode({'id': 'pb_other_1'}), 200);
        }
        return http.Response('{}', 404);
      });

      final pb = PocketBase('https://1-2-3-4.sslip.io', httpClientFactory: () => mockClient);
      pb.authStore.save(
        token,
        RecordModel.fromJson({
          'id': 'u_alice',
          'email': 'alice@example.com',
          'displayName': 'Alice',
          'role': 'user',
          'suspended': false,
        }),
      );

      await repo.loadForUser('u_alice', email: 'alice@example.com', displayName: 'Alice');
      await repo.saveTasks([
        TaskItem(
          id: 'local_task_1',
          userId: 'u_alice',
          title: 'Local queued task',
          categoryId: 'work',
          baseImportance: 1,
          effectiveImportance: 1,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);

      final dbService = DatabaseService(pb, db, repo);
      await dbService.performCloudSync(userId: 'u_alice');

      expect(dbService.status, SyncStatus.synced);
      expect(dbService.lastSyncTime, isNotNull);
      expect(pushedBodies.any((b) => b['clientId'] == 'local_task_1'), isTrue);
      expect(repo.getTasks().any((t) => t.id == 'remote_task_2' && t.title == 'Synced from OCI'), isTrue);

      final remainingOutbox = await (db.select(db.syncOutbox)..where((o) => o.userId.equals('u_alice'))).get();
      expect(remainingOutbox, isEmpty);
      dbService.dispose();
    });
  });
}

