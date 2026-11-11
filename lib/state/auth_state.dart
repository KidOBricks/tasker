import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_account.dart';
import '../data/services/auth_service.dart';
import '../data/services/database_service.dart';

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

// --- Auth State ---
class AuthNotifier extends Notifier<UserAccount?> {
  @override
  UserAccount? build() {
    return ref.watch(authServiceProvider).currentUser;
  }

  Future<void> signIn(String email, String password) async {
    final user = await ref.read(authServiceProvider).signIn(email, password);
    state = user;
    await ref.read(databaseServiceProvider).performCloudSync(userId: user.id);
  }

  Future<void> signUp(String email, String password, String displayName) async {
    final user = await ref.read(authServiceProvider).signUp(email, password, displayName);
    state = user;
    await ref.read(databaseServiceProvider).performCloudSync(userId: user.id);
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = null;
  }

  Future<void> switchUser(UserAccount user) async {
    await signIn(user.email, 'password');
  }

  Future<void> sendPasswordReset(String email) async {
    await ref.read(authServiceProvider).sendPasswordReset(email);
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserAccount?>(AuthNotifier.new);

// --- Admin Users Directory State ---
class AdminUsersNotifier extends Notifier<List<UserAccount>> {
  @override
  List<UserAccount> build() {
    return ref.watch(authServiceProvider).getAllUsers();
  }

  Future<void> refresh() async {
    state = ref.read(authServiceProvider).getAllUsers();
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await ref.read(authServiceProvider).updateUserRole(userId, newRole);
    state = ref.read(authServiceProvider).getAllUsers();
  }

  Future<void> toggleUserStatus(String userId) async {
    await ref.read(authServiceProvider).toggleUserStatus(userId);
    state = ref.read(authServiceProvider).getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await ref.read(authServiceProvider).deleteUser(userId);
    state = ref.read(authServiceProvider).getAllUsers();
  }
}

final adminUsersProvider =
    NotifierProvider<AdminUsersNotifier, List<UserAccount>>(AdminUsersNotifier.new);
