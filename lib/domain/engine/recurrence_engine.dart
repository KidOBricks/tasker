import 'package:uuid/uuid.dart';
import '../models/recurrence_rule.dart';
import '../models/task_item.dart';

class RecurrenceEngine {
  static const _uuid = Uuid();

  /// Calculates the next due date for an auto-scheduled rule based on completion/ignore time.
  /// For fixed schedules with sequential catch-up, steps forward one cycle from the original missed date.
  static ({DateTime nextDueAt, DateTime? updatedLastMissedDueDate}) calculateNextOccurrence({
    required RecurrenceRule rule,
    required DateTime actionTime, // when completed or ignored
    DateTime? originalDueDate,
  }) {
    if (rule.type == RecurrenceType.intervalAfterCompletion) {
      final interval = rule.intervalDays ?? 1;
      final next = actionTime.add(Duration(days: interval));
      return (nextDueAt: next, updatedLastMissedDueDate: null);
    }

    // Fixed schedule sequential catch-up
    final baseAnchor = rule.lastMissedDueDate ?? originalDueDate ?? rule.nextDueAt;
    final timeParts = rule.timeOfDay.split(':');
    final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 18 : 18;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

    DateTime candidate;

    switch (rule.frequency ?? ScheduleFrequency.weekly) {
      case ScheduleFrequency.daily:
        candidate = baseAnchor.add(const Duration(days: 1));
        break;

      case ScheduleFrequency.weekly:
        candidate = baseAnchor.add(const Duration(days: 7));
        break;

      case ScheduleFrequency.monthly:
        final nextMonth = baseAnchor.month == 12 ? 1 : baseAnchor.month + 1;
        final nextYear = baseAnchor.month == 12 ? baseAnchor.year + 1 : baseAnchor.year;
        final day = rule.dayOfMonth ?? baseAnchor.day;
        candidate = DateTime(nextYear, nextMonth, day, hour, minute);
        break;
    }

    // Set precise target time of day
    candidate = DateTime(
      candidate.year,
      candidate.month,
      candidate.day,
      hour,
      minute,
      59,
    );

    // If candidate is still before the current action time, user still has backlog to catch up!
    if (candidate.isBefore(actionTime)) {
      return (nextDueAt: candidate, updatedLastMissedDueDate: candidate);
    } else {
      // Caught up to the present / future
      return (nextDueAt: candidate, updatedLastMissedDueDate: null);
    }
  }

  /// Archives the current task as completed (or ignored) and spawns a fresh active instance
  /// with the calculated next due date.
  static ({TaskItem archivedTask, TaskItem? spawnedTask, RecurrenceRule updatedRule}) handleTaskCompletion({
    required TaskItem task,
    required RecurrenceRule rule,
    required TaskStatus finalStatus, // completed or ignored
    DateTime? actionTime,
  }) {
    final now = actionTime ?? DateTime.now();

    // 1. Finalize the current instance for history and progress analytics
    final archivedTask = task.copyWith(
      status: finalStatus,
      completedAt: finalStatus == TaskStatus.completed ? now : null,
      ignoredAt: finalStatus == TaskStatus.ignored ? now : null,
      clearInProgressAt: true,
    );

    // If the rule is paused or inactive, do not spawn next task
    if (!rule.isActive) {
      return (
        archivedTask: archivedTask,
        spawnedTask: null,
        updatedRule: rule,
      );
    }

    // 2. Calculate next occurrence
    final calculation = calculateNextOccurrence(
      rule: rule,
      actionTime: now,
      originalDueDate: task.dueDate,
    );

    // 3. Update rule record
    final updatedRule = rule.copyWith(
      nextDueAt: calculation.nextDueAt,
      lastMissedDueDate: calculation.updatedLastMissedDueDate,
      clearLastMissedDueDate: calculation.updatedLastMissedDueDate == null,
    );

    // 4. Spawn new active instance for the user
    final spawnedTask = TaskItem(
      id: _uuid.v4(),
      userId: task.userId,
      title: rule.title,
      description: rule.description ?? task.description,
      categoryId: rule.categoryId,
      baseImportance: rule.baseImportance,
      effectiveImportance: rule.baseImportance,
      dueDate: calculation.nextDueAt,
      status: TaskStatus.pending,
      createdAt: now,
      attachmentPaths: task.attachmentPaths,
      recurrenceRuleId: rule.id,
    );

    return (
      archivedTask: archivedTask,
      spawnedTask: spawnedTask,
      updatedRule: updatedRule,
    );
  }
}
