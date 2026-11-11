import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/engine/analytics_engine.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  AnalyticsTimeframe _timeframe = AnalyticsTimeframe.thisWeek;

  void _openExportDialog() {
    final allTasks = ref.read(tasksProvider);
    final filtered = AnalyticsEngine.filterByTimeframe(allTasks, _timeframe);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Analytics & Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeframe: ${_timeframe.displayName}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Records included: ${filtered.length} tasks', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Choose format to export:', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: const Text('CSV Format'),
                    onPressed: () {
                      final csv = AnalyticsEngine.exportToCsv(filtered);
                      Clipboard.setData(ClipboardData(text: csv));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CSV copied to clipboard! Ready to paste into Excel/Sheets.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.code, size: 18),
                    label: const Text('JSON Format'),
                    onPressed: () {
                      final jsonStr = AnalyticsEngine.exportToJson(filtered, timeframe: _timeframe);
                      Clipboard.setData(ClipboardData(text: jsonStr));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('JSON copied to clipboard!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider);
    final rules = ref.watch(recurrenceRulesProvider);

    final filteredTasks = AnalyticsEngine.filterByTimeframe(allTasks, _timeframe);
    final stackedMetrics = AnalyticsEngine.calculateStackedMetrics(filteredTasks);
    final heatmap = AnalyticsEngine.calculateActivityHeatmap(allTasks);
    final lateLeaderboard = AnalyticsEngine.calculateLateChoreLeaderboard(allTasks, rules);

    final totalCompleted = filteredTasks.where((t) => t.isCompleted).length;
    final totalInProgress = filteredTasks.where((t) => t.isInProgress).length;
    final totalIgnored = filteredTasks.where((t) => t.isIgnored).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Export Stats (CSV / JSON)',
            icon: const Icon(Icons.download, color: AppColors.primary),
            onPressed: _openExportDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeframe Selector Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: AnalyticsTimeframe.values.map((tf) {
                  final isSelected = _timeframe == tf;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timeframe = tf),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tf.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Top Metric Counters Card
            Row(
              children: [
                _buildStatPill('Completed', '$totalCompleted', AppColors.inProgress),
                const SizedBox(width: 8),
                _buildStatPill('In Progress', '$totalInProgress', AppColors.level2),
                const SizedBox(width: 8),
                _buildStatPill('Ignored', '$totalIgnored', AppColors.ignored),
              ],
            ),
            const SizedBox(height: 20),

            // Primary Visualization: 4-Column Stacked Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Task Distribution by Priority Tier',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Wrap(
                          spacing: 12,
                          children: [
                            _buildLegendItem('Completed', AppColors.inProgress),
                            _buildLegendItem('In Progress', AppColors.level2),
                            _buildLegendItem('Ignored', AppColors.ignored),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _calculateMaxY(stackedMetrics),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < stackedMetrics.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        stackedMetrics[idx].label,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.surfaceLight, strokeWidth: 0.8),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: stackedMetrics.asMap().entries.map((entry) {
                            final i = entry.key;
                            final m = entry.value;

                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: m.total.toDouble(),
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                  rodStackItems: [
                                    BarChartRodStackItem(0, m.completed.toDouble(), AppColors.inProgress),
                                    BarChartRodStackItem(m.completed.toDouble(), (m.completed + m.inProgress).toDouble(), AppColors.level2),
                                    BarChartRodStackItem((m.completed + m.inProgress).toDouble(), m.total.toDouble(), AppColors.ignored),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Visualization 1: GitHub-Style Activity Heatmap
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completion Consistency Heatmap (Last 12 Weeks)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text('Daily Velocity', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildHeatmapGrid(heatmap),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Visualization 2: Late-Chore Diagnostic Leaderboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.level2),
                        SizedBox(width: 8),
                        Text(
                          'Late-Chore Diagnostic (Habit Bottlenecks)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (lateLeaderboard.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'All recurring chores are currently completed on schedule! Great streak.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      )
                    else
                      Column(
                        children: lateLeaderboard.take(5).map((chore) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(chore.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text(
                                        'Late ${chore.lateCount} of ${chore.completionCount} cycles',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.overdue.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    chore.formattedDelay,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.overdue),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<StackedLevelMetric> metrics) {
    int maxVal = 5;
    for (var m in metrics) {
      if (m.total > maxVal) maxVal = m.total;
    }
    return (maxVal + 2).toDouble();
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildHeatmapGrid(Map<DateTime, int> heatmap) {
    final days = heatmap.keys.toList().reversed.toList();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((day) {
        final count = heatmap[day] ?? 0;
        Color boxColor = AppColors.background;
        if (count >= 4) {
          boxColor = AppColors.inProgress;
        } else if (count >= 2) {
          boxColor = AppColors.inProgress.withValues(alpha: 0.7);
        } else if (count == 1) {
          boxColor = AppColors.inProgress.withValues(alpha: 0.35);
        }

        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
        );
      }).toList(),
    );
  }
}
