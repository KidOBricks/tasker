import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/user_account.dart';

class AuthService {
  final SharedPreferences _prefs;
  static const _usersKey = 'tasker_user_accounts';
  static const _sessionKey = 'tasker_current_user_id';
  static const _uuid = Uuid();

  UserAccount? _currentUser;

  AuthService(this._prefs) {
    _initUsersAndSession();
  }

  UserAccount? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _initUsersAndSession() {
    // Seed initial demo users if not present
    if (!_prefs.containsKey(_usersKey)) {
      final now = DateTime.now();
      final initialUsers = [
        UserAccount(
          id: 'user_admin_1',
          email: 'admin@tasker.io',
          displayName: 'Alex Morgan',
          role: UserRole.admin,
          isActive: true,
          createdAt: now.subtract(const Duration(days: 90)),
          lastLoginAt: now,
          taskCount: 14,
        ),
        UserAccount(
          id: 'user_2',
          email: 'sarah.chen@university.edu',
          displayName: 'Sarah Chen',
          role: UserRole.user,
          isActive: true,
          createdAt: now.subtract(const Duration(days: 45)),
          lastLoginAt: now.subtract(const Duration(days: 1)),
          taskCount: 8,
        ),
        UserAccount(
          id: 'user_3',
          email: 'marcus.vance@acme-corp.com',
          displayName: 'Marcus Vance',
          role: UserRole.user,
          isActive: true,
          createdAt: now.subtract(const Duration(days: 20)),
          lastLoginAt: now.subtract(const Duration(days: 3)),
          taskCount: 5,
        ),
      ];
      _saveUsersList(initialUsers);
    }

    // Restore active session
    final savedUserId = _prefs.getString(_sessionKey);
    final allUsers = getAllUsers();
    if (savedUserId != null) {
      _currentUser = allUsers.firstWhere(
        (u) => u.id == savedUserId,
        orElse: () => allUsers.first,
      );
    } else {
      // Default initial session is Alex Morgan (Admin)
      _currentUser = allUsers.first;
      _prefs.setString(_sessionKey, _currentUser!.id);
    }
  }

  List<UserAccount> getAllUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((item) => UserAccount.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveUsersList(List<UserAccount> users) async {
    final raw = json.encode(users.map((u) => u.toMap()).toList());
    await _prefs.setString(_usersKey, raw);
  }

  Future<UserAccount> signIn(String email, String password) async {
    final all = getAllUsers();
    final user = all.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw Exception('User not found with email "$email"'),
    );

    if (!user.isActive) {
      throw Exception('Account has been suspended by an administrator.');
    }

    final updated = user.copyWith(lastLoginAt: DateTime.now());
    await _updateUserInList(updated);
    _currentUser = updated;
    await _prefs.setString(_sessionKey, updated.id);
    return updated;
  }

  Future<UserAccount> signUp(String email, String password, String displayName) async {
    final all = getAllUsers();
    final existing = all.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (existing) {
      throw Exception('An account with this email address already exists.');
    }

    final now = DateTime.now();
    final newUser = UserAccount(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      email: email.trim(),
      displayName: displayName.trim().isNotEmpty ? displayName.trim() : email.split('@').first,
      role: all.isEmpty ? UserRole.admin : UserRole.user, // first user is admin
      isActive: true,
      createdAt: now,
      lastLoginAt: now,
      taskCount: 0,
    );

    final updatedList = [...all, newUser];
    await _saveUsersList(updatedList);
    _currentUser = newUser;
    await _prefs.setString(_sessionKey, newUser.id);
    return newUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(_sessionKey);
  }

  Future<void> sendPasswordReset(String email) async {
    final all = getAllUsers();
    final exists = all.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (!exists) {
      throw Exception('No account found for email "$email"');
    }
    // Simulation: in production, calls FirebaseAuth.instance.sendPasswordResetEmail(email)
  }

  // --- Admin User Management Methods ---

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    final all = getAllUsers();
    final user = all.firstWhere((u) => u.id == userId);
    final updated = user.copyWith(role: newRole);
    await _updateUserInList(updated);
    if (_currentUser?.id == userId) {
      _currentUser = updated;
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    final all = getAllUsers();
    final user = all.firstWhere((u) => u.id == userId);
    final updated = user.copyWith(isActive: !user.isActive);
    await _updateUserInList(updated);
    if (_currentUser?.id == userId) {
      _currentUser = updated;
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_currentUser?.id == userId) {
      throw Exception('Cannot delete your own active administrator account.');
    }
    final all = getAllUsers();
    final updated = all.where((u) => u.id != userId).toList();
    await _saveUsersList(updated);
  }

  Future<void> _updateUserInList(UserAccount updatedUser) async {
    final all = getAllUsers();
    final list = all.map((u) => u.id == updatedUser.id ? updatedUser : u).toList();
    await _saveUsersList(list);
  }
}
