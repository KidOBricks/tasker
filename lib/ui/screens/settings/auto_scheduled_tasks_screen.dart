import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/recurrence_rule.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';

class AutoScheduledTasksScreen extends ConsumerWidget {
  const AutoScheduledTasksScreen({super.key});

  void _promptEditRule(BuildContext context, WidgetRef ref, RecurrenceRule rule) {
    final titleController = TextEditingController(text: rule.title);
    final descController = TextEditingController(text: rule.description ?? '');
    int intervalVal = rule.intervalValue;
    String intervalUnit = rule.intervalUnit;
    bool afterCompletion = rule.afterCompletion;
    int baseImportance = rule.baseImportance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Auto-Scheduled Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Cadence & Interval:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Every'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: intervalVal,
                      dropdownColor: AppColors.surface,
                      items: [1, 2, 3, 4, 5, 6, 7, 10, 14, 21, 30]
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                          .toList(),
                      onChanged: (val) => setDialogState(() => intervalVal = val ?? 3),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: intervalUnit,
                      dropdownColor: AppColors.surface,
                      items: const [
                        DropdownMenuItem(value: 'days', child: Text('days')),
                        DropdownMenuItem(value: 'weeks', child: Text('weeks')),
                        DropdownMenuItem(value: 'months', child: Text('months')),
                      ],
                      onChanged: (val) => setDialogState(() => intervalUnit = val ?? 'days'),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('After completion', style: TextStyle(fontSize: 12)),
                  value: afterCompletion,
                  onChanged: (val) => setDialogState(() => afterCompletion = val ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 12),
                const Text('Importance Level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: baseImportance,
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 3, child: Text('Level 3 (Urgent)')),
                    DropdownMenuItem(value: 2, child: Text('Level 2 (Medium)')),
                    DropdownMenuItem(value: 1, child: Text('Level 1 (Low)')),
                  ],
                  onChanged: (val) => setDialogState(() => baseImportance = val ?? 1),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = rule.copyWith(
                  title: titleController.text.trim(),
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                  intervalValue: intervalVal,
                  intervalUnit: intervalUnit,
                  afterCompletion: afterCompletion,
                  baseImportance: baseImportance,
                );
                ref.read(recurrenceRulesProvider.notifier).updateRule(updated);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto-scheduled task updated!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteRule(BuildContext context, WidgetRef ref, RecurrenceRule rule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Auto-Scheduled Task?'),
        content: Text('Are you sure you want to remove "${rule.title}"? Existing completed task records will remain in history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.overdue, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(recurrenceRulesProvider.notifier).deleteRule(rule.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auto-scheduled task deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(recurrenceRulesProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Scheduled Tasks Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informational Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Auto-scheduled tasks automatically spawn fresh active instances whenever marked completed or ignored, keeping recurring routines on track.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configured Recurring Routines (${rules.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (profile.vacationModeEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.level2.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Vacation Active', style: TextStyle(fontSize: 11, color: AppColors.level2, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (rules.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.repeat, size: 40, color: AppColors.textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 10),
                    const Text('No auto-scheduled routines yet.', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    const Text('Create recurring tasks from the Home Screen (+) button.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            ...rules.map((rule) {
              final isFrozen = profile.isChoreFrozenInVacation(rule.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (rule.isActive ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.repeat,
                              color: rule.isActive ? AppColors.primary : AppColors.textMuted,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rule.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: rule.isActive ? AppColors.textPrimary : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    if (isFrozen) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.overdue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Frozen (Vacation)', style: TextStyle(fontSize: 10, color: AppColors.overdue)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rule.recurrenceSummary,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: rule.isActive,
                            activeThumbColor: AppColors.inProgress,
                            onChanged: (_) => ref.read(recurrenceRulesProvider.notifier).toggleActive(rule.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Next due: ${DateFormat("MMM d, yyyy • h:mm a").format(rule.nextDueAt)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const Spacer(),
                          // Edit Button
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit', style: TextStyle(fontSize: 12)),
                            onPressed: () => _promptEditRule(context, ref, rule),
                          ),
                          // Delete Button
                          IconButton(
                            tooltip: 'Delete routine',
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.overdue),
                            onPressed: () => _confirmDeleteRule(context, ref, rule),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
