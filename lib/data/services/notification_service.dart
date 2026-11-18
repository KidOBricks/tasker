import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/user_profile.dart';
import 'database_service.dart';
import 'platform_notifier_io.dart'
    if (dart.library.js_interop) 'platform_notifier_web.dart';

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

class ScheduledAlarm {
  final int id;
  final DateTime triggerAt;
  final String title;
  final String body;

  const ScheduledAlarm({
    required this.id,
    required this.triggerAt,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'triggerAtMs': triggerAt.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      };
}

class NotificationService {
  final StreamController<PendingReminder> _inAppController = StreamController<PendingReminder>.broadcast();
  final Set<String> _firedKeys = {};
  bool _initialized = false;

  Stream<PendingReminder> get inAppAlerts => _inAppController.stream;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    return requestPlatformNotificationPermission();
  }

  Future<bool> checkBackgroundUnrestricted() => isBackgroundUnrestricted();

  Future<void> requestBackgroundExemption() => requestPlatformBackgroundExemption();

  static bool _shouldNotifyTask(TaskItem task, UserProfile profile) {
    if (task.isCompleted || task.isIgnored) return false;
    if (profile.isChoreFrozenInVacation(task.recurrenceRuleId)) return false;
    if (profile.notifyForTier == 'urgent_only' && task.effectiveImportance < 3) return false;
    if (profile.notifyForTier == 'in_progress_only' && !task.isInProgress) return false;
    return true;
  }

  /// Computes future local alarm triggers so Android AlarmManager fires when the app is closed.
  static List<ScheduledAlarm> computeScheduledAlarms(
    List<TaskItem> tasks,
    UserProfile profile, {
    DateTime? now,
    int maxAlarms = 40,
  }) {
    if (!profile.notificationsEnabled) return const [];
    final current = now ?? DateTime.now();
    final lead = Duration(minutes: profile.notifyPriorMinutes.clamp(0, 60 * 24 * 14));
    final alarms = <ScheduledAlarm>[];

    for (final task in tasks) {
      if (!_shouldNotifyTask(task, profile)) continue;
      final due = task.dueDate;
      if (due == null) continue;

      final upcomingAt = due.subtract(lead);
      if (upcomingAt.isAfter(current)) {
        final leadMins = lead.inMinutes;
        final body = leadMins <= 1 ? 'Due now' : 'Due in $leadMins min';
        alarms.add(ScheduledAlarm(
          id: ('alarm:due:${task.id}:${due.toIso8601String()}:$leadMins').hashCode & 0x7FFFFFFF,
          triggerAt: upcomingAt,
          title: 'Upcoming: ${task.title}',
          body: body,
        ));
      }

      if (profile.notifyForOverdue && due.isAfter(current)) {
        alarms.add(ScheduledAlarm(
          id: ('alarm:overdue:${task.id}:${due.toIso8601String()}').hashCode & 0x7FFFFFFF,
          triggerAt: due,
          title: 'Overdue: ${task.title}',
          body: 'Past due since ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}',
        ));
      }
    }

    if (profile.reviewTasksEnabled) {
      final parts = profile.reviewTasksTime.split(':');
      final hh = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
      final mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      var reviewAt = DateTime(current.year, current.month, current.day, hh, mm);
      if (!reviewAt.isAfter(current)) {
        reviewAt = reviewAt.add(const Duration(days: 1));
      }
      final activeCount = tasks.where((t) => !t.isCompleted && !t.isIgnored).length;
      alarms.add(ScheduledAlarm(
        id: 'alarm:review'.hashCode & 0x7FFFFFFF,
        triggerAt: reviewAt,
        title: 'Daily Task Review',
        body: 'You have $activeCount open task${activeCount == 1 ? '' : 's'} to review.',
      ));
    }

    alarms.sort((a, b) => a.triggerAt.compareTo(b.triggerAt));
    return alarms.length > maxAlarms ? alarms.sublist(0, maxAlarms) : alarms;
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
      if (!_shouldNotifyTask(task, profile)) continue;

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

  Future<void> syncBackgroundSchedule({
    required List<TaskItem> tasks,
    required UserProfile profile,
    required String userId,
    required String serverUrl,
  }) async {
    if (!_initialized) await initialize();
    final alarms = computeScheduledAlarms(tasks, profile);
    final knownIds = tasks.map((t) => t.id).toList();
    await syncPlatformNotificationSchedule(
      alarms: alarms.map((a) => a.toMap()).toList(),
      knownTaskIds: knownIds,
      enabled: profile.notificationsEnabled && userId.isNotEmpty,
      userId: userId,
      serverUrl: serverUrl,
    );
  }

  Future<void> clearBackgroundSchedule() => clearPlatformNotificationSchedule();

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
    await showPlatformNotification(
      id: reminder.key.hashCode & 0x7FFFFFFF,
      title: reminder.title,
      body: reminder.body,
    );
  }

  void dispose() {
    _inAppController.close();
  }
}
