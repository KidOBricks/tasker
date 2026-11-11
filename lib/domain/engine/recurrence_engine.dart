import 'package:uuid/uuid.dart';
import '../models/recurrence_rule.dart';
import '../models/task_item.dart';
import '../models/user_profile.dart';

class RecurrenceEngine {
  static const _uuid = Uuid();

  /// Calculates the next due date for an auto-scheduled rule based on completion/ignore time.
  /// Handles interval recurrence (days/weeks/months with afterCompletion toggle)
  /// and calendar recurrence (Google Calendar style daily/weekly/monthly).
  static ({DateTime nextDueAt, DateTime? updatedLastMissedDueDate}) calculateNextOccurrence({
    required RecurrenceRule rule,
    required DateTime actionTime, // when completed or ignored
    DateTime? originalDueDate,
  }) {
    if (rule.type.isInterval) {
      // If afterCompletion is true, calculate relative to actionTime.
      // If afterCompletion is false, calculate relative to originalDueDate (or actionTime if null).
      final baseAnchor = rule.afterCompletion
          ? actionTime
          : (originalDueDate ?? actionTime);

      DateTime next;
      if (rule.intervalUnit == 'weeks') {
        next = baseAnchor.add(Duration(days: rule.intervalValue * 7));
      } else if (rule.intervalUnit == 'months') {
        final nextMonth = baseAnchor.month + rule.intervalValue;
        final yearOffset = (nextMonth - 1) ~/ 12;
        final finalMonth = ((nextMonth - 1) % 12) + 1;
        final finalYear = baseAnchor.year + yearOffset;
        final targetDay = rule.dayOfMonth ?? baseAnchor.day;
        final clampedDay = targetDay.clamp(1, 28);
        next = DateTime(
          finalYear,
          finalMonth,
          clampedDay,
          baseAnchor.hour,
          baseAnchor.minute,
          baseAnchor.second,
        );
      } else {
        // Days
        next = baseAnchor.add(Duration(days: rule.intervalValue));
      }

      return (nextDueAt: next, updatedLastMissedDueDate: null);
    }

    // Calendar-based schedule (Google Calendar style)
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
        if (rule.daysOfWeek.isNotEmpty) {
          // Find next matching weekday in daysOfWeek
          DateTime cursor = baseAnchor.add(const Duration(days: 1));
          int loops = 0;
          while (!rule.daysOfWeek.contains(cursor.weekday) && loops < 7) {
            cursor = cursor.add(const Duration(days: 1));
            loops++;
          }
          candidate = cursor;
        } else {
          candidate = baseAnchor.add(const Duration(days: 7));
        }
        break;

      case ScheduleFrequency.monthly:
        final nextMonth = baseAnchor.month == 12 ? 1 : baseAnchor.month + 1;
        final nextYear = baseAnchor.month == 12 ? baseAnchor.year + 1 : baseAnchor.year;
        final day = (rule.dayOfMonth ?? baseAnchor.day).clamp(1, 28);
        candidate = DateTime(nextYear, nextMonth, day, hour, minute);
        break;

      case ScheduleFrequency.yearly:
        candidate = DateTime(baseAnchor.year + 1, baseAnchor.month, baseAnchor.day, hour, minute);
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

    // Sequential catch-up: if candidate is still before the action time, keep stepping
    if (candidate.isBefore(actionTime)) {
      return (nextDueAt: candidate, updatedLastMissedDueDate: candidate);
    } else {
      return (nextDueAt: candidate, updatedLastMissedDueDate: null);
    }
  }

  /// Archives the current task as completed (or ignored) and spawns a fresh active instance
  /// with the calculated next due date, unless paused by the user or Vacation Mode.
  static ({TaskItem archivedTask, TaskItem? spawnedTask, RecurrenceRule updatedRule}) handleTaskCompletion({
    required TaskItem task,
    required RecurrenceRule rule,
    required TaskStatus finalStatus, // completed or ignored
    DateTime? actionTime,
    UserProfile? userProfile,
  }) {
    final now = actionTime ?? DateTime.now();

    // 1. Finalize the current instance for history and progress analytics
    final archivedTask = task.copyWith(
      status: finalStatus,
      completedAt: finalStatus == TaskStatus.completed ? now : null,
      ignoredAt: finalStatus == TaskStatus.ignored ? now : null,
      clearInProgressAt: true,
    );

    // If the rule is paused or inactive, or frozen in Vacation Mode, do not spawn next task
    final isVacationFrozen = userProfile?.isChoreFrozenInVacation(rule.id) ?? false;
    if (!rule.isActive || isVacationFrozen) {
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
