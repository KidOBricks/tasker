import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../models/recurrence_rule.dart';

enum AnalyticsTimeframe {
  today,
  thisWeek,
  thisMonth,
  thisYear;

  String get displayName {
    switch (this) {
      case AnalyticsTimeframe.today:
        return 'Today';
      case AnalyticsTimeframe.thisWeek:
        return 'This Week';
      case AnalyticsTimeframe.thisMonth:
        return 'This Month';
      case AnalyticsTimeframe.thisYear:
        return 'This Year';
    }
  }
}

class StackedLevelMetric {
  final String label; // "Level 1", "Level 2", "Level 3", "Overdue"
  final int completed;
  final int inProgress;
  final int ignored;

  int get total => completed + inProgress + ignored;

  const StackedLevelMetric({
    required this.label,
    required this.completed,
    required this.inProgress,
    required this.ignored,
  });
}

class LateChoreMetric {
  final String title;
  final double averageDelayHours;
  final int completionCount;
  final int lateCount;

  const LateChoreMetric({
    required this.title,
    required this.averageDelayHours,
    required this.completionCount,
    required this.lateCount,
  });

  String get formattedDelay {
    if (averageDelayHours >= 24) {
      final days = (averageDelayHours / 24).toStringAsFixed(1);
      return '$days days avg delay';
    }
    return '${averageDelayHours.toStringAsFixed(0)}h avg delay';
  }
}

class AnalyticsEngine {
  /// Filters tasks by whether their activity (completed, ignored, created, in progress) falls within the timeframe.
  static List<TaskItem> filterByTimeframe(
    List<TaskItem> tasks,
    AnalyticsTimeframe timeframe, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    DateTime startBoundary;

    switch (timeframe) {
      case AnalyticsTimeframe.today:
        startBoundary = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsTimeframe.thisWeek:
        final daysToMonday = now.weekday - DateTime.monday;
        final monday = now.subtract(Duration(days: daysToMonday));
        startBoundary = DateTime(monday.year, monday.month, monday.day);
        break;
      case AnalyticsTimeframe.thisMonth:
        startBoundary = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsTimeframe.thisYear:
        startBoundary = DateTime(now.year, 1, 1);
        break;
    }

    return tasks.where((t) {
      final relevantDate = t.completedAt ?? t.ignoredAt ?? t.inProgressAt ?? t.createdAt;
      return relevantDate.isAfter(startBoundary) || relevantDate.isAtSameMomentAs(startBoundary);
    }).toList();
  }

  /// Calculates the 4-column stacked metrics: Overdue, Level 3, Level 2, Level 1.
  static List<StackedLevelMetric> calculateStackedMetrics(List<TaskItem> tasks) {
    int completedL1 = 0, inProgL1 = 0, ignoredL1 = 0;
    int completedL2 = 0, inProgL2 = 0, ignoredL2 = 0;
    int completedL3 = 0, inProgL3 = 0, ignoredL3 = 0;
    int completedOverdue = 0, inProgOverdue = 0, ignoredOverdue = 0;

    for (final task in tasks) {
      // If task was overdue at completion or currently overdue
      final isOverdue = task.isOverdue ||
          (task.dueDate != null &&
              task.completedAt != null &&
              task.completedAt!.isAfter(task.dueDate!));

      if (isOverdue) {
        if (task.isCompleted) completedOverdue++;
        if (task.isInProgress) inProgOverdue++;
        if (task.isIgnored) ignoredOverdue++;
        continue;
      }

      final level = task.effectiveImportance;

      if (level >= 3) {
        if (task.isCompleted) completedL3++;
        if (task.isInProgress) inProgL3++;
        if (task.isIgnored) ignoredL3++;
      } else if (level == 2) {
        if (task.isCompleted) completedL2++;
        if (task.isInProgress) inProgL2++;
        if (task.isIgnored) ignoredL2++;
      } else {
        if (task.isCompleted) completedL1++;
        if (task.isInProgress) inProgL1++;
        if (task.isIgnored) ignoredL1++;
      }
    }

    return [
      StackedLevelMetric(label: 'Overdue', completed: completedOverdue, inProgress: inProgOverdue, ignored: ignoredOverdue),
      StackedLevelMetric(label: 'Level 3', completed: completedL3, inProgress: inProgL3, ignored: ignoredL3),
      StackedLevelMetric(label: 'Level 2', completed: completedL2, inProgress: inProgL2, ignored: ignoredL2),
      StackedLevelMetric(label: 'Level 1', completed: completedL1, inProgress: inProgL1, ignored: ignoredL1),
    ];
  }

