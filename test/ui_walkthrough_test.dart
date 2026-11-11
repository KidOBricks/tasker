import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_sync/data/repositories/task_repository.dart';
import 'package:task_calendar_sync/data/services/auth_service.dart';
import 'package:task_calendar_sync/data/services/database_service.dart';
import 'package:task_calendar_sync/main.dart';
import 'package:task_calendar_sync/state/app_state.dart';
import 'package:task_calendar_sync/state/auth_state.dart';

void main() {
  testWidgets('Full UI walkthrough: navigation, accordions, categories, and settings', (WidgetTester tester) async {
    // Set workstation viewport size so all desktop accordions are in view
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = await TaskRepository.initWithPrefs(prefs);
    final authService = AuthService(prefs);
    final databaseService = DatabaseService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          authServiceProvider.overrideWithValue(authService),
          databaseServiceProvider.overrideWithValue(databaseService),
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

    // Verify Add Task dialog fields
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Title *'), findsOneWidget);
    expect(find.text('Importance Level *'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);

    // Switch to Recurring mode
    await tester.tap(find.text('Recurring'));
    await tester.pumpAndSettle();
    expect(find.text('Recurrence Setup'), findsOneWidget);
    expect(find.text('Interval Based'), findsOneWidget);
    expect(find.text('Calendar Based'), findsOneWidget);

    // Close Dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 4. Test Navigation to Calendar Screen
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Calendar & Integrations'), findsWidgets);

    // 5. Test Navigation to Progress Screen
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Progress & Analytics'), findsWidgets);
    expect(find.textContaining('Completion Consistency Heatmap'), findsWidgets);

    // 6. Test Navigation to Ideas Screen
    await tester.tap(find.byIcon(Icons.lightbulb_outline));
    await tester.pumpAndSettle();
    expect(find.text('Ideas & Email Inbox AI'), findsWidgets);

    // 7. Test Navigation to Profile & Settings Screen
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsWidgets);
    expect(find.text('Priority & Escalation Windows'), findsWidgets);
    expect(find.text('Vacation Mode'), findsWidgets);
    expect(find.text('Edit Auto-Scheduled Tasks'), findsWidgets);

    // 8. Test Navigation to Admin Console Screen
    await tester.tap(find.byIcon(Icons.admin_panel_settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Admin Console'), findsWidgets);
    expect(find.text('Registered Users Directory'), findsWidgets);
    expect(find.text('Total Users'), findsWidgets);
  });
}
