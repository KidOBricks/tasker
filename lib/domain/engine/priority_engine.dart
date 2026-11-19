import 'dart:math';
import '../models/task_item.dart';
import '../models/user_profile.dart';

class PriorityEngine {
  /// Evaluates dynamic escalation and overdue status based on deadline proximity.
  /// Does NOT mutate baseImportance, allowing natural de-escalation if the due date is postponed.
  static TaskItem evaluate(
    TaskItem task,
    UserProfile profile, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Completed or ignored tasks retain their final state
    if (task.isCompleted || task.isIgnored) {
      return task;
    }

    final clampedBase = task.baseImportance.clamp(1, profile.numImportanceLevels);

    if (task.dueDate == null) {
      return task.copyWith(
        baseImportance: clampedBase,
        effectiveImportance: clampedBase,
        isOverdue: false,
      );
    }

    final dueDate = task.dueDate!;
    final isOverdue = now.isAfter(dueDate);

    if (isOverdue) {
      return task.copyWith(
        baseImportance: clampedBase,
        effectiveImportance: profile.numImportanceLevels,
        isOverdue: true,
      );
    }

    final diff = dueDate.difference(now);
    int computedImportance = clampedBase;

    // Escalate to the highest configured level (numImportanceLevels down to 2) whose threshold matches.
    for (int lvl = profile.numImportanceLevels; lvl >= 2; lvl--) {
      if (diff.inSeconds <= profile.getThresholdDuration(lvl).inSeconds) {
        computedImportance = max(clampedBase, lvl);
        break;
      }
    }

    // Ensure within valid bounds [1, profile.numImportanceLevels]
    computedImportance = computedImportance.clamp(1, profile.numImportanceLevels);

    return task.copyWith(
      baseImportance: clampedBase,
      effectiveImportance: computedImportance,
      isOverdue: false,
    );
  }

  /// Calculates smart default due date when creating a new task based on importance:
  /// - Level 3+: End of tomorrow (23:59:59)
  /// - Level 2: 7 days away (23:59:59)
  /// - Level 1: No due date (null)
  static DateTime? getDefaultDueDateForImportance(
    int importance, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    if (importance >= 3) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
    } else if (importance == 2) {
      final target = now.add(const Duration(days: 7));
      return DateTime(target.year, target.month, target.day, 23, 59, 59);
    } else {
      // Level 1: No due date
      return null;
    }
  }

  /// Sorts tasks with highest priority and earliest due dates first.
  static List<TaskItem> sortByUrgency(List<TaskItem> tasks) {
    final sorted = List<TaskItem>.from(tasks);
    sorted.sort((a, b) {
      // 1. Overdue tasks come first
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // 2. Earliest due date first
      if (a.dueDate != null && b.dueDate != null) {
        final dateComp = a.dueDate!.compareTo(b.dueDate!);
        if (dateComp != 0) return dateComp;
      } else if (a.dueDate != null && b.dueDate == null) {
        return -1; // tasks with deadlines take precedence
      } else if (a.dueDate == null && b.dueDate != null) {
        return 1;
      }

      // 3. Higher effective importance first
      if (a.effectiveImportance != b.effectiveImportance) {
        return b.effectiveImportance.compareTo(a.effectiveImportance);
      }

      // 4. Fallback to newest created
      return b.createdAt.compareTo(a.createdAt);
    });

    return sorted;
  }
}
