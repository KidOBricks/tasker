import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CalendarEventMock {
  final String id;
  final String title;
  final String source; // 'google' or 'outlook'
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final bool hasLinkedTask;

  const CalendarEventMock({
    required this.id,
    required this.title,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.hasLinkedTask = false,
  });
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late List<CalendarEventMock> _events;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _events = [
      CalendarEventMock(
        id: 'ev_1',
        title: 'Sprint Planning & Architecture Review',
        source: 'google',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        location: 'Google Meet',
        hasLinkedTask: false,
      ),
      CalendarEventMock(
        id: 'ev_2',
        title: 'Executive Client Demo & Q&A',
        source: 'outlook',
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        location: 'Microsoft Teams',
        hasLinkedTask: false,
      ),
      CalendarEventMock(
        id: 'ev_3',
        title: 'Dentist Checkup & Teeth Cleaning',
        source: 'google',
        startTime: DateTime(now.year, now.month, now.day + 2, 16, 30),
        endTime: DateTime(now.year, now.month, now.day + 2, 17, 30),
        location: 'Downtown Dental Clinic',
        hasLinkedTask: false,
      ),
    ];
  }

  void _showEventPrepSheet(CalendarEventMock event) {
    // Smart suggested prep deadline: 2 hours before the meeting
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
                          description: 'Action items for ${event.title} at ${event.location}.',
                          categoryId: 'work',
                          baseImportance: 3,
                          dueDate: suggestedPrepDue,
                        );
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
    final unlinkedEvents = _events.where((e) => !e.hasLinkedTask).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync, size: 14, color: AppColors.inProgress),
                SizedBox(width: 6),
                Text('Google & Outlook Synced', style: TextStyle(fontSize: 11, color: AppColors.inProgress)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Proactive Suggestion Carousel Feed (Decision from /grill-me)
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

          ..._events.map((ev) {
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
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
              ),
            );
          }),
        ],
      ),
    );
  }
}
