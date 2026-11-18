import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<bool> requestPlatformNotificationPermission() async {
  try {
    if (web.Notification.permission == 'granted') return true;
    if (web.Notification.permission == 'denied') return false;
    final res = await web.Notification.requestPermission().toDart;
    return res.toDart == 'granted';
  } catch (_) {
    return false;
  }
}

Future<void> showPlatformNotification({
  required int id,
  required String title,
  required String body,
}) async {
  try {
    if (web.Notification.permission != 'granted') return;
    web.Notification(title, web.NotificationOptions(body: body, tag: 'tasker-$id'));
  } catch (_) {}
}

Future<bool> isBackgroundUnrestricted() async => true;

Future<void> requestPlatformBackgroundExemption() async {}

Future<void> syncPlatformNotificationSchedule({
  required List<Map<String, dynamic>> alarms,
  required List<String> knownTaskIds,
  required bool enabled,
  required String userId,
  required String serverUrl,
}) async {}

Future<void> clearPlatformNotificationSchedule() async {}
