import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/task_item.dart';
import '../../../domain/models/category_item.dart';
import '../../../domain/models/recurrence_rule.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/celebration_confetti.dart';
import 'widgets/task_item_tile.dart';
import 'widgets/add_edit_task_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Expansion states for accordions
  bool _overdueExpanded = true;
  bool _inProgressExpanded = true;
  final Map<int, bool> _levelExpansionMap = {};

  bool _isLevelExpanded(int level) {
    return _levelExpansionMap[level] ?? true;
  }

  void _toggleLevelExpanded(int level) {
    setState(() {
      _levelExpansionMap[level] = !_isLevelExpanded(level);
    });
  }

  void _openAddEditDialog({TaskItem? task}) {
    final categories = ref.read(categoriesProvider);
    final profile = ref.read(profileProvider);

    showDialog(
      context: context,
      builder: (ctx) => AddEditTaskDialog(
        existingTask: task,
        categories: categories,
        numImportanceLevels: profile.numImportanceLevels,
        customLevelNames: profile.levelNames,
        onSave: ({
          required String title,
          String? description,
          required String categoryId,
          required int baseImportance,
          DateTime? dueDate,
          List<String> attachmentPaths = const [],
          RecurrenceRule? recurrenceRule,
        }) {
          if (task == null) {
            ref.read(tasksProvider.notifier).addTask(
                  title: title,
                  description: description,
                  categoryId: categoryId,
                  baseImportance: baseImportance,
                  dueDate: dueDate,
                  attachmentPaths: attachmentPaths,
                  recurrenceRule: recurrenceRule,
                );
          } else {
            ref.read(tasksProvider.notifier).updateTask(
                  task.copyWith(
                    title: title,
                    description: description,
                    categoryId: categoryId,
                    baseImportance: baseImportance,
                    dueDate: dueDate,
                    clearDueDate: dueDate == null,
                    attachmentPaths: attachmentPaths,
                  ),
                );
          }
        },
        onMarkDone: (id) => ref.read(tasksProvider.notifier).markCompleted(id),
        onMarkInProgress: (id) => _toggleInProgressWithGuard(id),
        onMarkIgnored: (id) => ref.read(tasksProvider.notifier).markIgnored(id),
        onDelete: (id) => ref.read(tasksProvider.notifier).deleteTask(id),
      ),
    );
  }

  Future<void> _toggleInProgressWithGuard(String taskId) async {
    final success = await ref.read(tasksProvider.notifier).toggleInProgress(taskId);
    if (!success && mounted) {
      final profile = ref.read(profileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum in-progress task limit reached (${profile.maxInProgressTasks}). Complete or unmark an active task first.',
          ),
          backgroundColor: AppColors.level2,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final liveHistory = ref.watch(taskHistoryProvider);
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.history, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Task Activity & Undo'),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 450),
              child: liveHistory.isEmpty
                  ? const Center(
                      child: Text('No recent task activities yet.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: liveHistory.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, idx) {
                        final item = liveHistory[idx];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: _buildHistoryIcon(item.action),
                          title: Text(item.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            DateFormat('h:mm a • MMM d').format(item.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          trailing: TextButton.icon(
                            icon: const Icon(Icons.undo, size: 14),
                            label: const Text('Undo', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              ref.read(tasksProvider.notifier).undoHistoryAction(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Action undone successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryIcon(String action) {
    IconData icon;
    Color color;

    switch (action) {
      case 'completed':
        icon = Icons.check_circle;
        color = AppColors.inProgress;
        break;
      case 'in_progress':
        icon = Icons.play_circle;
        color = AppColors.inProgress;
        break;
      case 'ignored':
        icon = Icons.visibility_off;
        color = AppColors.textMuted;
        break;
      case 'deleted':
        icon = Icons.delete;
        color = AppColors.overdue;
        break;
      case 'created':
        icon = Icons.add_circle;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.edit;
        color = AppColors.level2;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _promptCreateCategory() {
    final textController = TextEditingController();
    int selectedColor = 0xFF8B5CF6; // Purple

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Fitness, Reading, Finance',
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose Color', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  0xFF8B5CF6, // Purple
                  0xFFEC4899, // Pink
                  0xFF14B8A6, // Teal
                  0xFFF97316, // Orange
                  0xFF06B6D4, // Cyan
                ].map((colorVal) {
                  final isSelected = selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = colorVal),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(categoriesProvider.notifier).addCategory(name, selectedColor, 'folder');
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 3) return AppColors.level3;
    if (level == 2) return AppColors.level2;
    return AppColors.level1;
  }

  IconData _getLevelIcon(int level) {
    if (level >= 3) return Icons.priority_high;
    if (level == 2) return Icons.drag_handle;
    return Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final activeCat = ref.watch(activeCategoryTabProvider);
    final sectioned = ref.watch(sectionedTasksProvider);
    final profile = ref.watch(profileProvider);
    final history = ref.watch(taskHistoryProvider);

    return CelebrationConfettiOverlay(
      child: Scaffold(
        body: Column(
          children: [
            // Top Category Tabs Bar + History/Undo Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...categories.map((cat) {
                            final isSelected = activeCat == cat.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Color(cat.colorValue),
                                ),
                                label: Text(cat.name),
                                selected: isSelected,
                                onSelected: (_) => ref.read(activeCategoryTabProvider.notifier).setCategory(cat.id),
                                selectedColor: Color(cat.colorValue).withValues(alpha: 0.22),
                                backgroundColor: AppColors.background,
                                side: BorderSide(
                                  color: isSelected ? Color(cat.colorValue) : AppColors.border,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Color(cat.colorValue) : AppColors.textSecondary,
                                ),
                              ),
                            );
                          }),
                          // + New Category Button
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
                            label: const Text('New Category'),
                            onPressed: _promptCreateCategory,
                            backgroundColor: AppColors.background,
                            side: const BorderSide(color: AppColors.border, style: BorderStyle.solid),
                            labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // History / Undo Quick Launcher
                  IconButton(
                    tooltip: 'Task History & Undo (${history.length} actions)',
                    icon: Badge(
                      isLabelVisible: history.isNotEmpty,
                      label: Text('${history.length}'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                    ),
                    onPressed: _showHistoryDialog,
                  ),
                ],
              ),
            ),

            // Vacation Mode Banner (if active)
            if (profile.vacationModeEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.beach_access, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vacation Mode Active • ${profile.vacationFrozenChoreIds.length} recurring chores frozen',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const Text('Enjoy your break!', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),

            // Main Screen: Accordion Sections (Overdue, In Progress, Level N ... Level 1)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 90, top: 10),
                children: [
                  // 1. Overdue Section (Right at the top)
                  if (sectioned.overdueTasks.isNotEmpty)
                    _buildAccordionSection(
                      title: 'Overdue',
                      count: sectioned.overdueTasks.length,
                      accentColor: AppColors.overdue,
                      icon: Icons.error_outline,
                      isExpanded: _overdueExpanded,
                      onToggle: () => setState(() => _overdueExpanded = !_overdueExpanded),
                      tasks: sectioned.overdueTasks,
                      categories: categories,
                    ),

                  // 2. In Progress Section (Below overdue)
                  if (sectioned.inProgressTasks.isNotEmpty)
                    _buildAccordionSection(
                      title: 'In Progress',
                      count: sectioned.inProgressTasks.length,
                      accentColor: AppColors.inProgress,
                      icon: Icons.play_circle_outline,
                      isExpanded: _inProgressExpanded,
                      onToggle: () => setState(() => _inProgressExpanded = !_inProgressExpanded),
                      tasks: sectioned.inProgressTasks,
                      categories: categories,
                    ),

                  // 3. Dynamic Importance Levels (Level N down to Level 1)
                  for (int lvl = profile.numImportanceLevels; lvl >= 1; lvl--) ...[
                    Builder(
                      builder: (ctx) {
                        final tasksForLevel = sectioned.levelTasks[lvl] ?? const [];
                        final levelTitle = profile.getLevelName(lvl);
                        final accentColor = _getLevelColor(lvl);
                        final icon = _getLevelIcon(lvl);
                        final isExpanded = _isLevelExpanded(lvl);

                        return _buildAccordionSection(
                          title: levelTitle,
                          count: tasksForLevel.length,
                          accentColor: accentColor,
                          icon: icon,
                          isExpanded: isExpanded,
                          onToggle: () => _toggleLevelExpanded(lvl),
                          tasks: tasksForLevel,
                          categories: categories,
                        );
                      },
                    ),
                  ],

                  // Empty State if no tasks match
                  if (sectioned.overdueTasks.isEmpty &&
                      sectioned.inProgressTasks.isEmpty &&
                      sectioned.levelTasks.values.every((l) => l.isEmpty))
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('No active tasks in this category', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Bottom Right (+) Button to Add New Tasks
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddEditDialog(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required int count,
    required Color accentColor,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<TaskItem> tasks,
    required List<CategoryItem> categories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accordion Header Bar
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),

        // Accordion Dropdown Content
        if (isExpanded)
          tasks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(
                    'No tasks in this section',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted.withValues(alpha: 0.6)),
                  ),
                )
              : Column(
                  children: tasks.map((task) {
                    return TaskItemTile(
                      task: task,
                      categories: categories,
                      onTap: () => _openAddEditDialog(task: task),
                      onToggleComplete: () => ref.read(tasksProvider.notifier).markCompleted(task.id),
                      onToggleInProgress: () => _toggleInProgressWithGuard(task.id),
                      onMarkIgnored: () => ref.read(tasksProvider.notifier).markIgnored(task.id),
                      onDelete: () => ref.read(tasksProvider.notifier).deleteTask(task.id),
                    );
                  }).toList(),
                ),

        const SizedBox(height: 6),
      ],
    );
  }
}
