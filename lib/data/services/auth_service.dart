import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/user_account.dart';
import 'server_config.dart';

class AuthService {
  final PocketBase _pb;
  final ServerConfig _serverConfig;

  AuthService(this._pb, this._serverConfig);

  PocketBase get pb => _pb;
  String get serverUrl => _pb.baseURL;

  bool get isAuthenticated => _pb.authStore.isValid && currentUser != null;

  UserAccount? get currentUser {
    final record = _pb.authStore.record;
    if (record == null || !_pb.authStore.isValid) return null;
    if (record.get<bool>('suspended', false)) return null;
    return _recordToUser(record);
  }

  Future<void> setServerUrl(String url) async {
    await _serverConfig.setServerUrl(url);
    _pb.baseURL = _serverConfig.serverUrl;
  }

  Future<UserAccount> signIn(String email, String password) async {
    final authData = await _pb.collection('users').authWithPassword(
          email.trim(),
          password,
        );
    final user = _recordToUser(authData.record);
    if (!user.isActive) {
      await signOut();
      throw Exception('Account has been suspended by an administrator.');
    }
    return user;
  }

  Future<UserAccount> signInWithOAuth2(
    String provider, {
    Future<void> Function(Uri url)? launchCallback,
  }) async {
    final launcher = launchCallback ??
        (Uri url) async {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        };

    final authData = await _pb.collection('users').authWithOAuth2(
          provider,
          launcher,
        );
    final user = _recordToUser(authData.record);
    if (!user.isActive) {
      await signOut();
      throw Exception('Account has been suspended by an administrator.');
    }
    return user;
  }

  Future<UserAccount?> refreshSessionIfPossible() async {
    if (!_pb.authStore.isValid) return null;
    try {
      final refreshed = await _pb.collection('users').authRefresh();
      final user = _recordToUser(refreshed.record);
      if (!user.isActive) {
        await signOut();
        return null;
      }
      return user;
    } on ClientException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await signOut();
        return null;
      }
      return currentUser; // Offline or transient server error: keep cached session
    } catch (_) {
      return currentUser;
    }
  }

  Future<UserAccount> updateDisplayName(String displayName) async {
    final active = currentUser;
    if (active == null) {
      throw Exception('Not signed in.');
    }
    final updated = await _pb.collection('users').update(
      active.id,
      body: {'displayName': displayName.trim()},
    );
    _pb.authStore.save(_pb.authStore.token, updated);
    return _recordToUser(updated);
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
  }

  static UserAccount _recordToUser(RecordModel record) {
    final email = record.get<String>('email', '');
    final name = record.get<String>('displayName', '').trim();
    final created = DateTime.tryParse(record.get<String>('created', '')) ?? DateTime.now();
    final updated = DateTime.tryParse(record.get<String>('updated', '')) ?? DateTime.now();

    return UserAccount(
      id: record.id,
      email: email,
      displayName: name.isNotEmpty ? name : (email.contains('@') ? email.split('@').first : 'User'),
      role: UserRole.fromString(record.get<String>('role', 'user')),
      isActive: !record.get<bool>('suspended', false),
      createdAt: created,
      lastLoginAt: updated,
    );
  }
}
