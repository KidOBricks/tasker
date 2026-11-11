import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_calendar_sync/domain/engine/analytics_engine.dart';
import 'package:task_calendar_sync/domain/models/recurrence_rule.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';

void main() {
  group('AnalyticsEngine Tests', () {
    final now = DateTime(2026, 11, 11, 12, 0, 0);

    final tasks = [
      TaskItem(
        id: '1',
        userId: 'u1',
        title: 'Task L3 Done',
        baseImportance: 3,
        effectiveImportance: 3,
        status: TaskStatus.completed,
        createdAt: now,
        completedAt: now,
      ),
      TaskItem(
        id: '2',
        userId: 'u1',
        title: 'Task L3 In Progress',
        baseImportance: 3,
        effectiveImportance: 3,
        status: TaskStatus.inProgress,
        createdAt: now,
        inProgressAt: now,
      ),
      TaskItem(
        id: '3',
        userId: 'u1',
        title: 'Task L2 Ignored',
        baseImportance: 2,
        effectiveImportance: 2,
        status: TaskStatus.ignored,
        createdAt: now,
        ignoredAt: now,
      ),
      TaskItem(
        id: '4',
        userId: 'u1',
        title: 'Task Overdue Done Late',
        baseImportance: 2,
        effectiveImportance: 3,
        dueDate: now.subtract(const Duration(days: 3)),
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now, // finished after due date -> counts as Overdue
      ),
    ];

    test('Stacked metrics calculate accurately across priority tiers', () {
      final metrics = AnalyticsEngine.calculateStackedMetrics(tasks);

      final overdueMetric = metrics.firstWhere((m) => m.label == 'Overdue');
      expect(overdueMetric.completed, 1);

      final l3Metric = metrics.firstWhere((m) => m.label == 'Level 3');
      expect(l3Metric.completed, 1);
      expect(l3Metric.inProgress, 1);

      final l2Metric = metrics.firstWhere((m) => m.label == 'Level 2');
      expect(l2Metric.ignored, 1);
    });

    test('CSV export contains proper headers and rows', () {
      final csv = AnalyticsEngine.exportToCsv(tasks);
      expect(csv, contains('Title,Category,Base Importance'));
      expect(csv, contains('Task L3 Done'));
      expect(csv, contains('Task Overdue Done Late'));
    });

    test('JSON export contains valid summary and task items', () {
      final jsonStr = AnalyticsEngine.exportToJson(tasks, timeframe: AnalyticsTimeframe.thisWeek);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;

      expect(decoded['timeframe'], 'This Week');
      expect(decoded['summary']['totalTasks'], 4);
      expect(decoded['summary']['completed'], 2);
      expect(decoded['tasks'], isNotEmpty);
    });

    test('Late-chore leaderboard ranks chores with highest delay', () {
      final rule = RecurrenceRule(
        id: 'r_bills',
        userId: 'u1',
        title: 'Pay utility bills',
        type: RecurrenceType.fixedSchedule,
        baseImportance: 3,
        nextDueAt: now,
        createdAt: now,
      );

      final lateTasks = [
        TaskItem(
          id: 't_late1',
          userId: 'u1',
          title: 'Pay utility bills',
          baseImportance: 3,
          effectiveImportance: 3,
          dueDate: now.subtract(const Duration(hours: 48)),
          status: TaskStatus.completed,
          completedAt: now, // 48h late
          createdAt: now.subtract(const Duration(days: 10)),
          recurrenceRuleId: rule.id,
        ),
      ];

      final leaderboard = AnalyticsEngine.calculateLateChoreLeaderboard(lateTasks, [rule]);
      expect(leaderboard, isNotEmpty);
      expect(leaderboard.first.title, 'Pay utility bills');
      expect(leaderboard.first.averageDelayHours, 48.0);
    });
  });
}
