import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/services/calendar_integration_service.dart';
import '../../../state/app_state.dart';
import '../../../state/integration_state.dart';
import '../../theme/app_theme.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isSyncing = false;

  Future<void> _connectProvider(String provider) async {
    final label = provider == 'google' ? 'Google Calendar' : 'Outlook Calendar';
    try {
      await ref.read(connectedAccountsProvider.notifier).connectProvider(provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complete $label sign-in in your browser, then return here'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await ref.read(connectedAccountsProvider.notifier).syncNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendar events synced'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _showEventPrepSheet(ExternalCalendarEvent event) {
    final suggestedPrepDue = event.startTime.subtract(const Duration(hours: 2));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.borderStrong),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  event.source == 'google' ? Icons.calendar_month_outlined : Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  event.source == 'google' ? 'Google Calendar' : 'Outlook Calendar',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('EEE, MMM d • h:mm a').format(event.startTime.toLocal())} – ${DateFormat('h:mm a').format(event.endTime.toLocal())}',
              style: AppTheme.mono(12, color: AppColors.textSecondary),
            ),
            if (event.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.location,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
            if (event.meetingUrl != null && event.meetingUrl!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.meetingUrl!,
                style: AppTheme.mono(11, color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested prep task',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prep: ${event.title}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due ${DateFormat('h:mm a').format(suggestedPrepDue.toLocal())} (2h before)',
                    style: AppTheme.mono(12, color: AppColors.level2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Create linked task'),
                  onPressed: () {
                    ref.read(tasksProvider.notifier).addTask(
                          title: 'Prep: ${event.title}',
                          description:
                              'Action items for ${event.title}${event.location.isNotEmpty ? " (${event.location})" : ""}.\nLink: ${event.meetingUrl ?? "N/A"}',
                          categoryId: 'work',
                          baseImportance: 3,
                          dueDate: suggestedPrepDue,
                          calendarEventId: event.id,
                        );
                    ref.read(externalEventsProvider.notifier).markEventLinked(event);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created prep task for "${event.title}"')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(connectedAccountsProvider);
    final eventsAsync = ref.watch(externalEventsProvider);
    final hasAnyConnected = accounts.google != null || accounts.outlook != null;
    final isWide = MediaQuery.of(context).size.width >= 840;
    final pad = isWide ? 24.0 : 16.0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          Row(
            children: [
              const Text(
                'Calendar & Integrations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_isSyncing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                OutlinedButton.icon(
                  onPressed: _syncNow,
                  icon: const Icon(Icons.sync, size: 16, color: AppColors.textSecondary),
                  label: const Text('Sync calendars'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Connected accounts card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connected Personal Calendar Accounts',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _AccountChip(
                        connected: accounts.google != null,
                        label: accounts.google != null
                            ? 'Google (${accounts.google!.email.isNotEmpty ? accounts.google!.email : "Connected"})'
                            : 'Connect Google Calendar',
                        onTap: () {
                          if (accounts.google != null) {
                            _confirmDisconnect(context, 'google', accounts.google!.email);
                          } else {
                            _connectProvider('google');
                          }
                        },
                      ),
                      _AccountChip(
                        connected: accounts.outlook != null,
                        label: accounts.outlook != null
                            ? 'Outlook (${accounts.outlook!.email.isNotEmpty ? accounts.outlook!.email : "Connected"})'
                            : 'Connect Outlook Calendar',
                        onTap: () {
                          if (accounts.outlook != null) {
                            _confirmDisconnect(context, 'microsoft', accounts.outlook!.email);
                          } else {
                            _connectProvider('microsoft');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          eventsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error loading events: $err',
                style: const TextStyle(color: AppColors.overdue, fontSize: 13),
              ),
            ),
            data: (events) {
              final unlinkedEvents = events.where((e) => !e.hasLinkedTask).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unlinkedEvents.isNotEmpty) ...[
                    const Text(
                      'Upcoming without prep tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 124,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: unlinkedEvents.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final ev = unlinkedEvents[i];
                          return Container(
                            width: 264,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ev.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('EEE, MMM d • h:mm a').format(ev.startTime.toLocal()),
                                  style: AppTheme.mono(12, color: AppColors.textMuted),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text('Add prep task', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _showEventPrepSheet(ev),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Agenda feed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          hasAnyConnected
                              ? 'No upcoming events synced yet. Tap Sync calendars to fetch.'
                              : 'Connect Google Calendar or Outlook above to sync upcoming meetings.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...events.map((ev) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            onTap: () => _showEventPrepSheet(ev),
                            leading: Icon(
                              ev.source == 'google'
                                  ? Icons.calendar_month_outlined
                                  : Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            title: Text(
                              ev.title,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${DateFormat('EEE, MMM d • h:mm a').format(ev.startTime.toLocal())}${ev.location.isNotEmpty ? " (${ev.location})" : ""}',
                              style: AppTheme.mono(12, color: AppColors.textMuted),
                            ),
                            trailing: ev.hasLinkedTask
                                ? Text(
                                    'Prep added',
                                    style: AppTheme.mono(12, color: AppColors.inProgress),
                                  )
                                : const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDisconnect(BuildContext context, String provider, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Disconnect ${provider == "google" ? "Google Calendar" : "Outlook"}'),
        content: Text(
          'Events from $email will stop syncing until reconnected.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.overdue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (provider == 'google') {
                ref.read(connectedAccountsProvider.notifier).disconnectGoogle();
              } else {
                ref.read(connectedAccountsProvider.notifier).disconnectOutlook();
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final bool connected;
  final String label;
  final VoidCallback onTap;

  const _AccountChip({
    required this.connected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: connected ? AppColors.surfaceLight : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: connected ? AppColors.borderStrong : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: connected ? AppColors.inProgress : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: connected ? FontWeight.w500 : FontWeight.w400,
                color: connected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
