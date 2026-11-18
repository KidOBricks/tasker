import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/services/calendar_integration_service.dart';
import '../../../data/services/database_service.dart';
import '../../../state/app_state.dart';
import '../../../state/auth_state.dart';
import '../../../state/integration_state.dart';
import '../../theme/app_theme.dart';
import 'auto_scheduled_tasks_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPasswordHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account access'),
        content: const Text(
          'Tasker does not send automated reset emails.\n\n'
          'Sign in with Google or Microsoft SSO, or ask an admin to update your password in PocketBase (/_/).',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final profile = ref.read(profileProvider);
    final authUser = ref.read(authProvider);
    final nameController = TextEditingController(
      text: profile.displayName.isNotEmpty ? profile.displayName : (authUser?.displayName ?? ''),
    );
    final emailController = TextEditingController(
      text: authUser?.email ?? profile.email,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email (managed in PocketBase)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final nextName = nameController.text.trim();
              if (nextName.isEmpty) return;
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(authProvider.notifier).updateDisplayName(nextName);
                if (ctx.mounted) nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Update failed: ${e.toString().replaceFirst("Exception: ", "")}'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showServerUrlDialog(BuildContext context, WidgetRef ref) {
    final currentUrl = ref.read(databaseServiceProvider).serverUrl;
    final urlController = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Base URL of your PocketBase server, such as https://1-2-3-4.sslip.io',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'https://1-2-3-4.sslip.io',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final nextUrl = urlController.text.trim();
              if (!nextUrl.startsWith('http://') && !nextUrl.startsWith('https://')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL must start with https:// or http://')),
                );
                return;
              }
              await ref.read(authProvider.notifier).updateServerUrl(nextUrl);
              final user = ref.read(authProvider);
              if (user != null) {
                await ref.read(databaseServiceProvider).performCloudSync(userId: user.id);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save & sync'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectIntegration(BuildContext context, WidgetRef ref, String provider) async {
    try {
      await ref.read(connectedAccountsProvider.notifier).connectProvider(provider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complete ${provider == "google" ? "Google" : "Microsoft"} sign-in in your browser, then return here',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _showGoogleCalendarsDialog(BuildContext context, WidgetRef ref) async {
    final calSvc = ref.read(calendarIntegrationServiceProvider);
    List<GoogleCalendarInfo> calendars;
    try {
      calendars = await calSvc.fetchGoogleCalendars();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load Google calendars: $e')),
        );
      }
      return;
    }
    if (!context.mounted) return;

    final selected = calendars.where((c) => c.selected).map((c) => c.id).toSet();
    if (selected.isEmpty && calendars.isNotEmpty) {
      final primary = calendars.firstWhere((c) => c.primary, orElse: () => calendars.first);
      selected.add(primary.id);
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select Google Calendars'),
          content: SizedBox(
            width: 420,
            child: calendars.isEmpty
                ? const Text('No calendars found on this Google account.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: calendars.length,
                    itemBuilder: (_, idx) {
                      final cal = calendars[idx];
                      return CheckboxListTile(
                        value: selected.contains(cal.id),
                        title: Text(cal.summary.isNotEmpty ? cal.summary : cal.id, style: const TextStyle(fontSize: 13)),
                        subtitle: cal.primary ? const Text('Primary calendar', style: TextStyle(fontSize: 11, color: AppColors.primary)) : null,
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selected.add(cal.id);
                            } else if (selected.length > 1) {
                              selected.remove(cal.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: calendars.isEmpty
                  ? null
                  : () async {
                      Navigator.of(ctx).pop();
                      await calSvc.saveGoogleCalendars(selected.toList());
                      await ref.read(connectedAccountsProvider.notifier).syncNow();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Updated calendars & synced events')),
                        );
                      }
                    },
              child: const Text('Save & sync'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomLeadTimeDialog(BuildContext context, WidgetRef ref, int currentMinutes) async {
    final controller = TextEditingController(text: '$currentMinutes');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom reminder lead time'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minutes before due time',
            hintText: 'e.g. 45',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0 && parsed <= 20160) {
                ref.read(profileProvider.notifier).updateSettings(notifyPriorMinutes: parsed);
                Navigator.of(ctx).pop();
              }
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
      helpText: 'Daily review time',
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
      helpText: 'Vacation period',
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
    final authUser = ref.watch(authProvider);
    final shownName = profile.displayName.isNotEmpty ? profile.displayName : (authUser?.displayName ?? 'User');
    final shownEmail = authUser?.email.isNotEmpty == true ? authUser!.email : profile.email;
    final isWide = MediaQuery.of(context).size.width >= 840;
    final pad = isWide ? 24.0 : 16.0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          const Text(
            'Profile & Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Account Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      shownName.isNotEmpty ? shownName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shownName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shownEmail,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    onPressed: () => _showEditProfileDialog(context, ref),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () => _showPasswordHelpDialog(context),
                    child: const Text('Reset pass'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Cloud Sync & Connected Accounts
          const Text(
            'Cloud Sync & Connected Accounts',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final syncStatus = ref.watch(syncStatusProvider).value ?? SyncStatus.offline;
                      final dbService = ref.read(databaseServiceProvider);
                      final badgeColor = syncStatus == SyncStatus.synced
                          ? AppColors.inProgress
                          : (syncStatus == SyncStatus.syncing ? AppColors.primary : AppColors.level2);
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      'PocketBase Cloud Sync',
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                    ),
                                    Text(
                                      syncStatus.displayName,
                                      style: AppTheme.mono(12, color: badgeColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${dbService.serverUrl} • Drift SQLite + SSE',
                                  style: AppTheme.mono(11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (!kIsWeb) ...[
                            TextButton(
                              onPressed: () => _showServerUrlDialog(context, ref),
                              child: const Text('Server'),
                            ),
                            const SizedBox(width: 4),
                          ],
                          ElevatedButton(
                            onPressed: () async {
                              final auth = ref.read(authProvider);
                              await ref.read(databaseServiceProvider).performCloudSync(userId: auth?.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cloud sync complete')),
                                );
                              }
                            },
                            child: const Text('Sync now'),
                          ),
                        ],
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),

                  // Google Account
                  Consumer(
                    builder: (context, ref, _) {
                      final accounts = ref.watch(connectedAccountsProvider);
                      final isConnected = accounts.google != null;
                      return Row(
                        children: [
                          const Icon(Icons.account_circle_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected
                                      ? 'Google (${accounts.google!.email.isNotEmpty ? accounts.google!.email : "Connected"})'
                                      : 'Google (Calendar & Gmail)',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isConnected
                                      ? 'Syncing Google Calendar events and Gmail inbox extraction'
                                      : 'Connect via OAuth to sync Google Calendar and Gmail',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (isConnected) ...[
                            TextButton(
                              onPressed: () => _showGoogleCalendarsDialog(context, ref),
                              child: const Text('Calendars'),
                            ),
                            const SizedBox(width: 4),
                          ],
                          OutlinedButton(
                            style: isConnected
                                ? OutlinedButton.styleFrom(foregroundColor: AppColors.overdue)
                                : null,
                            onPressed: () {
                              if (isConnected) {
                                ref.read(connectedAccountsProvider.notifier).disconnectGoogle();
                              } else {
                                _connectIntegration(context, ref, 'google');
                              }
                            },
                            child: Text(isConnected ? 'Disconnect' : 'Connect'),
                          ),
                        ],
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),

                  // Microsoft Outlook Account
                  Consumer(
                    builder: (context, ref, _) {
                      final accounts = ref.watch(connectedAccountsProvider);
                      final isConnected = accounts.outlook != null;
                      return Row(
                        children: [
                          const Icon(Icons.grid_view_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected
                                      ? 'Microsoft 365 (${accounts.outlook!.email.isNotEmpty ? accounts.outlook!.email : "Connected"})'
                                      : 'Microsoft 365 / Outlook Calendar',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isConnected
                                      ? 'Syncing Outlook Calendar events via Microsoft Graph'
                                      : 'Connect via OAuth to sync Outlook meetings',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: isConnected
                                ? OutlinedButton.styleFrom(foregroundColor: AppColors.overdue)
                                : null,
                            onPressed: () {
                              if (isConnected) {
                                ref.read(connectedAccountsProvider.notifier).disconnectOutlook();
                              } else {
                                _connectIntegration(context, ref, 'microsoft');
                              }
                            },
                            child: Text(isConnected ? 'Disconnect' : 'Connect'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Priority & Escalation Windows
          const Text(
            'Priority & Escalation Windows',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Max in-progress tasks', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Limit concurrent active tasks', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: profile.maxInProgressTasks,
                        dropdownColor: AppColors.surface,
                        items: [1, 2, 3, 5, 10]
                            .map((count) => DropdownMenuItem(value: count, child: Text('$count tasks')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(maxInProgressTasks: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Importance levels', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Tier hierarchy depth (3, 4, or 5)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: profile.numImportanceLevels,
                        dropdownColor: AppColors.surface,
                        items: [3, 4, 5].map((lvl) => DropdownMenuItem(value: lvl, child: Text('$lvl levels'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(numImportanceLevels: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Level labels',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  for (int lvl = profile.numImportanceLevels; lvl >= 1; lvl--)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '$lvl',
                              style: AppTheme.mono(12, color: AppColors.textPrimary, weight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: profile.getLevelName(lvl),
                              style: const TextStyle(fontSize: 13),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  const Text(
                    'Escalation windows',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Escalate to level 2', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('When due date is within', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Escalate to level 3', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('When due date is within', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
          const SizedBox(height: 16),

          // Auto-Scheduled Tasks Manager Link
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.repeat, color: AppColors.textSecondary, size: 20),
              title: const Text('Edit Auto-Scheduled Tasks', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              subtitle: Text(
                '${rules.length} recurring routines configured',
                style: AppTheme.mono(12, color: AppColors.textMuted),
              ),
              trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AutoScheduledTasksScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 4. Notifications & Daily Review
          const Text(
            'Notifications & daily review',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push and desktop notifications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: const Text('Alert on upcoming and overdue deadlines', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(notificationsEnabled: val),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lead time', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('Alert before due time', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: profile.notifyPriorMinutes,
                        dropdownColor: AppColors.surface,
                        items: [
                          const DropdownMenuItem(value: 0, child: Text('At due time')),
                          const DropdownMenuItem(value: 15, child: Text('15 min before')),
                          const DropdownMenuItem(value: 30, child: Text('30 min before')),
                          const DropdownMenuItem(value: 60, child: Text('1 hour before')),
                          const DropdownMenuItem(value: 120, child: Text('2 hours before')),
                          const DropdownMenuItem(value: 1440, child: Text('1 day before')),
                          if (!{0, 15, 30, 60, 120, 1440}.contains(profile.notifyPriorMinutes))
                            DropdownMenuItem(
                              value: profile.notifyPriorMinutes,
                              child: Text('${profile.notifyPriorMinutes} min before'),
                            ),
                          const DropdownMenuItem(value: -1, child: Text('Custom...')),
                        ],
                        onChanged: (val) {
                          if (val == -1) {
                            _showCustomLeadTimeDialog(context, ref, profile.notifyPriorMinutes);
                          } else if (val != null) {
                            ref.read(profileProvider.notifier).updateSettings(notifyPriorMinutes: val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Overdue reminders', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    subtitle: const Text('Alert once per day for past-due tasks', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.notifyForOverdue,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(notifyForOverdue: val),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final granted = await ref.read(notificationServiceProvider).requestPermissions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  granted
                                      ? 'Browser/OS notifications enabled'
                                      : 'Permission not granted — in-app banners will still alert you',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.notifications_active_outlined, size: 16),
                        label: const Text('Enable alerts'),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.read(notificationServiceProvider).sendTestNotification(),
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text('Test alert'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tasks to notify for', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('Filter alerts by urgency', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily review reminder', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text(
                              'Reminds at ${profile.reviewTasksTime} until opened',
                              style: AppTheme.mono(12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(profile.reviewTasksTime, style: AppTheme.mono(12, color: AppColors.textPrimary)),
                        onPressed: () => _pickReviewTime(context, ref, profile.reviewTasksTime),
                      ),
                      Switch(
                        value: profile.reviewTasksEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(reviewTasksEnabled: val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4b. Trusted Taskgivers
          const _TrustedTaskgiversSection(),
          const SizedBox(height: 24),

          // 5. Vacation Mode
          const Text(
            'Vacation Mode',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pause recurring routines', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: const Text('Freeze selected routines and mute alerts while away', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.vacationModeEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => ref.read(profileProvider.notifier).updateSettings(vacationModeEnabled: val),
                  ),
                  if (profile.vacationModeEnabled) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vacation period', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text(
                              profile.vacationStartDate != null && profile.vacationEndDate != null
                                  ? '${DateFormat("MMM d").format(profile.vacationStartDate!)} – ${DateFormat("MMM d, yyyy").format(profile.vacationEndDate!)}'
                                  : 'No dates set (indefinite)',
                              style: AppTheme.mono(12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.date_range_outlined, size: 16),
                          label: const Text('Set dates'),
                          onPressed: () => _pickVacationRange(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vacation notifications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            Text('Alerts allowed while away', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                    const Text('Routines to pause', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (rules.isEmpty)
                      const Text('No auto-scheduled routines configured', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                    else
                      ...rules.map((rule) {
                        final isChecked = profile.vacationFrozenChoreIds.contains(rule.id);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(rule.title, style: const TextStyle(fontSize: 13)),
                          subtitle: Text(rule.recurrenceSummary, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          value: isChecked,
                          onChanged: (_) => ref.read(profileProvider.notifier).toggleVacationChore(rule.id),
                        );
                      }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TrustedTaskgiversSection extends ConsumerStatefulWidget {
  const _TrustedTaskgiversSection();

  @override
  ConsumerState<_TrustedTaskgiversSection> createState() => _TrustedTaskgiversSectionState();
}

class _TrustedTaskgiversSectionState extends ConsumerState<_TrustedTaskgiversSection> {
  List<TrustedTaskgiver> _items = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authProvider);
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final list = await ref.read(calendarIntegrationServiceProvider).listTaskgivers(user.id);
      if (mounted) setState(() => _items = list);
    } catch (_) {
      // Offline or unconfigured server: keep current list
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAddEditDialog({TrustedTaskgiver? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Trusted Taskgiver' : 'Edit Trusted Taskgiver'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Manager, Partner',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'Notify when you finish their task',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final svc = ref.read(calendarIntegrationServiceProvider);
              Navigator.of(ctx).pop();
              try {
                if (existing == null) {
                  final created = await svc.createTaskgiver(name: nameCtrl.text, email: emailCtrl.text);
                  await Clipboard.setData(ClipboardData(text: created.shareUrl));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created link for ${created.name} (copied to clipboard)')),
                    );
                  }
                } else {
                  await svc.updateTaskgiver(existing.id, name: nameCtrl.text, email: emailCtrl.text);
                }
                await _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: Text(existing == null ? 'Generate link' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trusted Taskgivers',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            OutlinedButton.icon(
              onPressed: () => _openAddEditDialog(),
              icon: const Icon(Icons.link, size: 16),
              label: const Text('New link'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _loading && _items.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
                : _items.isEmpty
                    ? const Text(
                        'Create a unique link for someone you trust so they can add tasks to your list and check task status.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      )
                    : Column(
                        children: _items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (item.isActive ? AppColors.inProgress : AppColors.overdue).withValues(alpha: 0.16),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.isActive ? 'Active' : 'Revoked',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: item.isActive ? AppColors.inProgress : AppColors.overdue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.email.isNotEmpty)
                                        Text(item.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                      Text(
                                        item.shareUrl,
                                        style: AppTheme.mono(11, color: AppColors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Copy link',
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: item.shareUrl));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Share link copied')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _openAddEditDialog(existing: item),
                                ),
                                Switch(
                                  value: item.isActive,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) async {
                                    await ref.read(calendarIntegrationServiceProvider).updateTaskgiver(item.id, isActive: val);
                                    await _load();
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.overdue),
                                  onPressed: () async {
                                    await ref.read(calendarIntegrationServiceProvider).deleteTaskgiver(item.id);
                                    await _load();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ),
      ],
    );
  }
}
