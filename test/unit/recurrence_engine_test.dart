import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_sync/domain/engine/recurrence_engine.dart';
import 'package:task_calendar_sync/domain/models/recurrence_rule.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';

void main() {
  group('RecurrenceEngine Tests', () {
    final now = DateTime(2026, 11, 11, 14, 0, 0);

    test('Interval after completion adds interval to completion timestamp', () {
      final rule = RecurrenceRule(
        id: 'r_int',
        userId: 'u1',
        title: 'Water plants',
        type: RecurrenceType.intervalAfterCompletion,
        intervalDays: 4,
        baseImportance: 1,
        nextDueAt: now,
        createdAt: now,
      );

      final next = RecurrenceEngine.calculateNextOccurrence(
        rule: rule,
        actionTime: now,
      );

      expect(next.nextDueAt, now.add(const Duration(days: 4)));
      expect(next.updatedLastMissedDueDate, isNull);
    });

    test('Fixed weekly schedule steps forward sequentially when catching up late', () {
      // Rule was originally due on Nov 4 (7 days ago)
      final originalDueDate = DateTime(2026, 11, 4, 18, 0, 0);
      final rule = RecurrenceRule(
        id: 'r_weekly',
        userId: 'u1',
        title: 'Weekly Homework',
        type: RecurrenceType.fixedSchedule,
        frequency: ScheduleFrequency.weekly,
        timeOfDay: '18:00',
        baseImportance: 2,
        nextDueAt: originalDueDate,
        createdAt: DateTime(2026, 10, 1),
      );

      // User marks it complete on Nov 11 at 14:00 (before 18:00 deadline today)
      final result = RecurrenceEngine.calculateNextOccurrence(
        rule: rule,
        actionTime: now,
        originalDueDate: originalDueDate,
      );

      // Steps forward by 7 days from Nov 4 -> Nov 11 at 18:00:59
      expect(result.nextDueAt.day, 11);
      expect(result.nextDueAt.month, 11);
      expect(result.nextDueAt.hour, 18);
    });

    test('handleTaskCompletion archives completed instance and spawns new active instance', () {
      final rule = RecurrenceRule(
        id: 'r1',
        userId: 'u1',
        title: 'Clean kitchen filters',
        type: RecurrenceType.intervalAfterCompletion,
        intervalDays: 14,
        baseImportance: 2,
        nextDueAt: now,
        createdAt: now.subtract(const Duration(days: 30)),
      );

      final task = TaskItem(
        id: 'task_old',
        userId: 'u1',
        title: 'Clean kitchen filters',
        baseImportance: 2,
        effectiveImportance: 2,
        dueDate: now,
        status: TaskStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 14)),
        recurrenceRuleId: rule.id,
      );

      final result = RecurrenceEngine.handleTaskCompletion(
        task: task,
        rule: rule,
        finalStatus: TaskStatus.completed,
        actionTime: now,
      );

      // 1. Archived task is completed
      expect(result.archivedTask.status, TaskStatus.completed);
      expect(result.archivedTask.completedAt, now);
      expect(result.archivedTask.isInProgress, isFalse);

      // 2. Spawned task is active and scheduled 14 days out
      expect(result.spawnedTask, isNotNull);
      expect(result.spawnedTask!.id, isNot('task_old'));
      expect(result.spawnedTask!.status, TaskStatus.pending);
      expect(result.spawnedTask!.dueDate, now.add(const Duration(days: 14)));
      expect(result.spawnedTask!.recurrenceRuleId, rule.id);
    });

    test('Marking recurring task as Ignored advances schedule without disabling', () {
      final rule = RecurrenceRule(
        id: 'r2',
        userId: 'u1',
        title: 'Daily meditation',
        type: RecurrenceType.intervalAfterCompletion,
        intervalDays: 1,
        baseImportance: 1,
        nextDueAt: now,
        createdAt: now,
      );

      final task = TaskItem(
        id: 'task_med',
        userId: 'u1',
        title: 'Daily meditation',
        baseImportance: 1,
        effectiveImportance: 1,
        dueDate: now,
        createdAt: now,
        recurrenceRuleId: rule.id,
      );

      final result = RecurrenceEngine.handleTaskCompletion(
        task: task,
        rule: rule,
        finalStatus: TaskStatus.ignored,
        actionTime: now,
      );

      expect(result.archivedTask.status, TaskStatus.ignored);
      expect(result.archivedTask.ignoredAt, now);
      expect(result.spawnedTask, isNotNull);
      expect(result.spawnedTask!.dueDate, now.add(const Duration(days: 1)));
      expect(result.updatedRule.isActive, isTrue); // schedule remains active
    });
  });
}
