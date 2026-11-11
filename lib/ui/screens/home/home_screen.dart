import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/task_item.dart';
import '../../../domain/models/category_item.dart';
import '../../../domain/models/recurrence_rule.dart';
import '../../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/task_item_tile.dart';
import 'widgets/add_edit_task_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Expansion states for the 5 accordions
  bool _overdueExpanded = true;
  bool _inProgressExpanded = true;
  bool _level3Expanded = true;
  bool _level2Expanded = true;
  bool _level1Expanded = true;

  void _openAddEditDialog({TaskItem? task}) {
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (ctx) => AddEditTaskDialog(
        existingTask: task,
        categories: categories,
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

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final activeCat = ref.watch(activeCategoryTabProvider);
    final sectioned = ref.watch(sectionedTasksProvider);

    return Scaffold(
      body: Column(
        children: [
          // Top Category Tabs Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
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

          // Main Screen: 5 Accordion Sections
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

                // 3. Level 3 (Urgent)
                _buildAccordionSection(
                  title: 'Level 3 - Urgent',
                  count: sectioned.level3Tasks.length,
                  accentColor: AppColors.level3,
                  icon: Icons.priority_high,
                  isExpanded: _level3Expanded,
                  onToggle: () => setState(() => _level3Expanded = !_level3Expanded),
                  tasks: sectioned.level3Tasks,
                  categories: categories,
                ),

                // 4. Level 2 (Medium)
                _buildAccordionSection(
                  title: 'Level 2 - Medium',
                  count: sectioned.level2Tasks.length,
                  accentColor: AppColors.level2,
                  icon: Icons.drag_handle,
                  isExpanded: _level2Expanded,
                  onToggle: () => setState(() => _level2Expanded = !_level2Expanded),
                  tasks: sectioned.level2Tasks,
                  categories: categories,
                ),

                // 5. Level 1 (Low)
                _buildAccordionSection(
                  title: 'Level 1 - Low Priority',
                  count: sectioned.level1Tasks.length,
                  accentColor: AppColors.level1,
                  icon: Icons.arrow_downward,
                  isExpanded: _level1Expanded,
                  onToggle: () => setState(() => _level1Expanded = !_level1Expanded),
                  tasks: sectioned.level1Tasks,
                  categories: categories,
                ),

                // Empty State if no tasks match
                if (sectioned.overdueTasks.isEmpty &&
                    sectioned.inProgressTasks.isEmpty &&
                    sectioned.level3Tasks.isEmpty &&
                    sectioned.level2Tasks.isEmpty &&
                    sectioned.level1Tasks.isEmpty)
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
                    );
                  }).toList(),
                ),

        const SizedBox(height: 6),
      ],
    );
  }
}
