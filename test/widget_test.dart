import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_sync/data/repositories/task_repository.dart';
import 'package:task_calendar_sync/main.dart';
import 'package:task_calendar_sync/state/app_state.dart';

void main() {
  testWidgets('App mounts and displays navigation and task dashboard', (WidgetTester tester) async {
    // Set up mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final repository = await TaskRepository.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
        ],
        child: const TaskCalendarSyncApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify presence of Tasks destination and main sections
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Ideas'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
