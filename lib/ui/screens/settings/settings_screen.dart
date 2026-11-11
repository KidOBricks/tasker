import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPasswordResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password Reset'),
        content: const Text('A password reset link will be sent to your registered account email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset instructions sent! Check your inbox.')),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final rules = ref.watch(recurrenceRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Account Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          profile.displayName.isNotEmpty ? profile.displayName[0] : 'U',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(profile.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _showPasswordResetDialog(context),
                        child: const Text('Reset Pass'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 2. Custom Importance Escalation Rules Section
          const Text('Priority & Escalation Rules', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Max in-progress tasks limit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Max In-Progress Tasks', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Limit concurrent active tasks for focus', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: profile.maxInProgressTasks,
                        dropdownColor: AppColors.surface,
                        items: [1, 2, 3, 5, 10].map((count) => DropdownMenuItem(value: count, child: Text('$count tasks'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(maxInProgressTasks: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),

                  // Number of importance levels (e.g. 3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Importance Levels', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Standard 3-tier hierarchy (L1, L2, L3)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: profile.numImportanceLevels,
                        dropdownColor: AppColors.surface,
                        items: [3, 4, 5].map((lvl) => DropdownMenuItem(value: lvl, child: Text('$lvl Levels'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(numImportanceLevels: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),

                  // Escalation Thresholds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('L2 Escalation Threshold', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('L1 auto-escalates to L2 when due in', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: profile.level2ThresholdDays,
                        dropdownColor: AppColors.surface,
                        items: [3, 5, 7, 10, 14].map((d) => DropdownMenuItem(value: d, child: Text('$d days'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(level2ThresholdDays: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('L3 Escalation Threshold', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('L2 auto-escalates to L3 when due in', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: profile.level3ThresholdDays,
                        dropdownColor: AppColors.surface,
                        items: [1, 2, 3].map((d) => DropdownMenuItem(value: d, child: Text('$d day(s)'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(level3ThresholdDays: val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Scheduled Tasks View (Manage Auto-Scheduling Tasks)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Scheduled (Recurring) Tasks', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('${rules.length} active rules', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          if (rules.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No recurring tasks created yet.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...rules.map((rule) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.repeat, color: AppColors.primary, size: 20),
                  ),
                  title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    rule.type.name == 'fixedSchedule'
                        ? 'Fixed schedule (every ${rule.frequency?.name ?? "week"}) • Next: ${DateFormat("MMM d, h:mm a").format(rule.nextDueAt)}'
                        : 'Interval: every ${rule.intervalDays ?? 3} days after completion • Next: ${DateFormat("MMM d, h:mm a").format(rule.nextDueAt)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: Switch(
                    value: rule.isActive,
                    activeThumbColor: AppColors.inProgress,
                    onChanged: (_) => ref.read(recurrenceRulesProvider.notifier).toggleActive(rule.id),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
