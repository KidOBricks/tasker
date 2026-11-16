import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_account.dart';
import '../data/services/auth_service.dart';
import '../data/services/database_service.dart';
import 'app_state.dart';

// --- Services Providers ---
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('Initialize authServiceProvider in main()');
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('Initialize databaseServiceProvider in main()');
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.syncStatusStream;
});

final cloudDataRevisionProvider = StreamProvider<String>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.dataUpdatedStream;
});

// --- Auth State ---
class AuthNotifier extends Notifier<UserAccount?> {
  @override
  UserAccount? build() {
    return ref.watch(authServiceProvider).currentUser;
  }

  Future<void> signIn(String email, String password) async {
    final user = await ref.read(authServiceProvider).signIn(email, password);
    await _activateUserSession(user);
  }

  Future<void> signInWithOAuth2(String provider) async {
    final user = await ref.read(authServiceProvider).signInWithOAuth2(provider);
    await _activateUserSession(user);
  }

  Future<void> updateServerUrl(String url) async {
    await ref.read(authServiceProvider).setServerUrl(url);
  }

  Future<void> updateDisplayName(String displayName) async {
    final updated = await ref.read(authServiceProvider).updateDisplayName(displayName);
    state = updated;
    await ref.read(profileProvider.notifier).updateSettings(displayName: updated.displayName);
  }

  Future<void> _activateUserSession(UserAccount user) async {
    final repo = ref.read(repositoryProvider);
    await repo.loadForUser(
      user.id,
      email: user.email,
      displayName: user.displayName,
    );
    state = user;

    final dbService = ref.read(databaseServiceProvider);
    await dbService.performCloudSync(userId: user.id);
    await dbService.startRealtimeSync(user.id);
  }

  Future<void> signOut() async {
    await ref.read(databaseServiceProvider).stopRealtimeSync();
    await ref.read(authServiceProvider).signOut();
    await ref.read(repositoryProvider).loadForUser('');
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserAccount?>(AuthNotifier.new);
