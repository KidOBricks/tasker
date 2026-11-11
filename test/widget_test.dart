import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_sync/data/repositories/task_repository.dart';
import 'package:task_calendar_sync/data/services/auth_service.dart';
import 'package:task_calendar_sync/data/services/database_service.dart';
import 'package:task_calendar_sync/data/services/calendar_integration_service.dart';
import 'package:task_calendar_sync/data/services/email_integration_service.dart';
import 'package:task_calendar_sync/main.dart';
import 'package:task_calendar_sync/state/app_state.dart';
import 'package:task_calendar_sync/state/auth_state.dart';
import 'package:task_calendar_sync/state/integration_state.dart';
import 'package:task_calendar_sync/ui/screens/admin/admin_console_screen.dart';

void main() {
  testWidgets('Regular client app mounts and displays 5 user navigation destinations without admin clutter', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = await TaskRepository.initWithPrefs(prefs);
    final authService = AuthService(prefs);
    final databaseService = DatabaseService(prefs);
    final calendarService = CalendarIntegrationService(prefs);
    final emailService = EmailIntegrationService(prefs);

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

    // Verify presence of the 5 user destinations in the regular app
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Ideas'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // Verify Admin tab is not shown in regular Windows/Android user navigation
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('Admin Console web screen mounts and displays enterprise management dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService(prefs);
    final databaseService = DatabaseService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
        child: const MaterialApp(home: AdminConsoleScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Admin Console'), findsOneWidget);
    expect(find.text('Registered Users Directory'), findsOneWidget);
    expect(find.text('Total Users'), findsWidgets);
  });
}
