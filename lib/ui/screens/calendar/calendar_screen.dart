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
  void _showConnectDialog(BuildContext context, String provider) {
    final emailController = TextEditingController(
      text: provider == 'google' ? 'user@gmail.com' : 'user@outlook.com',
    );
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              provider == 'google' ? Icons.calendar_month : Icons.calendar_today,
              color: provider == 'google' ? Colors.blue : Colors.cyan,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(provider == 'google' ? 'Connect Google Calendar' : 'Connect Outlook Calendar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link your personal ${provider == "google" ? "Google Calendar" : "Microsoft Outlook"} to sync upcoming meetings and automatically generate preparation tasks.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Account Email',
                hintText: provider == 'google' ? 'you@gmail.com' : 'you@outlook.com',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'OAuth 2.0 Bearer Token (Optional)',
                hintText: 'Leave empty for simulated cloud connection',
                prefixIcon: Icon(Icons.key_outlined, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: provider == 'google' ? Colors.blue : Colors.cyan,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final email = emailController.text.trim();
              final token = tokenController.text.trim().isNotEmpty ? tokenController.text.trim() : null;
              if (email.isNotEmpty) {
                if (provider == 'google') {
                  ref.read(connectedAccountsProvider.notifier).connectGoogle(email: email, accessToken: token);
                } else {
                  ref.read(connectedAccountsProvider.notifier).connectOutlook(email: email, accessToken: token);
                }
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connected ${provider == "google" ? "Google" : "Outlook"} account: $email!'),
                    backgroundColor: AppColors.inProgress,
                  ),
                );
              }
            },
            child: const Text('Connect Account'),
          ),
        ],
      ),
    );
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
              '${DateFormat('EEEE, MMM d  •  h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            Text(
              'Location: ${event.location}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (event.meetingUrl != null) ...[
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
                    'Suggested Deadline: ${DateFormat('h:mm a (2h prior)').format(suggestedPrepDue)}',
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
                          description: 'Action items for ${event.title} (${event.location}).\nLink: ${event.meetingUrl ?? "N/A"}',
                          categoryId: 'work',
                          baseImportance: 3,
                          dueDate: suggestedPrepDue,
                        );
                    ref.read(externalEventsProvider.notifier).markEventLinked(event.id);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Sync Calendars Now',
            icon: const Icon(Icons.sync, color: AppColors.primary),
            onPressed: () {
              ref.read(externalEventsProvider.notifier).refreshEvents();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing Google Calendar & Outlook events...'), duration: Duration(seconds: 1)),
              );
            },
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
                        accounts.google != null ? 'Google (${accounts.google!.email})' : '+ Connect Google Calendar',
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
                          _showConnectDialog(context, 'google');
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
                        accounts.outlook != null ? 'Outlook (${accounts.outlook!.email})' : '+ Connect Outlook Calendar',
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
                          _showConnectDialog(context, 'microsoft');
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
                  // Proactive Suggestion Carousel Feed
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
                                  DateFormat('EEE, MMM d  •  h:mm a').format(ev.startTime),
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

                  // Interactive Agenda Feed
                  const Text('Agenda Feed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No upcoming events found.', style: TextStyle(color: AppColors.textMuted))),
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
                            '${DateFormat('EEE, MMM d • h:mm a').format(ev.startTime)}  (${ev.location})',
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
