import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
        'id': 'u_walkthrough',
        'type': 'auth',
        'exp': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return '$header.$payload.sig';
}

void main() {
  testWidgets('Full UI walkthrough: navigation, accordions, categories, and settings', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final serverConfig = ServerConfig(prefs);
    final db = AppDatabase(NativeDatabase.memory());
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
    pb.authStore.save(
      _testJwt(),
      RecordModel.fromJson({
        'id': 'u_walkthrough',
        'email': 'alex@example.com',
        'displayName': 'Alex Morgan',
        'role': 'user',
        'suspended': false,
      }),
    );

    final repository = TaskRepository(db);
    await repository.loadForUser('u_walkthrough', email: 'alex@example.com', displayName: 'Alex Morgan', seedSampleTasksIfEmpty: true);
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

    // 1. Verify Home Screen mounted with accordions
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Level 3 (Urgent)'), findsWidgets);
    expect(find.text('Level 2 (Medium)'), findsWidgets);
    expect(find.text('Level 1 (Low)'), findsWidgets);

    // 2. Test Category filtering
    expect(find.text('Personal'), findsWidgets);
    await tester.tap(find.text('Personal').first);
    await tester.pumpAndSettle();

    // Reset back to All
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();

    // 3. Test Add Task Dialog
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Title *'), findsOneWidget);
    expect(find.text('Importance Level *'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);

    await tester.tap(find.text('Recurring'));
    await tester.pumpAndSettle();
    expect(find.text('Recurrence Setup'), findsOneWidget);
    expect(find.text('Interval Based'), findsOneWidget);
    expect(find.text('Calendar Based'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 4. Test Navigation to Calendar Screen
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Calendar & Integrations'), findsWidgets);
    expect(find.textContaining('Connected Personal Calendar Accounts'), findsOneWidget);

    // 5. Test Navigation to Progress Screen
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Progress & Analytics'), findsWidgets);
    expect(find.textContaining('Completion Consistency Heatmap'), findsWidgets);

    // 6. Test Navigation to Ideas Screen
    await tester.tap(find.byIcon(Icons.lightbulb_outline));
    await tester.pumpAndSettle();
    expect(find.text('Inbox Ideas'), findsWidgets);

    // 7. Test Navigation to Profile & Settings Screen
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsWidgets);
    expect(find.text('Cloud Sync & Connected Accounts'), findsOneWidget);
    expect(find.text('PocketBase Cloud Sync'), findsOneWidget);
    expect(find.text('Priority & Escalation Windows'), findsWidgets);
    expect(find.text('Edit Auto-Scheduled Tasks'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Vacation Mode'), findsWidgets);
  });
}

