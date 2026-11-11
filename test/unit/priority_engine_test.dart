import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_sync/domain/engine/priority_engine.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/domain/models/user_profile.dart';

void main() {
  group('PriorityEngine Tests', () {
    final now = DateTime(2026, 11, 11, 10, 0, 0);
    const profile = UserProfile(
      uid: 'u1',
      email: 'alex@example.com',
      displayName: 'Alex',
      numImportanceLevels: 3,
      level2ThresholdDays: 7,
      level3ThresholdDays: 1,
    );

    test('Task without due date retains base importance and is not overdue', () {
      final task = TaskItem(
        id: 't1',
        userId: 'u1',
        title: 'Review notes',
        baseImportance: 1,
        effectiveImportance: 1,
        createdAt: now,
      );

      final evaluated = PriorityEngine.evaluate(task, profile, currentTime: now);
      expect(evaluated.effectiveImportance, 1);
      expect(evaluated.isOverdue, isFalse);
    });

    test('Task past due date becomes overdue and escalates to top level', () {
      final task = TaskItem(
        id: 't2',
        userId: 'u1',
        title: 'File taxes',
        baseImportance: 1,
        effectiveImportance: 1,
        dueDate: now.subtract(const Duration(hours: 2)), // 2 hours ago
        createdAt: now.subtract(const Duration(days: 2)),
      );

      final evaluated = PriorityEngine.evaluate(task, profile, currentTime: now);
      expect(evaluated.isOverdue, isTrue);
      expect(evaluated.effectiveImportance, 3);
    });

    test('Task due in 12 hours escalates Level 1 to Level 3', () {
      final task = TaskItem(
        id: 't3',
        userId: 'u1',
        title: 'Submit Homework',
        baseImportance: 1,
        effectiveImportance: 1,
        dueDate: now.add(const Duration(hours: 12)), // within 1 day
        createdAt: now,
      );

      final evaluated = PriorityEngine.evaluate(task, profile, currentTime: now);
      expect(evaluated.isOverdue, isFalse);
      expect(evaluated.effectiveImportance, 3);
    });

    test('Task due in 3 days escalates Level 1 to Level 2', () {
      final task = TaskItem(
        id: 't4',
        userId: 'u1',
        title: 'Weekly grocery list',
        baseImportance: 1,
        effectiveImportance: 1,
        dueDate: now.add(const Duration(days: 3)), // within 7 days
        createdAt: now,
      );

      final evaluated = PriorityEngine.evaluate(task, profile, currentTime: now);
      expect(evaluated.isOverdue, isFalse);
      expect(evaluated.effectiveImportance, 2);
    });

    test('Postponing due date de-escalates task back to base importance', () {
      // 1. Initially due tomorrow -> escalates to Level 3
      final task = TaskItem(
        id: 't5',
        userId: 'u1',
        title: 'Quarterly review',
        baseImportance: 1,
        effectiveImportance: 3,
        dueDate: now.add(const Duration(hours: 18)),
        createdAt: now,
      );

      // 2. Postponed to 14 days out
      final postponedTask = task.copyWith(
        dueDate: now.add(const Duration(days: 14)),
      );

      final evaluated = PriorityEngine.evaluate(postponedTask, profile, currentTime: now);
      expect(evaluated.isOverdue, isFalse);
      expect(evaluated.effectiveImportance, 1); // cleanly returned to base level!
    });

    test('Default due dates populate accurately', () {
      final l3Date = PriorityEngine.getDefaultDueDateForImportance(3, currentTime: now);
      expect(l3Date, isNotNull);
      expect(l3Date!.day, now.day + 1);
      expect(l3Date.hour, 23);
      expect(l3Date.minute, 59);

      final l2Date = PriorityEngine.getDefaultDueDateForImportance(2, currentTime: now);
      expect(l2Date, isNotNull);
      expect(l2Date!.day, now.day + 7);

      final l1Date = PriorityEngine.getDefaultDueDateForImportance(1, currentTime: now);
      expect(l1Date, isNull);
    });
  });
}
