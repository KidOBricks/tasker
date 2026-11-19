import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/notification_service.dart';
import '../../state/app_state.dart';
import '../../state/auth_state.dart';
import '../../state/integration_state.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ideas/ideas_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/celebration_confetti.dart';

class AdaptiveScaffold extends ConsumerStatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  ConsumerState<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends ConsumerState<AdaptiveScaffold> {
  int _selectedIndex = 0;
  final GlobalKey<CelebrationConfettiOverlayState> _confettiKey = GlobalKey();
  Timer? _reminderTimer;
  Timer? _initialCheckTimer;
  Timer? _scheduleSyncDebounce;
  bool _androidPermPrompted = false;
  StreamSubscription<TaskGivenAlert>? _givenSub;
  StreamSubscription<PendingReminder>? _alertSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNotificationWatchers());
  }

  void _startNotificationWatchers() {
    final notif = ref.read(notificationServiceProvider);
    final dbSvc = ref.read(databaseServiceProvider);

    _givenSub = dbSvc.taskGivenStream.listen((alert) {
      final profile = ref.read(profileProvider);
      notif.notifyTaskGiven(alert, profile);
    });

    _alertSub = notif.inAppAlerts.listen((alert) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 84),
          backgroundColor: alert.isUrgent ? AppColors.surface : AppColors.surfaceLight,
          content: Row(
            children: [
              Icon(
                alert.isUrgent ? Icons.notifications_active : Icons.notifications_outlined,
                size: 18,
                color: alert.isUrgent ? AppColors.level3 : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${alert.title} — ${alert.body}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });

    _initialCheckTimer = Timer(const Duration(seconds: 5), () {
      _maybePromptNativePermission();
      _evaluateNow();
      _syncNativeSchedule();
    });
    _reminderTimer = Timer.periodic(const Duration(seconds: 60), (_) => _evaluateNow());
  }

  void _maybePromptNativePermission() {
    if (_androidPermPrompted || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (ref.read(authProvider) == null || !ref.read(profileProvider).notificationsEnabled) return;
    _androidPermPrompted = true;
    unawaited(ref.read(notificationServiceProvider).requestPermissions());
  }

  void _syncNativeSchedule() {
    _scheduleSyncDebounce?.cancel();
    _scheduleSyncDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final user = ref.read(authProvider);
      final notif = ref.read(notificationServiceProvider);
      if (user == null) {
        unawaited(notif.clearBackgroundSchedule());
        return;
      }
      final tasks = ref.read(tasksProvider);
      final profile = ref.read(profileProvider);
      final serverUrl = ref.read(databaseServiceProvider).serverUrl;
      unawaited(notif.syncBackgroundSchedule(
        tasks: tasks,
        profile: profile,
        userId: user.id,
        serverUrl: serverUrl,
      ));
    });
  }

  void _evaluateNow() {
    if (!mounted || ref.read(authProvider) == null) return;
    final tasks = ref.read(tasksProvider);
    final profile = ref.read(profileProvider);
    ref.read(notificationServiceProvider).evaluateAndNotify(tasks, profile);
  }

  @override
  void dispose() {
    _initialCheckTimer?.cancel();
    _reminderTimer?.cancel();
    _scheduleSyncDebounce?.cancel();
    _givenSub?.cancel();
    _alertSub?.cancel();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text(
          'Your local SQLite cache stays on this device until your next sign-in',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.overdue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  static Color _syncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return AppColors.inProgress;
      case SyncStatus.syncing:
        return AppColors.primary;
      case SyncStatus.offline:
      case SyncStatus.error:
        return AppColors.overdue;
    }
  }

  static Widget _buildSyncBadge(SyncStatus status) {
    final isWarning = status == SyncStatus.offline || status == SyncStatus.error;
    final color = _syncColor(status);
    final label = status == SyncStatus.offline ? 'Offline — Not Syncing' : status.displayName;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWarning)
          Icon(Icons.error_outline, size: 13, color: color)
        else
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono(
              11,
              color: isWarning ? AppColors.overdue : AppColors.textMuted,
              weight: isWarning ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      if (next == null) {
        unawaited(ref.read(notificationServiceProvider).clearBackgroundSchedule());
      } else {
        _maybePromptNativePermission();
        _syncNativeSchedule();
      }
    });
    ref.listen(tasksProvider, (_, _) => _syncNativeSchedule());
    ref.listen(profileProvider, (_, _) => _syncNativeSchedule());

    if (currentUser == null) {
      return const AuthScreen();
    }

    ref.listen<int>(celebrationTriggerProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        _confettiKey.currentState?.trigger();
        final today = DateTime.now();
        final doneToday = ref.read(tasksProvider).where((t) {
          final c = t.completedAt;
          return t.isCompleted &&
              c != null &&
              c.year == today.year &&
              c.month == today.month &&
              c.day == today.day;
        }).length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.celebration, size: 18, color: AppColors.inProgress),
                const SizedBox(width: 10),
                Text('Nice! $doneToday task${doneToday == 1 ? '' : 's'} completed today'),
              ],
            ),
          ),
        );
      }
    });

    final sectioned = ref.watch(sectionedTasksProvider);
    final syncStatus = ref.watch(syncStatusProvider).value ?? SyncStatus.offline;
    final overdueCount = sectioned.overdueTasks.length;
    final isDesktop = MediaQuery.of(context).size.width >= 840;

    const screens = [
      HomeScreen(),
      CalendarScreen(),
      ProgressScreen(),
      IdeasScreen(),
      SettingsScreen(),
    ];

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    final Widget shell = isDesktop
        ? Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: AppColors.sidebar,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Workspace header + live sync dot signature
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const TaskerMark(size: 24),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Tasker',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSyncBadge(syncStatus),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(),
                  ),
                  const SizedBox(height: 12),

                  // Primary navigation items (36px rows, 4px vertical gap)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _SidebarItem(
                          icon: Icons.task_alt,
                          label: 'Tasks',
                          selected: _selectedIndex == 0,
                          trailingCount: overdueCount > 0 ? overdueCount : null,
                          trailingColor: AppColors.overdue,
                          onTap: () => _navigateTo(0),
                        ),
                        const SizedBox(height: 4),
                        _SidebarItem(
                          icon: Icons.calendar_month_outlined,
                          label: 'Calendar',
                          selected: _selectedIndex == 1,
                          onTap: () => _navigateTo(1),
                        ),
                        const SizedBox(height: 4),
                        _SidebarItem(
                          icon: Icons.bar_chart_outlined,
                          label: 'Progress',
                          selected: _selectedIndex == 2,
                          onTap: () => _navigateTo(2),
                        ),
                        const SizedBox(height: 4),
                        _SidebarItem(
                          icon: Icons.lightbulb_outline,
                          label: 'Ideas',
                          selected: _selectedIndex == 3,
                          onTap: () => _navigateTo(3),
                        ),
                        const SizedBox(height: 4),
                        _SidebarItem(
                          icon: Icons.settings_outlined,
                          label: 'Profile',
                          selected: _selectedIndex == 4,
                          onTap: () => _navigateTo(4),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // User footer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _navigateTo(4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.surfaceLight,
                                  child: Text(
                                    currentUser.displayName.isNotEmpty
                                        ? currentUser.displayName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        currentUser.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Sign out',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.logout, size: 16, color: AppColors.textMuted),
                          onPressed: () => _confirmSignOut(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: screens[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        title: const Row(
          children: [
            TaskerMark(size: 24),
            SizedBox(width: 8),
            Text(
              'Tasker',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: _buildSyncBadge(syncStatus),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => _navigateTo(4),
            icon: CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.surfaceLight,
              child: Text(
                currentUser.displayName.isNotEmpty
                    ? currentUser.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout, size: 16, color: AppColors.textMuted),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigateTo,
          backgroundColor: AppColors.sidebar,
          indicatorColor: AppColors.surfaceLight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: overdueCount > 0,
                offset: const Offset(10, -6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                label: Text(
                  '$overdueCount',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                backgroundColor: AppColors.overdue,
                child: const Icon(Icons.task_alt, size: 18),
              ),
              selectedIcon: Badge(
                isLabelVisible: overdueCount > 0,
                offset: const Offset(10, -6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                label: Text(
                  '$overdueCount',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                backgroundColor: AppColors.overdue,
                child: const Icon(Icons.task_alt, size: 18, color: AppColors.primary),
              ),
              label: 'Tasks',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, size: 18),
              selectedIcon: Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
              label: 'Calendar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, size: 18),
              selectedIcon: Icon(Icons.bar_chart, size: 18, color: AppColors.primary),
              label: 'Progress',
            ),
            const NavigationDestination(
              icon: Icon(Icons.lightbulb_outline, size: 18),
              selectedIcon: Icon(Icons.lightbulb, size: 18, color: AppColors.primary),
              label: 'Ideas',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 18),
              selectedIcon: Icon(Icons.settings, size: 18, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );

    return CelebrationConfettiOverlay(
      key: _confettiKey,
      child: shell,
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? trailingCount;
  final Color? trailingColor;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.trailingCount,
    this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceLight : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.surface,
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: AppColors.border) : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Icon(
                  icon,
                  size: 16,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
              if (trailingCount != null)
                Text(
                  '$trailingCount',
                  style: AppTheme.mono(
                    12,
                    color: trailingColor ?? AppColors.textMuted,
                    weight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
