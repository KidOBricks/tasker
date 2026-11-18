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
import 'package:task_calendar_sync/data/services/calendar_integration_service.dart';
import 'package:task_calendar_sync/data/services/database_service.dart';
import 'package:task_calendar_sync/data/services/email_integration_service.dart';
import 'package:task_calendar_sync/data/services/server_config.dart';
import 'package:task_calendar_sync/main.dart';
import 'package:task_calendar_sync/state/app_state.dart';
import 'package:task_calendar_sync/state/auth_state.dart';
import 'package:task_calendar_sync/state/integration_state.dart';

String _testJwt() {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
  final payload = base64Url
      .encode(utf8.encode(json.encode({
        'id': 'u_test',
        'type': 'auth',
        'exp': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return '$header.$payload.sig';
}

PocketBase _mockPocketBase({bool authenticated = true}) {
  final client = MockClient((req) async {
    if (req.url.path == '/api/integrations/status') {
      return http.Response(
        json.encode({
          'google': null,
          'microsoft': null,
          'configured': {'google': true, 'microsoft': true},
        }),
        200,
      );
    }
    return http.Response(json.encode({'page': 1, 'perPage': 500, 'totalItems': 0, 'items': []}), 200);
  });

  final pb = PocketBase('https://1-2-3-4.sslip.io', httpClientFactory: () => client);
  if (authenticated) {
    pb.authStore.save(
      _testJwt(),
      RecordModel.fromJson({
        'id': 'u_test',
        'email': 'alex@example.com',
        'displayName': 'Alex Morgan',
        'role': 'user',
        'suspended': false,
      }),
    );
  }
  return pb;
}

void main() {
  testWidgets('Unauthenticated app renders invite-only AuthScreen with SSO options', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final serverConfig = ServerConfig(prefs);
    final db = AppDatabase(NativeDatabase.memory());
    final pb = _mockPocketBase(authenticated: false);
    final repository = TaskRepository(db);
    final authService = AuthService(pb, serverConfig);
    final databaseService = DatabaseService(pb, db, repository);
    final calendarService = CalendarIntegrationService(pb, db);
    final emailService = EmailIntegrationService(pb, db);

    addTearDown(() async {
      databaseService.dispose();
      await tester.runAsync(() => db.close());
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          authServiceProvider.overrideWithValue(authService),
          databaseServiceProvider.overrideWithValue(databaseService),
          calendarIntegrationServiceProvider.overrideWithValue(calendarService),
          emailIntegrationServiceProvider.overrideWithValue(emailService),
        ],
        child: const TaskCalendarSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Microsoft'), findsOneWidget);
    expect(find.textContaining('Invite-only workspace'), findsOneWidget);
  });

  testWidgets('Authenticated client app displays 5 user navigation destinations without admin tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final serverConfig = ServerConfig(prefs);
    final db = AppDatabase(NativeDatabase.memory());
    final pb = _mockPocketBase(authenticated: true);
    final repository = TaskRepository(db);
    await repository.loadForUser('u_test', email: 'alex@example.com', displayName: 'Alex Morgan', seedSampleTasksIfEmpty: true);
    final authService = AuthService(pb, serverConfig);
    final databaseService = DatabaseService(pb, db, repository);
    final calendarService = CalendarIntegrationService(pb, db);
    final emailService = EmailIntegrationService(pb, db);

    addTearDown(() async {
      databaseService.dispose();
      await tester.runAsync(() => db.close());
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          authServiceProvider.overrideWithValue(authService),
          databaseServiceProvider.overrideWithValue(databaseService),
          calendarIntegrationServiceProvider.overrideWithValue(calendarService),
          emailIntegrationServiceProvider.overrideWithValue(emailService),
        ],
        child: const TaskCalendarSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Ideas'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Admin'), findsNothing);
  });
}

