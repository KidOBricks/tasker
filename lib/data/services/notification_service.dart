import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/user_profile.dart';
import 'database_service.dart';

class PendingReminder {
  final String key;
  final String title;
  final String body;
  final bool isUrgent;

  const PendingReminder({
    required this.key,
    required this.title,
    required this.body,
    this.isUrgent = false,
  });
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final StreamController<PendingReminder> _inAppController = StreamController<PendingReminder>.broadcast();
  final Set<String> _firedKeys = {};
  bool _initialized = false;

  Stream<PendingReminder> get inAppAlerts => _inAppController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        windows: WindowsInitializationSettings(
          appName: 'Tasker',
          appUserModelId: 'KidOBricks.Tasker.Desktop',
          guid: '8c5b1b5d-6f4a-4b67-9c12-1e3c4d5e6f70',
        ),
        web: WebInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init skipped: $e');
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    try {
      if (kIsWeb) {
        final webPlugin = _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();
        return await webPlugin?.requestNotificationsPermission() ?? false;
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.requestNotificationsPermission() ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Pure reminder evaluation helper for unit testing and periodic checks.
  static List<PendingReminder> computePendingReminders(
    List<TaskItem> tasks,
    UserProfile profile, {
    DateTime? now,
  }) {
    if (!profile.notificationsEnabled) return const [];
    final current = now ?? DateTime.now();
    final reminders = <PendingReminder>[];
    final lead = Duration(minutes: profile.notifyPriorMinutes.clamp(0, 60 * 24 * 14));

    for (final task in tasks) {
      if (task.isCompleted || task.isIgnored) continue;
      if (profile.isChoreFrozenInVacation(task.recurrenceRuleId)) continue;
      if (profile.notifyForTier == 'urgent_only' && task.effectiveImportance < 3) continue;
      if (profile.notifyForTier == 'in_progress_only' && !task.isInProgress) continue;

      final due = task.dueDate;
      if (due == null) continue;

      if (current.isAfter(due)) {
        if (profile.notifyForOverdue) {
          final dayKey = '${current.year}-${current.month}-${current.day}';
          reminders.add(PendingReminder(
            key: 'overdue:${task.id}:$dayKey',
            title: 'Overdue: ${task.title}',
            body: 'Past due since ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}',
            isUrgent: true,
          ));
        }
        continue;
      }

      final triggerAt = due.subtract(lead);
      if (!current.isBefore(triggerAt)) {
        final minsLeft = due.difference(current).inMinutes;
        final timeText = minsLeft <= 1 ? 'Due now' : 'Due in $minsLeft min';
        reminders.add(PendingReminder(
          key: 'due:${task.id}:${due.toIso8601String()}:${profile.notifyPriorMinutes}',
          title: 'Upcoming: ${task.title}',
          body: timeText,
          isUrgent: task.effectiveImportance >= 3,
        ));
      }
    }

    if (profile.reviewTasksEnabled) {
      final parts = profile.reviewTasksTime.split(':');
      final hh = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
      final mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final reviewAt = DateTime(current.year, current.month, current.day, hh, mm);
      final diffMins = current.difference(reviewAt).inMinutes;
      if (diffMins >= 0 && diffMins < 5) {
        final dayKey = '${current.year}-${current.month}-${current.day}';
        final activeCount = tasks.where((t) => !t.isCompleted && !t.isIgnored).length;
        reminders.add(PendingReminder(
          key: 'review:$dayKey',
          title: 'Daily Task Review',
          body: 'You have $activeCount open task${activeCount == 1 ? '' : 's'} to review.',
        ));
      }
    }

    return reminders;
  }

  Future<void> evaluateAndNotify(List<TaskItem> tasks, UserProfile profile, {DateTime? now}) async {
    final pending = computePendingReminders(tasks, profile, now: now);
    for (final item in pending) {
      if (_firedKeys.contains(item.key)) continue;
      _firedKeys.add(item.key);
      await _deliver(item);
    }
  }

  Future<void> notifyTaskGiven(TaskGivenAlert alert, UserProfile profile) async {
    if (!profile.notificationsEnabled) return;
    final key = 'given:${alert.taskId}';
    if (_firedKeys.contains(key)) return;
    _firedKeys.add(key);
    await _deliver(PendingReminder(
      key: key,
      title: 'New task from ${alert.giverName}',
      body: alert.title,
      isUrgent: true,
    ));
  }

  Future<void> sendTestNotification() async {
    await _deliver(PendingReminder(
      key: 'test:${DateTime.now().millisecondsSinceEpoch}',
      title: 'Tasker notifications active',
      body: 'Reminders will arrive on your configured schedule.',
    ));
  }

  Future<void> _deliver(PendingReminder reminder) async {
    if (!_inAppController.isClosed) {
      _inAppController.add(reminder);
    }
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    if (!_initialized) return;
    try {
      await _plugin.show(
        id: reminder.key.hashCode & 0x7FFFFFFF,
        title: reminder.title,
        body: reminder.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasker_reminders',
            'Task Reminders',
            channelDescription: 'Upcoming deadlines, daily reviews, and assigned tasks',
            importance: Importance.high,
            priority: Priority.high,
          ),
          windows: WindowsNotificationDetails(),
          web: WebNotificationDetails(),
        ),
      );
    } catch (e) {
      // Web throws if browser notification permission hasn't been granted yet; in-app banner still displays.
      debugPrint('OS notification skipped: $e');
    }
  }

  void dispose() {
    _inAppController.close();
  }
}
