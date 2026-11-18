import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _androidChannel = MethodChannel('tasker/notifications');
const _windowsAppId = 'KidOBricks.Tasker.Desktop';

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
$xml.LoadXml("<toast scenario='reminder'><visual><binding template='ToastGeneric'><text>$t</text><text>$b</text></binding></visual></toast>")
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

Future<bool> isBackgroundUnrestricted() async {
  if (Platform.isAndroid) {
    try {
      final res = await _androidChannel.invokeMethod<bool>('isBackgroundUnrestricted');
      return res == true;
    } catch (_) {
      return false;
    }
  }
  return true;
}

Future<void> requestPlatformBackgroundExemption() async {
  if (!Platform.isAndroid) return;
  try {
    await _androidChannel.invokeMethod<void>('requestBackgroundExemption');
  } catch (_) {}
}

Future<void> syncPlatformNotificationSchedule({
  required List<Map<String, dynamic>> alarms,
  required List<String> knownTaskIds,
  required bool enabled,
  required String userId,
  required String serverUrl,
}) async {
  if (Platform.isAndroid) {
    try {
      await _androidChannel.invokeMethod<void>('syncSchedule', {
        'alarms': alarms,
        'knownTaskIds': knownTaskIds,
        'enabled': enabled,
        'userId': userId,
        'serverUrl': serverUrl,
      });
    } catch (_) {}
    return;
  }
  if (Platform.isWindows) {
    await _syncWindowsScheduledToasts(alarms: alarms, enabled: enabled);
  }
}

Future<void> clearPlatformNotificationSchedule() async {
  if (Platform.isAndroid) {
    try {
      await _androidChannel.invokeMethod<void>('clearSchedule');
    } catch (_) {}
    return;
  }
  if (Platform.isWindows) {
    await _syncWindowsScheduledToasts(alarms: const [], enabled: false);
  }
}

Future<void> _syncWindowsScheduledToasts({
  required List<Map<String, dynamic>> alarms,
  required bool enabled,
}) async {
  const psScript = r'''
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($env:TASKER_APP_ID)
foreach ($existing in @($notifier.GetScheduledToastNotifications())) {
  if ($existing.Id -like 'tasker_*') {
    $notifier.RemoveFromSchedule($existing)
  }
}
if ($env:TASKER_ALARMS_ENABLED -eq '1' -and $env:TASKER_ALARMS_JSON) {
  $items = $env:TASKER_ALARMS_JSON | ConvertFrom-Json
  $now = [DateTimeOffset]::UtcNow
  foreach ($item in $items) {
    $due = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.triggerAtMs)
    if ($due -le $now.AddSeconds(2)) { continue }
    $t = [System.Security.SecurityElement]::Escape([string]$item.title)
    $b = [System.Security.SecurityElement]::Escape([string]$item.body)
    $xml = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::new()
    $xml.LoadXml("<toast scenario='reminder'><visual><binding template='ToastGeneric'><text>$t</text><text>$b</text></binding></visual></toast>")
    $st = [Windows.UI.Notifications.ScheduledToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::new($xml, $due)
    $rawId = "tasker_$($item.id)"
    if ($rawId.Length -gt 16) { $rawId = $rawId.Substring(0, 16) }
    $st.Id = $rawId
    $notifier.AddToSchedule($st)
  }
}
''';
  try {
    final res = await Process.run(
      'powershell',
      ['-NoProfile', '-NonInteractive', '-Command', psScript],
      environment: {
        'TASKER_APP_ID': _windowsAppId,
        'TASKER_ALARMS_ENABLED': enabled ? '1' : '0',
        'TASKER_ALARMS_JSON': json.encode(alarms),
      },
    );
    if (res.exitCode != 0) {
      debugPrint('Windows scheduled toast error (${res.exitCode}): ${res.stderr}');
    }
  } catch (e) {
    debugPrint('Windows scheduled toast exception: $e');
  }
}
