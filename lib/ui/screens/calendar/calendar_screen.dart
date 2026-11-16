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
            content: Text('Complete $label authorization in your browser, then return here.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.overdue,
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
            content: Text('Calendar events synced with server.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.overdue,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  event.source == 'google' ? Icons.calendar_month : Icons.calendar_today,
                  color: event.source == 'google' ? Colors.blue : Colors.cyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  event.source == 'google' ? 'Google Calendar Event' : 'Outlook Calendar Event',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('EEEE, MMM d  •  h:mm a').format(event.startTime.toLocal())} - ${DateFormat('h:mm a').format(event.endTime.toLocal())}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (event.location.isNotEmpty)
              Text(
                'Location: ${event.location}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            if (event.meetingUrl != null && event.meetingUrl!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Meeting link: ${event.meetingUrl}',
                style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
              ),
            ],
            const SizedBox(height: 20),

            // Prep Task Suggestion Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Suggested Preparation Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Task Title: "Prepare notes & slides for ${event.title}"', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    'Suggested Deadline: ${DateFormat('h:mm a (2h prior)').format(suggestedPrepDue.toLocal())}',
                    style: const TextStyle(fontSize: 12, color: AppColors.level2, fontWeight: FontWeight.w600),
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
                  child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add_task, size: 18),
                  label: const Text('Create Linked Task'),
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
                      SnackBar(content: Text('Created preparation task for "${event.title}"!')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              tooltip: 'Sync Calendars Now',
              icon: const Icon(Icons.sync, color: AppColors.primary),
              onPressed: _syncNow,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Integrations Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Connected Personal Calendar Accounts',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    // Google Calendar Chip
                    ActionChip(
                      avatar: Icon(
                        Icons.calendar_month,
                        color: accounts.google != null ? Colors.blue : AppColors.textMuted,
                        size: 16,
                      ),
                      label: Text(
                        accounts.google != null
                            ? 'Google (${accounts.google!.email.isNotEmpty ? accounts.google!.email : "Connected"})'
                            : '+ Connect Google Calendar',
                        style: TextStyle(
                          fontSize: 12,
                          color: accounts.google != null ? Colors.white : AppColors.textSecondary,
                          fontWeight: accounts.google != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: accounts.google != null ? Colors.blue.withValues(alpha: 0.15) : AppColors.background,
                      side: BorderSide(color: accounts.google != null ? Colors.blue.withValues(alpha: 0.5) : AppColors.border),
                      onPressed: () {
                        if (accounts.google != null) {
                          _confirmDisconnect(context, 'google', accounts.google!.email);
                        } else {
                          _connectProvider('google');
                        }
                      },
                    ),

                    // Outlook Calendar Chip
                    ActionChip(
                      avatar: Icon(
                        Icons.calendar_today,
                        color: accounts.outlook != null ? Colors.cyan : AppColors.textMuted,
                        size: 16,
                      ),
                      label: Text(
                        accounts.outlook != null
                            ? 'Outlook (${accounts.outlook!.email.isNotEmpty ? accounts.outlook!.email : "Connected"})'
                            : '+ Connect Outlook Calendar',
                        style: TextStyle(
                          fontSize: 12,
                          color: accounts.outlook != null ? Colors.white : AppColors.textSecondary,
                          fontWeight: accounts.outlook != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: accounts.outlook != null ? Colors.cyan.withValues(alpha: 0.15) : AppColors.background,
                      side: BorderSide(color: accounts.outlook != null ? Colors.cyan.withValues(alpha: 0.5) : AppColors.border),
                      onPressed: () {
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
          const SizedBox(height: 20),

          // Events rendering
          eventsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text('Error loading events: $err', style: const TextStyle(color: AppColors.overdue)),
              ),
            ),
            data: (events) {
              final unlinkedEvents = events.where((e) => !e.hasLinkedTask).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unlinkedEvents.isNotEmpty) ...[
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppColors.level2),
                        SizedBox(width: 8),
                        Text(
                          'Upcoming Events Missing Action Items',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: unlinkedEvents.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final ev = unlinkedEvents[i];
                          return Container(
                            width: 280,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      ev.source == 'google' ? Icons.calendar_month : Icons.calendar_today,
                                      size: 14,
                                      color: ev.source == 'google' ? Colors.blue : Colors.cyan,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        ev.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat('EEE, MMM d  •  h:mm a').format(ev.startTime.toLocal()),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text('Add Prep Task', style: TextStyle(fontSize: 11)),
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

                  const Text('Agenda Feed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          hasAnyConnected
                              ? 'No upcoming events synced yet. Tap Sync to fetch from your calendar.'
                              : 'Connect Google Calendar or Outlook above to sync your upcoming meetings.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...events.map((ev) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () => _showEventPrepSheet(ev),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ev.source == 'google' ? Colors.blue.withValues(alpha: 0.15) : Colors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              ev.source == 'google' ? Icons.calendar_month : Icons.calendar_today,
                              color: ev.source == 'google' ? Colors.blue : Colors.cyan,
                            ),
                          ),
                          title: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${DateFormat('EEE, MMM d • h:mm a').format(ev.startTime.toLocal())}${ev.location.isNotEmpty ? "  (${ev.location})" : ""}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: ev.hasLinkedTask
                              ? const Chip(
                                  label: Text('Prep Added', style: TextStyle(fontSize: 10, color: Colors.green)),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: Colors.green),
                                )
                              : const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
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
        title: Text('Disconnect ${provider == "google" ? "Google Calendar" : "Outlook"}?'),
        content: Text('Are you sure you want to disconnect $email? Events will no longer synchronize.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.overdue, foregroundColor: Colors.white),
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

