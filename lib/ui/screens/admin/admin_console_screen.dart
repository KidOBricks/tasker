import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/user_account.dart';
import '../../../state/auth_state.dart';
import '../../theme/app_theme.dart';

class AdminConsoleScreen extends ConsumerStatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  ConsumerState<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends ConsumerState<AdminConsoleScreen> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  void _confirmRoleChange(BuildContext context, UserAccount user) {
    final newRole = user.role == UserRole.admin ? UserRole.user : UserRole.admin;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Role to ${newRole.displayName}?'),
        content: Text('Are you sure you want to change permissions for "${user.displayName}" (${user.email}) to ${newRole.displayName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(adminUsersProvider.notifier).updateUserRole(user.id, newRole);
              if (ctx.mounted) nav.pop();
              messenger.showSnackBar(
                SnackBar(content: Text('Updated "${user.displayName}" to ${newRole.displayName}!')),
              );
            },
            child: const Text('Confirm Role Change'),
          ),
        ],
      ),
    );
  }

  void _confirmToggleStatus(BuildContext context, UserAccount user) {
    final willSuspend = user.isActive;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willSuspend ? 'Suspend Account?' : 'Reactivate Account?'),
        content: Text(
          willSuspend
              ? 'Suspending "${user.displayName}" will revoke their login access and pause real-time cloud synchronization.'
              : 'Reactivating will immediately restore account access.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willSuspend ? AppColors.overdue : AppColors.inProgress,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(adminUsersProvider.notifier).toggleUserStatus(user.id);
              if (ctx.mounted) nav.pop();
              messenger.showSnackBar(
                SnackBar(content: Text(willSuspend ? 'Account suspended.' : 'Account reactivated.')),
              );
            },
            child: Text(willSuspend ? 'Suspend' : 'Reactivate'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User Account?'),
        content: Text('Permanently remove "${user.displayName}" (${user.email}) from the database? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.overdue, foregroundColor: Colors.white),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
                if (ctx.mounted) nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('User account permanently deleted.')),
                );
              } catch (e) {
                if (ctx.mounted) nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                );
              }
            },
            child: const Text('Delete User'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerCloudSync() async {
    final db = ref.read(databaseServiceProvider);
    await db.performCloudSync();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud synchronization forced! Database state is fresh across all devices.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider);
    final currentUser = ref.watch(authProvider);
    final db = ref.watch(databaseServiceProvider);

    // Compute metrics
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.isActive).length;
    final adminCount = users.where((u) => u.isAdmin).length;
    final totalTasks = users.fold<int>(0, (sum, u) => sum + u.taskCount);

    // Filter users
    final filteredUsers = users.where((u) {
      final matchesQuery = u.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRoleFilter == 'all' ||
          (_selectedRoleFilter == 'admin' && u.isAdmin) ||
          (_selectedRoleFilter == 'user' && !u.isAdmin);
      return matchesQuery && matchesRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.cloud_sync, size: 16),
            label: const Text('Force Cloud Sync'),
            onPressed: _triggerCloudSync,
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Cloud Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cloud Sync Status: Active & Realtime',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Database: Firebase Multi-Tenant Architecture • Last sync: ${DateFormat("h:mm:ss a").format(db.lastSyncTime)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inProgress.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('HEALTHY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.inProgress)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // KPI Cards Row
          Row(
            children: [
              _buildKpiCard('Total Users', '$totalUsers', Icons.people, AppColors.primary),
              const SizedBox(width: 12),
              _buildKpiCard('Active Now', '$activeUsers', Icons.check_circle, AppColors.inProgress),
              const SizedBox(width: 12),
              _buildKpiCard('Admins', '$adminCount', Icons.shield, AppColors.level2),
              const SizedBox(width: 12),
              _buildKpiCard('Synced Tasks', '$totalTasks', Icons.task_alt, const Color(0xFF06B6D4)),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter Header
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Registered Users Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search Input
                  SizedBox(
                    width: 180,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search user...',
                        prefixIcon: const Icon(Icons.search, size: 16),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  // Role Filter Dropdown
                  DropdownButton<String>(
                    value: _selectedRoleFilter,
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Roles')),
                      DropdownMenuItem(value: 'admin', child: Text('Admins')),
                      DropdownMenuItem(value: 'user', child: Text('Users')),
                    ],
                    onChanged: (val) => setState(() => _selectedRoleFilter = val ?? 'all'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Cards Directory List
          if (filteredUsers.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No users found matching search criteria.', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            ...filteredUsers.map((user) {
              final isSelf = user.id == currentUser?.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: user.isAdmin ? AppColors.primary : const Color(0xFF64748B),
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                if (isSelf) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('You', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                // Role Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user.isAdmin ? AppColors.primary : const Color(0xFF64748B)).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: user.isAdmin ? AppColors.primary : const Color(0xFF64748B), width: 0.8),
                                  ),
                                  child: Text(
                                    user.role.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: user.isAdmin ? AppColors.primary : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user.isActive ? AppColors.inProgress : AppColors.overdue).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.isActive ? 'Active' : 'Suspended',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: user.isActive ? AppColors.inProgress : AppColors.overdue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 12,
                              children: [
                                Text(
                                  'Joined: ${DateFormat("MMM d, yyyy").format(user.createdAt)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Text(
                                  'Last Active: ${DateFormat("MMM d, h:mm a").format(user.lastLoginAt)}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Text(
                                  'Tasks: ${user.taskCount}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Admin Action Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle Role Button
                          Tooltip(
                            message: user.isAdmin ? 'Demote to standard user' : 'Promote to administrator',
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              icon: Icon(user.isAdmin ? Icons.person : Icons.admin_panel_settings, size: 14),
                              label: Text(user.isAdmin ? 'Make User' : 'Make Admin', style: const TextStyle(fontSize: 11)),
                              onPressed: () => _confirmRoleChange(context, user),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Toggle Status (Suspend / Reactivate)
                          Tooltip(
                            message: user.isActive ? 'Suspend account' : 'Reactivate account',
                            child: IconButton(
                              icon: Icon(
                                user.isActive ? Icons.block : Icons.check_circle_outline,
                                color: user.isActive ? AppColors.overdue : AppColors.inProgress,
                                size: 18,
                              ),
                              onPressed: () => _confirmToggleStatus(context, user),
                            ),
                          ),

                          // Delete User Button
                          if (!isSelf)
                            Tooltip(
                              message: 'Delete user account',
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.overdue, size: 18),
                                onPressed: () => _confirmDeleteUser(context, user),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, size: 15, color: color),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
