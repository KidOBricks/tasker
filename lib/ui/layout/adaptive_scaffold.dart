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

  @override
  Widget build(BuildContext context) {
    final sectioned = ref.watch(sectionedTasksProvider);
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.sync_alt, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(height: 6),
                    const Text('SyncTask', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.task_alt),
                  selectedIcon: const Icon(Icons.task_alt, color: AppColors.primary),
                  label: const Text('Tasks'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month, color: AppColors.primary),
                  label: const Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart, color: AppColors.primary),
                  label: const Text('Progress'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.lightbulb_outline),
                  selectedIcon: const Icon(Icons.lightbulb, color: AppColors.primary),
                  label: const Text('Ideas'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings, color: AppColors.primary),
                  label: const Text('Settings'),
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
