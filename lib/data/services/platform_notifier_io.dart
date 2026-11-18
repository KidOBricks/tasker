import 'dart:io';
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
$xml.LoadXml("<toast><visual><binding template='ToastText02'><text id='1'>$t</text><text id='2'>$b</text></binding></visual></toast>")
$toast = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::new($xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Tasker').Show($toast)
''';
    try {
      await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-Command', psScript],
        environment: {
          'TASKER_TOAST_TITLE': title,
          'TASKER_TOAST_BODY': body,
        },
      );
    } catch (_) {}
  }
}
