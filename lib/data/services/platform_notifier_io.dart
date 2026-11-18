import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _androidChannel = MethodChannel('tasker/notifications');

Future<bool> requestPlatformNotificationPermission() async {
  if (Platform.isAndroid) {
    try {
      final res = await _androidChannel.invokeMethod<bool>('requestPermission');
      return res == true;
    } catch (_) {
      return false;
    }
  }
  return true;
}

Future<void> showPlatformNotification({
  required int id,
  required String title,
  required String body,
}) async {
  if (Platform.isAndroid) {
    try {
      await _androidChannel.invokeMethod<void>('show', {
        'id': id,
        'title': title,
        'body': body,
      });
    } catch (_) {}
    return;
  }
  if (Platform.isWindows) {
    // Pass text via env vars and XML-escape inside PowerShell to prevent injection.
    const psScript = r'''
$t = [System.Security.SecurityElement]::Escape($env:TASKER_TOAST_TITLE)
$b = [System.Security.SecurityElement]::Escape($env:TASKER_TOAST_BODY)
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$xml = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::new()
$xml.LoadXml("<toast><visual><binding template='ToastGeneric'><text>$t</text><text>$b</text></binding></visual></toast>")
$toast = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::new($xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('KidOBricks.Tasker.Desktop').Show($toast)
''';
    try {
      final res = await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-Command', psScript],
        environment: {
          'TASKER_TOAST_TITLE': title,
          'TASKER_TOAST_BODY': body,
        },
      );
      if (res.exitCode != 0) {
        debugPrint('Windows toast error (${res.exitCode}): ${res.stderr}');
      }
    } catch (e) {
      debugPrint('Windows toast exception: $e');
    }
  }
}

Future<void> syncPlatformNotificationSchedule({
  required List<Map<String, dynamic>> alarms,
  required List<String> knownTaskIds,
  required bool enabled,
  required String userId,
  required String serverUrl,
}) async {
  if (!Platform.isAndroid) return;
  try {
    await _androidChannel.invokeMethod<void>('syncSchedule', {
      'alarms': alarms,
      'knownTaskIds': knownTaskIds,
      'enabled': enabled,
      'userId': userId,
      'serverUrl': serverUrl,
    });
  } catch (_) {}
}

Future<void> clearPlatformNotificationSchedule() async {
  if (!Platform.isAndroid) return;
  try {
    await _androidChannel.invokeMethod<void>('clearSchedule');
  } catch (_) {}
}
