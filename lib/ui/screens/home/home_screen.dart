import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/category_item.dart';
import '../../../domain/models/recurrence_rule.dart';
import '../../../domain/models/task_item.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/celebration_confetti.dart';
import 'widgets/add_edit_task_dialog.dart';
import 'widgets/task_item_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _overdueExpanded = true;
  bool _inProgressExpanded = true;
  final Map<int, bool> _levelExpansionMap = {};

  bool _isLevelExpanded(int level) => _levelExpansionMap[level] ?? true;

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
            'Active task limit reached (${profile.maxInProgressTasks}). Finish or pause an active task first.',
          ),
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
                Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text('Task activity & undo'),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 440),
              child: liveHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'No recent task activity',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: liveHistory.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, idx) {
                        final item = liveHistory[idx];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: _buildHistoryIcon(item.action),
                          title: Text(
                            item.description,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            DateFormat('h:mm a • MMM d').format(item.timestamp),
                            style: AppTheme.mono(11, color: AppColors.textMuted),
                          ),
                          trailing: TextButton.icon(
                            icon: const Icon(Icons.undo, size: 14),
                            label: const Text('Undo', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              ref.read(tasksProvider.notifier).undoHistoryAction(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Action reverted'),
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
        icon = Icons.check_circle_outline;
        color = AppColors.inProgress;
        break;
      case 'in_progress':
        icon = Icons.play_circle_outline;
        color = AppColors.inProgress;
        break;
      case 'ignored':
        icon = Icons.visibility_off_outlined;
        color = AppColors.textMuted;
        break;
      case 'deleted':
        icon = Icons.delete_outline;
        color = AppColors.overdue;
        break;
      case 'created':
        icon = Icons.add_circle_outline;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.edit_outlined;
        color = AppColors.level2;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _promptCreateCategory() {
    final textController = TextEditingController();
    int selectedColor = 0xFF3CA89C;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  hintText: 'Fitness, Reading, Finance',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Marker color',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  0xFF3CA89C, // Mineral teal
                  0xFF3EB489, // Sage emerald
                  0xFFE09F3E, // Warm amber
                  0xFF5E94D4, // Slate cobalt
                  0xFFD97757, // Terracotta
                ].map((colorVal) {
                  final isSelected = selectedColor == colorVal;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setDialogState(() => selectedColor = colorVal),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.textPrimary, width: 2)
                            : Border.all(color: AppColors.border),
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
    final isWide = MediaQuery.of(context).size.width >= 840;
    final pagePad = isWide ? 24.0 : 16.0;

    return CelebrationConfettiOverlay(
      child: Scaffold(
        body: Column(
          children: [
            // Page header + category bar
            Container(
              padding: EdgeInsets.fromLTRB(pagePad, isWide ? 20 : 12, pagePad, 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _showHistoryDialog,
                        icon: const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
                        label: Text(
                          history.isNotEmpty ? 'History (${history.length})' : 'History',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...categories.map((cat) {
                          final isSelected = activeCat == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => ref.read(activeCategoryTabProvider.notifier).setCategory(cat.id),
                              child: AnimatedContainer(
                                duration: AppTheme.fastDuration,
                                curve: AppTheme.motionCurve,
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.borderStrong : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Color(cat.colorValue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _promptCreateCategory,
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: AppColors.textSecondary),
                                SizedBox(width: 6),
                                Text(
                                  'New category',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Vacation banner
            if (profile.vacationModeEnabled)
              Container(
                padding: EdgeInsets.symmetric(horizontal: pagePad, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.beach_access_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vacation mode active — ${profile.vacationFrozenChoreIds.length} recurring routines paused',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Accordions list
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(pagePad, 16, pagePad, 96),
                children: [
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

                  for (int lvl = profile.numImportanceLevels; lvl >= 1; lvl--)
                    _buildAccordionSection(
                      title: profile.getLevelName(lvl),
                      count: (sectioned.levelTasks[lvl] ?? const []).length,
                      accentColor: _getLevelColor(lvl),
                      icon: _getLevelIcon(lvl),
                      isExpanded: _isLevelExpanded(lvl),
                      onToggle: () => _toggleLevelExpanded(lvl),
                      tasks: sectioned.levelTasks[lvl] ?? const [],
                      categories: categories,
                    ),

                  if (sectioned.overdueTasks.isEmpty &&
                      sectioned.inProgressTasks.isEmpty &&
                      sectioned.levelTasks.values.every((l) => l.isEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 32, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No active tasks in this category',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _openAddEditDialog(),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add task'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddEditDialog(),
          backgroundColor: AppColors.actionBg,
          foregroundColor: AppColors.actionFg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Task',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: AppTheme.mono(12, color: AppColors.textMuted),
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
          if (isExpanded)
            tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      'No tasks in this section',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
        ],
      ),
    );
  }
}
