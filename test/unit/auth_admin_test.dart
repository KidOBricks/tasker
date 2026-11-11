import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_sync/domain/models/user_account.dart';
import 'package:task_calendar_sync/data/services/auth_service.dart';
import 'package:task_calendar_sync/data/services/database_service.dart';

void main() {
  group('Auth & Admin Console Unit Tests', () {
    late SharedPreferences prefs;
    late AuthService authService;
    late DatabaseService dbService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      authService = AuthService(prefs);
      dbService = DatabaseService(prefs);
    });

    test('Initializes with default admin and demo user accounts', () {
      final allUsers = authService.getAllUsers();
      expect(allUsers.length, greaterThanOrEqualTo(3));

      final admin = allUsers.firstWhere((u) => u.isAdmin);
      expect(admin.email, 'admin@tasker.io');
      expect(admin.displayName, 'Alex Morgan');
      expect(admin.role, UserRole.admin);

      final standardUser = allUsers.firstWhere((u) => !u.isAdmin);
      expect(standardUser.role, UserRole.user);
    });

    test('Signs up a new user account with correct initial state', () async {
      final newUser = await authService.signUp('newuser@example.com', 'password123', 'Jordan Lee');
      expect(newUser.email, 'newuser@example.com');
      expect(newUser.displayName, 'Jordan Lee');
      expect(newUser.isActive, isTrue);
      expect(newUser.role, UserRole.user);

      expect(authService.currentUser?.id, newUser.id);
    });

    test('Sign in and sign out work as expected', () async {
      await authService.signOut();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);

      final user = await authService.signIn('sarah.chen@university.edu', 'password123');
      expect(user.displayName, 'Sarah Chen');
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser?.id, user.id);
    });

    test('Admin can promote user to administrator or demote', () async {
      final users = authService.getAllUsers();
      final target = users.firstWhere((u) => !u.isAdmin);

      await authService.updateUserRole(target.id, UserRole.admin);
      final updated = authService.getAllUsers().firstWhere((u) => u.id == target.id);
      expect(updated.isAdmin, isTrue);
      expect(updated.role, UserRole.admin);

      await authService.updateUserRole(target.id, UserRole.user);
      final demoted = authService.getAllUsers().firstWhere((u) => u.id == target.id);
      expect(demoted.isAdmin, isFalse);
    });

    test('Admin can suspend and reactivate user accounts', () async {
      final users = authService.getAllUsers();
      final target = users.firstWhere((u) => !u.isAdmin);

      await authService.toggleUserStatus(target.id);
      final suspended = authService.getAllUsers().firstWhere((u) => u.id == target.id);
      expect(suspended.isActive, isFalse);

      // Suspended user cannot sign in
      expect(
        () => authService.signIn(suspended.email, 'password123'),
        throwsA(isA<Exception>()),
      );

      // Reactivate
      await authService.toggleUserStatus(target.id);
      final reactivated = authService.getAllUsers().firstWhere((u) => u.id == target.id);
      expect(reactivated.isActive, isTrue);
    });

    test('DatabaseService transitions sync status and records sync time', () async {
      expect(dbService.status, SyncStatus.synced);
      final syncFuture = dbService.performCloudSync(userId: 'u1');
      await syncFuture;
      expect(dbService.status, SyncStatus.synced);
      expect(dbService.lastSyncTime, isNotNull);
    });
  });
}
