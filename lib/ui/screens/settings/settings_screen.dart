import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'auto_scheduled_tasks_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPasswordResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password Reset'),
        content: const Text('A password reset link will be sent to your registered account email address.'),
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

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final profile = ref.read(profileProvider);
    final nameController = TextEditingController(text: profile.displayName);
    final emailController = TextEditingController(text: profile.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Account Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(profileProvider.notifier).updateSettings();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile information updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReviewTime(BuildContext context, WidgetRef ref, String currentTime) async {
    final parts = currentTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final initialMin = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
      helpText: 'Select Review Tasks Reminder Time',
      builder: (context, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(profileProvider.notifier).updateSettings(reviewTasksTime: formatted);
    }
  }

  Future<void> _pickVacationRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Vacation Duration',
      builder: (context, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );

    if (pickedRange != null) {
      ref.read(profileProvider.notifier).updateSettings(
            vacationStartDate: pickedRange.start,
            vacationEndDate: pickedRange.end,
          );
    }
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
                      IconButton(
                        tooltip: 'Edit Profile',
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        onPressed: () => _showEditProfileDialog(context, ref),
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
          const Text('Priority & Escalation Windows', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

                  // Number of importance levels (e.g. 3, 4, 5)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number of Importance Levels', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text('Select tier hierarchy depth (3, 4, or 5)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                  const SizedBox(height: 14),

                  // Custom Importance Level Names Customizer
                  const Text('Custom Level Labels', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  for (int lvl = profile.numImportanceLevels; lvl >= 1; lvl--) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$lvl', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: profile.getLevelName(lvl),
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onFieldSubmitted: (text) {
                                if (text.trim().isNotEmpty) {
                                  ref.read(profileProvider.notifier).updateLevelName(lvl, text.trim());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(color: AppColors.border, height: 24),

                  // Escalation Windows (Number on left, Modifier on right)
                  const Text('Escalation Windows', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  // Level 2 Escalation Window
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Escalate to Level 2', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('When due date approaches within', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: profile.level2WindowValue,
                            dropdownColor: AppColors.surface,
                            items: [1, 2, 3, 5, 7, 10, 14, 21, 30]
                                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(profileProvider.notifier).updateSettings(level2WindowValue: val);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: profile.level2WindowUnit,
                            dropdownColor: AppColors.surface,
                            items: const [
                              DropdownMenuItem(value: 'hours', child: Text('hours')),
                              DropdownMenuItem(value: 'days', child: Text('days')),
                              DropdownMenuItem(value: 'weeks', child: Text('weeks')),
                              DropdownMenuItem(value: 'months', child: Text('months')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(profileProvider.notifier).updateSettings(level2WindowUnit: val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Level 3 Escalation Window
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Escalate to Level 3', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('When due date approaches within', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: profile.level3WindowValue,
                            dropdownColor: AppColors.surface,
                            items: [1, 2, 3, 4, 6, 12, 24, 48]
                                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(profileProvider.notifier).updateSettings(level3WindowValue: val);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: profile.level3WindowUnit,
                            dropdownColor: AppColors.surface,
                            items: const [
                              DropdownMenuItem(value: 'hours', child: Text('hours')),
                              DropdownMenuItem(value: 'days', child: Text('days')),
                              DropdownMenuItem(value: 'weeks', child: Text('weeks')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(profileProvider.notifier).updateSettings(level3WindowUnit: val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Edit Auto-Scheduled Tasks Manager Link
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.repeat, color: AppColors.primary, size: 22),
              ),
              title: const Text('Edit Auto-Scheduled Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                'View, modify, and delete all recurring routines (${rules.length} configured)',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AutoScheduledTasksScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // 4. Notifications Section
          const Text('Notifications & Daily Review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Push / Desktop Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Receive alerts for upcoming and overdue deadlines', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.notificationsEnabled,
                    activeThumbColor: AppColors.inProgress,
                    onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(notificationsEnabled: val),
                  ),
                  const Divider(color: AppColors.border, height: 20),
                  // Lead time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notification Timing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Alert lead time prior to deadline', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: profile.notifyPriorHours,
                        dropdownColor: AppColors.surface,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('At due time')),
                          DropdownMenuItem(value: 1, child: Text('1 hour before')),
                          DropdownMenuItem(value: 2, child: Text('2 hours before')),
                          DropdownMenuItem(value: 24, child: Text('1 day before')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(notifyPriorHours: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Task tier filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tasks to Notify For', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Filter notification frequency by urgency', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      DropdownButton<String>(
                        value: profile.notifyForTier,
                        dropdownColor: AppColors.surface,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All tasks')),
                          DropdownMenuItem(value: 'urgent_only', child: Text('Urgent only')),
                          DropdownMenuItem(value: 'in_progress_only', child: Text('In-progress only')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(notifyForTier: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 20),
                  // Daily "Review Tasks" persistent notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily "Review Tasks" Reminder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(
                              'Reminds at ${profile.reviewTasksTime} daily until you open the app that day',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(profile.reviewTasksTime),
                        onPressed: () => _pickReviewTime(context, ref, profile.reviewTasksTime),
                      ),
                      Switch(
                        value: profile.reviewTasksEnabled,
                        activeThumbColor: AppColors.inProgress,
                        onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(reviewTasksEnabled: val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 5. Vacation Mode Section
          const Text('Vacation Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vacation Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Freeze recurring chores and filter notifications while away', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.vacationModeEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(vacationModeEnabled: val),
                  ),
                  if (profile.vacationModeEnabled) ...[
                    const Divider(color: AppColors.border, height: 20),
                    // Vacation Date Range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vacation Period', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(
                              profile.vacationStartDate != null && profile.vacationEndDate != null
                                  ? '${DateFormat("MMM d").format(profile.vacationStartDate!)} - ${DateFormat("MMM d, yyyy").format(profile.vacationEndDate!)}'
                                  : 'No dates set (Indefinite)',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          icon: const Icon(Icons.date_range, size: 16),
                          label: const Text('Set Dates'),
                          onPressed: () => _pickVacationRange(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notification filter in Vacation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vacation Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Allowed notifications while on vacation', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: profile.vacationNotificationFilter,
                          dropdownColor: AppColors.surface,
                          items: const [
                            DropdownMenuItem(value: 'urgent_only', child: Text('Urgent only')),
                            DropdownMenuItem(value: 'none', child: Text('Silence all')),
                            DropdownMenuItem(value: 'all', child: Text('Allow all')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(profileProvider.notifier).updateSettings(vacationNotificationFilter: val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Frozen chores checklist
                    const Text('Select Auto-Scheduled Tasks to Freeze:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (rules.isEmpty)
                      const Text('No auto-scheduled routines configured.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                    else
                      ...rules.map((rule) {
                        final isChecked = profile.vacationFrozenChoreIds.contains(rule.id);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(rule.title, style: const TextStyle(fontSize: 13)),
                          subtitle: Text(rule.recurrenceSummary, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          value: isChecked,
                          onChanged: (_) => ref.read(profileProvider.notifier).toggleVacationChore(rule.id),
                        );
                      }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
