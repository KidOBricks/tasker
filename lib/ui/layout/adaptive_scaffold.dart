import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/ideas/ideas_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../../state/app_state.dart';

class AdaptiveScaffold extends ConsumerStatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  ConsumerState<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends ConsumerState<AdaptiveScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    ProgressScreen(),
    IdeasScreen(),
    SettingsScreen(),
  ];

  void _navigateToSettings() {
    setState(() => _selectedIndex = 4);
  }

  @override
  Widget build(BuildContext context) {
    final sectioned = ref.watch(sectionedTasksProvider);
    final profile = ref.watch(profileProvider);
    final overdueCount = sectioned.overdueTasks.length;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      // Desktop Multi-Pane Layout (Windows & Linux)
      return Scaffold(
        body: Row(
          children: [
            // Left Navigation Rail
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    // User Profile Avatar & Name (Clicking launches Settings/Profile)
                    Tooltip(
                      message: 'Click to open Profile & Settings',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _navigateToSettings,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 4
                                ? AppColors.primary.withValues(alpha: 0.25)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedIndex == 4 ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  profile.displayName.isNotEmpty ? profile.displayName[0] : 'A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  profile.displayName.split(' ').first,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.border, indent: 12, endIndent: 12),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: overdueCount > 0,
                    label: Text('$overdueCount'),
                    backgroundColor: AppColors.overdue,
                    child: const Icon(Icons.task_alt),
                  ),
                  selectedIcon: const Icon(Icons.task_alt, color: AppColors.primary),
                  label: const Text('Tasks'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
                  label: Text('Calendar'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
                  label: Text('Progress'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.lightbulb_outline),
                  selectedIcon: Icon(Icons.lightbulb, color: AppColors.primary),
                  label: Text('Ideas'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: AppColors.primary),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.border),

            // Main Active Screen Content
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    }

    // Mobile Portrait Layout (Android)
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sync_alt, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Tasker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          // User Avatar on Mobile Top Bar (Clicking launches Profile/Settings)
          Tooltip(
            message: 'Profile & Settings',
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _navigateToSettings,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        profile.displayName.isNotEmpty ? profile.displayName[0] : 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile.displayName.split(' ').first,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: overdueCount > 0,
              label: Text('$overdueCount'),
              backgroundColor: AppColors.overdue,
              child: const Icon(Icons.task_alt),
            ),
            label: 'Tasks',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
            label: 'Calendar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
            label: 'Progress',
          ),
          const NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb, color: AppColors.primary),
            label: 'Ideas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