  /// Generates daily completion counts for a GitHub-style activity heatmap (last 12 weeks / 84 days).
  static Map<DateTime, int> calculateActivityHeatmap(List<TaskItem> tasks, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = <DateTime, int>{};

    for (int i = 0; i < 84; i++) {
      final day = today.subtract(Duration(days: i));
      counts[day] = 0;
    }

    for (final task in tasks) {
      if (task.isCompleted && task.completedAt != null) {
        final d = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
        if (counts.containsKey(d)) {
          counts[d] = (counts[d] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  /// Calculates Late-Chore Diagnostic Leaderboard (ranks recurring tasks with highest average delay).
  static List<LateChoreMetric> calculateLateChoreLeaderboard(
    List<TaskItem> allArchivedTasks,
    List<RecurrenceRule> rules,
  ) {
    final ruleMap = {for (var r in rules) r.id: r};
    final delayTracker = <String, List<double>>{};
    final countTracker = <String, int>{};
    final titleMap = <String, String>{};

    for (final task in allArchivedTasks) {
      if (task.recurrenceRuleId == null || !task.isCompleted || task.dueDate == null || task.completedAt == null) {
        continue;
      }
      final ruleId = task.recurrenceRuleId!;
      final rule = ruleMap[ruleId];
      final title = rule?.title ?? task.title;
      titleMap[ruleId] = title;
      countTracker[ruleId] = (countTracker[ruleId] ?? 0) + 1;

      if (task.completedAt!.isAfter(task.dueDate!)) {
        final delayHours = task.completedAt!.difference(task.dueDate!).inMinutes / 60.0;
        delayTracker.putIfAbsent(ruleId, () => []).add(delayHours);
      }
    }

    final result = <LateChoreMetric>[];
    for (final ruleId in titleMap.keys) {
      final delays = delayTracker[ruleId] ?? [];
      final totalDelay = delays.fold<double>(0, (sum, val) => sum + val);
      final avgDelay = delays.isNotEmpty ? totalDelay / delays.length : 0.0;
      final totalCompletions = countTracker[ruleId] ?? 0;

      if (delays.isNotEmpty) {
        result.add(LateChoreMetric(
          title: titleMap[ruleId]!,
          averageDelayHours: avgDelay,
          completionCount: totalCompletions,
          lateCount: delays.length,
        ));
      }
    }

    result.sort((a, b) => b.averageDelayHours.compareTo(a.averageDelayHours));
    return result;
  }

  /// Exports filtered tasks into CSV format.
  static String exportToCsv(List<TaskItem> tasks) {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Title',
        'Category',
        'Base Importance',
        'Effective Importance',
        'Status',
        'Due Date',
        'Created At',
        'Completed At',
        'Ignored At',
        'Is Overdue',
        'Is Recurring',
      ]
    ];

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final t in tasks) {
      rows.add([
        t.id,
        t.title,
        t.categoryId,
        t.baseImportance,
        t.effectiveImportance,
        t.status.asString,
        t.dueDate != null ? dateFormat.format(t.dueDate!) : '',
        dateFormat.format(t.createdAt),
        t.completedAt != null ? dateFormat.format(t.completedAt!) : '',
        t.ignoredAt != null ? dateFormat.format(t.ignoredAt!) : '',
        t.isOverdue ? 'TRUE' : 'FALSE',
        t.isRecurring ? 'TRUE' : 'FALSE',
      ]);
    }

    return csv.encode(rows);
  }

  /// Exports filtered tasks and summary statistics into formatted JSON.
  static String exportToJson(List<TaskItem> tasks, {AnalyticsTimeframe? timeframe}) {
    final stacked = calculateStackedMetrics(tasks);
    final totalCompleted = tasks.where((t) => t.isCompleted).length;
    final totalInProgress = tasks.where((t) => t.isInProgress).length;
    final totalIgnored = tasks.where((t) => t.isIgnored).length;

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'timeframe': timeframe?.displayName ?? 'All Time',
      'summary': {
        'totalTasks': tasks.length,
        'completed': totalCompleted,
        'inProgress': totalInProgress,
        'ignored': totalIgnored,
        'levels': [
          for (final s in stacked)
            {
              'level': s.label,
              'completed': s.completed,
              'inProgress': s.inProgress,
              'ignored': s.ignored,
              'total': s.total,
            }
        ],
      },
      'tasks': [for (final t in tasks) t.toMap()],
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
