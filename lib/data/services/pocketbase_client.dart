import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'server_config.dart';

class PocketBaseClientFactory {
  static const authStorageKey = 'pb_auth_v1';

  static PocketBase create(
    SharedPreferences prefs,
    ServerConfig config, {
    http.Client Function()? httpClientFactory,
  }) {
    final store = AsyncAuthStore(
      initial: prefs.getString(authStorageKey),
      save: (String data) async {
        await prefs.setString(authStorageKey, data);
      },
      clear: () async {
        await prefs.remove(authStorageKey);
      },
    );

    return PocketBase(
      config.serverUrl,
      authStore: store,
      httpClientFactory: httpClientFactory,
    );
  }
}
