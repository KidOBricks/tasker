import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Export tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_timeframe.displayName} • ${filtered.length} tasks',
              style: AppTheme.mono(12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Copy CSV'),
                    onPressed: () {
                      final csv = AnalyticsEngine.exportToCsv(filtered);
                      Clipboard.setData(ClipboardData(text: csv));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CSV copied to clipboard')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.code, size: 16),
                    label: const Text('Copy JSON'),
                    onPressed: () {
                      final jsonStr = AnalyticsEngine.exportToJson(filtered, timeframe: _timeframe);
                      Clipboard.setData(ClipboardData(text: jsonStr));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('JSON copied to clipboard')),
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

    final isWide = MediaQuery.of(context).size.width >= 900;
    final pad = isWide ? 24.0 : 16.0;

    final chartCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Priority tier breakdown',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildLegendItem('Completed', AppColors.inProgress),
                    _buildLegendItem('In progress', AppColors.level2),
                    _buildLegendItem('Ignored', AppColors.ignored),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(stackedMetrics),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, _) => Text(
                          '${val.toInt()}',
                          style: AppTheme.mono(11, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < stackedMetrics.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                stackedMetrics[idx].label,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
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
                          borderRadius: BorderRadius.circular(4),
                          rodStackItems: [
                            BarChartRodStackItem(0, m.completed.toDouble(), AppColors.inProgress),
                            BarChartRodStackItem(
                              m.completed.toDouble(),
                              (m.completed + m.inProgress).toDouble(),
                              AppColors.level2,
                            ),
                            BarChartRodStackItem(
                              (m.completed + m.inProgress).toDouble(),
                              m.total.toDouble(),
                              AppColors.ignored,
                            ),
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
    );

    final bottleneckCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recurring delays',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (lateLeaderboard.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'All recurring routines are currently on schedule',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              )
            else
              Column(
                children: lateLeaderboard.take(5).map((chore) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              Text(
                                chore.title,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Late ${chore.lateCount} of ${chore.completionCount} cycles',
                                style: AppTheme.mono(11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chore.formattedDelay,
                          style: AppTheme.mono(
                            12,
                            color: AppColors.overdue,
                            weight: FontWeight.w500,
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
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Progress & Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _openExportDialog,
                  icon: const Icon(Icons.download_outlined, size: 16, color: AppColors.textSecondary),
                  label: const Text('Export'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Segmented timeframe control (outer radius 12 - 4px padding = 8px inner radius)
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _timeframe = tf),
                      child: AnimatedContainer(
                        duration: AppTheme.fastDuration,
                        curve: AppTheme.motionCurve,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: AppColors.borderStrong) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tf.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Compact stat cards (label + figure only)
            Row(
              children: [
                _buildStatCard('Completed', '$totalCompleted', AppColors.inProgress),
                const SizedBox(width: 12),
                _buildStatCard('In progress', '$totalInProgress', AppColors.level2),
                const SizedBox(width: 12),
                _buildStatCard('Ignored', '$totalIgnored', AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 16),

            // Asymmetric chart + bottleneck list on desktop
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: chartCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: bottleneckCard),
                ],
              )
            else ...[
              chartCard,
              const SizedBox(height: 16),
              bottleneckCard,
            ],

            const SizedBox(height: 16),

            // 12-week completion consistency heatmap
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Completion Consistency Heatmap',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Last 12 weeks',
                          style: AppTheme.mono(12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHeatmapGrid(heatmap),
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
    for (final m in metrics) {
      if (m.total > maxVal) maxVal = m.total;
    }
    return (maxVal + 2).toDouble();
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.mono(28, color: valueColor, weight: FontWeight.w500),
            ),
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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
          boxColor = AppColors.inProgress.withValues(alpha: 0.65);
        } else if (count == 1) {
          boxColor = AppColors.inProgress.withValues(alpha: 0.3);
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
