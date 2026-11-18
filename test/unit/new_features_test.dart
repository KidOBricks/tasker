import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_sync/data/services/notification_service.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/domain/models/user_profile.dart';
import 'package:task_calendar_sync/ui/screens/home/widgets/bulk_add_tasks_dialog.dart';
import 'package:task_calendar_sync/ui/widgets/celebration_confetti.dart';

void main() {
  group('Subtasks priority roll-up and auto-completion', () {
    test('parent priority matches highest subtask and auto-completes when all done', () {
      final base = TaskItem(
        id: 't1',
        userId: 'u1',
        title: 'Launch feature',
        baseImportance: 1,
        effectiveImportance: 1,
        createdAt: DateTime(2026, 11, 18),
        subtasks: const [
          SubtaskItem(id: 's1', title: 'Draft', baseImportance: 1, isCompleted: true),
          SubtaskItem(id: 's2', title: 'Deploy', baseImportance: 3, isCompleted: false),
        ],
      );

      final rolled = base.recalculateFromSubtasks();
      expect(rolled.baseImportance, 3);
      expect(rolled.isCompleted, false);

      final allDone = rolled.copyWith(
        subtasks: rolled.subtasks.map((s) => s.copyWith(isCompleted: true)).toList(),
      ).recalculateFromSubtasks(currentTime: DateTime(2026, 11, 18, 12));

      expect(allDone.isCompleted, true);
      expect(allDone.completedAt, isNotNull);

      final reopened = allDone.copyWith(
        subtasks: [
          allDone.subtasks.first.copyWith(isCompleted: false),
          allDone.subtasks.last,
        ],
      ).recalculateFromSubtasks();
      expect(reopened.isCompleted, false);
      expect(reopened.completedAt, isNull);
    });
  });

  group('BulkAddTasksDialog.splitLinesLocally', () {
    test('strips markdown bullets, checkboxes, and numbering', () {
      final drafts = BulkAddTasksDialog.splitLinesLocally(
        '- [ ] Buy milk\n* Call mom\n1. Submit assignment\n\n• Clean desk',
        defaultCategoryId: 'personal',
        defaultImportance: 2,
      );
      expect(drafts.map((d) => d.title).toList(), [
        'Buy milk',
        'Call mom',
        'Submit assignment',
        'Clean desk',
      ]);
      expect(drafts.every((d) => d.categoryId == 'personal' && d.importance == 2), true);
    });
  });

  group('NotificationService.computePendingReminders', () {
    test('triggers upcoming reminder within notifyPriorMinutes and respects overdue/tier filters', () {
      final now = DateTime(2026, 11, 18, 10, 0);
      final profile = UserProfile.defaultProfile().copyWith(
        notificationsEnabled: true,
        notifyPriorMinutes: 30,
        notifyForTier: 'all',
        notifyForOverdue: true,
        reviewTasksEnabled: false,
      );

      final tasks = [
        TaskItem(
          id: 'soon',
          userId: 'u1',
          title: 'Standup prep',
          baseImportance: 2,
          effectiveImportance: 2,
          dueDate: DateTime(2026, 11, 18, 10, 20),
          createdAt: now,
        ),
        TaskItem(
          id: 'later',
          userId: 'u1',
          title: 'Evening chore',
          baseImportance: 2,
          effectiveImportance: 2,
          dueDate: DateTime(2026, 11, 18, 18, 0),
          createdAt: now,
        ),
        TaskItem(
          id: 'late',
          userId: 'u1',
          title: 'Send invoice',
          baseImportance: 3,
          effectiveImportance: 3,
          dueDate: DateTime(2026, 11, 18, 9, 0),
          createdAt: now,
        ),
      ];

      final reminders = NotificationService.computePendingReminders(tasks, profile, now: now);
      expect(reminders.length, 2);
      expect(reminders.any((r) => r.title.contains('Standup prep')), true);
      expect(reminders.any((r) => r.title.contains('Send invoice')), true);

      final muted = profile.copyWith(notificationsEnabled: false);
      expect(NotificationService.computePendingReminders(tasks, muted, now: now), isEmpty);
    });

    test('computeScheduledAlarms returns future upcoming, overdue, and next daily review triggers', () {
      final now = DateTime(2026, 11, 18, 10, 0);
      final profile = UserProfile.defaultProfile().copyWith(
        notificationsEnabled: true,
        notifyPriorMinutes: 30,
        notifyForTier: 'all',
        notifyForOverdue: true,
        reviewTasksEnabled: true,
        reviewTasksTime: '09:30',
      );
      final tasks = [
        TaskItem(
          id: 'upcoming',
          userId: 'u1',
          title: 'Submit deck',
          baseImportance: 2,
          effectiveImportance: 2,
          dueDate: DateTime(2026, 11, 18, 11, 15),
          createdAt: now,
        ),
        TaskItem(
          id: 'done',
          userId: 'u1',
          title: 'Already done',
          baseImportance: 3,
          effectiveImportance: 3,
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 11, 18, 12, 0),
          createdAt: now,
        ),
      ];

      final alarms = NotificationService.computeScheduledAlarms(tasks, profile, now: now);
      expect(alarms.map((a) => a.title).toList(), [
        'Upcoming: Submit deck',
        'Overdue: Submit deck',
        'Daily Task Review',
      ]);
      expect(alarms[0].triggerAt, DateTime(2026, 11, 18, 10, 45));
      expect(alarms[1].triggerAt, DateTime(2026, 11, 18, 11, 15));
      // Since 09:30 has passed today at 10:00, review alarm schedules for tomorrow 09:30.
      expect(alarms[2].triggerAt, DateTime(2026, 11, 19, 9, 30));

      final muted = profile.copyWith(notificationsEnabled: false);
      expect(NotificationService.computeScheduledAlarms(tasks, muted, now: now), isEmpty);
    });
  });

  group('CelebrationConfettiOverlay', () {
    testWidgets('triggers and animates without error', (tester) async {
      final key = GlobalKey<CelebrationConfettiOverlayState>();
      await tester.pumpWidget(
        MaterialApp(
          home: CelebrationConfettiOverlay(
            key: key,
            child: const Scaffold(body: Center(child: Text('Done'))),
          ),
        ),
      );
      key.currentState!.trigger();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 2600));
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
