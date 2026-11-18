import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const _serverUrlKey = 'tasker_server_url_v1';
  static const _envServerUrl = String.fromEnvironment('TASKER_API_URL', defaultValue: '');

  final SharedPreferences _prefs;

  ServerConfig(this._prefs);

  String get serverUrl {
    final saved = _prefs.getString(_serverUrlKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      return _normalizeUrl(saved);
    }
    if (_envServerUrl.trim().isNotEmpty) {
      return _normalizeUrl(_envServerUrl);
    }
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.startsWith('http://') || origin.startsWith('https://')) {
        return _normalizeUrl(origin);
      }
    }
    return 'http://127.0.0.1:8090';
  }

  bool get hasCustomServerUrl =>
      (_prefs.getString(_serverUrlKey)?.trim().isNotEmpty ?? false) ||
      _envServerUrl.trim().isNotEmpty;

  Future<void> setServerUrl(String url) async {
    final normalized = _normalizeUrl(url);
    if (normalized.isEmpty) {
      await _prefs.remove(_serverUrlKey);
    } else {
      await _prefs.setString(_serverUrlKey, normalized);
    }
  }

  static String _normalizeUrl(String raw) {
    var trimmed = raw.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
