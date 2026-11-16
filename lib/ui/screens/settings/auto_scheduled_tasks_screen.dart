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
          title: const Text('Edit recurring task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Cadence', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Every', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                  title: const Text('Schedule after completion', style: TextStyle(fontSize: 13)),
                  value: afterCompletion,
                  onChanged: (val) => setDialogState(() => afterCompletion = val ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 12),
                const Text('Importance level', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
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
                  const SnackBar(content: Text('Recurring routine updated')),
                );
              },
              child: const Text('Save'),
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
        title: const Text('Delete recurring routine'),
        content: Text(
          'Remove "${rule.title}"? Past completed records remain in history.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
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
                const SnackBar(content: Text('Recurring routine deleted')),
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
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        title: const Text(
          'Auto-scheduled tasks',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Auto-scheduled tasks spawn their next instance automatically when completed or ignored.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Configured routines (${rules.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (profile.vacationModeEnabled)
                    Text(
                      'Vacation mode active',
                      style: AppTheme.mono(12, color: AppColors.level2),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (rules.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.repeat, size: 32, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No auto-scheduled routines yet',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enable Recurring when creating a task to add one',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              else
                ...rules.map((rule) {
                  final isFrozen = profile.isChoreFrozenInVacation(rule.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  color: rule.isActive ? AppColors.primary : AppColors.textMuted,
                                  size: 18,
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
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: rule.isActive
                                                    ? AppColors.textPrimary
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                          if (isFrozen) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              'Paused',
                                              style: AppTheme.mono(11, color: AppColors.overdue),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rule.recurrenceSummary,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: rule.isActive,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (_) => ref.read(recurrenceRulesProvider.notifier).toggleActive(rule.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Next ${DateFormat("MMM d, yyyy • h:mm a").format(rule.nextDueAt)}',
                                  style: AppTheme.mono(12, color: AppColors.textMuted),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  icon: const Icon(Icons.edit_outlined, size: 14),
                                  label: const Text('Edit'),
                                  onPressed: () => _promptEditRule(context, ref, rule),
                                ),
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
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
