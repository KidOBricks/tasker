import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_sync/domain/models/category_item.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/ui/theme/app_theme.dart';

class TaskItemTile extends StatefulWidget {
  final TaskItem task;
  final List<CategoryItem> categories;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleInProgress;
  final Function(String subtaskId)? onToggleSubtask;
  final VoidCallback? onMarkIgnored;
  final VoidCallback? onDelete;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.categories,
    required this.onTap,
    required this.onToggleComplete,
    required this.onToggleInProgress,
    this.onToggleSubtask,
    this.onMarkIgnored,
    this.onDelete,
  });

  @override
  State<TaskItemTile> createState() => _TaskItemTileState();
}

class _TaskItemTileState extends State<TaskItemTile> {
  bool _subtasksExpanded = false;

  TaskItem get task => widget.task;

  Color _getPriorityColor() {
    if (task.isOverdue) return AppColors.overdue;
    if (task.effectiveImportance >= 3) return AppColors.level3;
    if (task.effectiveImportance == 2) return AppColors.level2;
    return AppColors.level1;
  }

  void _handleComplete(BuildContext context) {
    widget.onToggleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final isInProgress = task.isInProgress;

    final borderColor = isInProgress
        ? AppColors.inProgress.withValues(alpha: 0.45)
        : (task.isOverdue ? AppColors.overdue.withValues(alpha: 0.35) : AppColors.border);

    final category = widget.categories.firstWhere(
      (c) => c.id == task.categoryId,
      orElse: () => const CategoryItem(id: 'all', name: 'General', colorValue: 0xFF7D7870),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.surfaceLight,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 8px status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isInProgress ? AppColors.inProgress : priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Center: title + quiet metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.isRecurring) ...[
                            const SizedBox(width: 8),
                            const Tooltip(
                              message: 'Recurring task',
                              child: Icon(Icons.repeat, size: 14, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(category.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (task.dueDate != null)
                            Text(
                              _formatDueDate(task.dueDate!, task.isOverdue),
                              style: AppTheme.mono(
                                12,
                                color: task.isOverdue ? AppColors.overdue : AppColors.textMuted,
                                weight: task.isOverdue ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                          if (task.attachmentPaths.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_file, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Text(
                                  '${task.attachmentPaths.length}',
                                  style: AppTheme.mono(12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          if (task.givenByName != null && task.givenByName!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'From ${task.givenByName}',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          if (task.hasSubtasks)
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => setState(() => _subtasksExpanded = !_subtasksExpanded),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.checklist, size: 13, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.completedSubtaskCount}/${task.subtasks.length}',
                                      style: AppTheme.mono(11, color: AppColors.textSecondary),
                                    ),
                                    Icon(
                                      _subtasksExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Actions: in progress toggle, complete checkbox, overflow menu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: isInProgress ? 'Unmark in progress' : 'Mark in progress',
                      onPressed: widget.onToggleInProgress,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: isInProgress
                            ? AppColors.inProgress.withValues(alpha: 0.16)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isInProgress ? AppColors.inProgress.withValues(alpha: 0.5) : AppColors.border,
                          ),
                        ),
                      ),
                      icon: Icon(
                        isInProgress ? Icons.play_arrow : Icons.play_arrow_outlined,
                        size: 16,
                        color: isInProgress ? AppColors.inProgress : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => _handleComplete(context),
                      activeColor: AppColors.inProgress,
                      checkColor: AppColors.actionFg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Task options',
                      icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.textMuted),
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.borderStrong),
                      ),
                      onSelected: (val) {
                        switch (val) {
                          case 'edit':
                            widget.onTap();
                            break;
                          case 'in_progress':
                            widget.onToggleInProgress();
                            break;
                          case 'ignore':
                            widget.onMarkIgnored?.call();
                            break;
                          case 'delete':
                            widget.onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Text('Edit task', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'in_progress',
                          child: Row(
                            children: [
                              Icon(
                                isInProgress ? Icons.pause : Icons.play_arrow_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInProgress ? 'Unmark in progress' : 'Mark in progress',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'ignore',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_off_outlined, size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Text('Ignore task', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 16, color: AppColors.overdue),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.overdue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                  ],
                ),
                if (_subtasksExpanded && task.hasSubtasks) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 6),
                  ...task.subtasks.map((sub) => InkWell(
                        onTap: () => widget.onToggleSubtask?.call(sub.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: sub.isCompleted,
                                  onChanged: (_) => widget.onToggleSubtask?.call(sub.id),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: sub.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                                    decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              Text(
                                'L${sub.baseImportance}',
                                style: AppTheme.mono(10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date, bool isOverdue) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    final timeStr = DateFormat('h:mm a').format(date);

    if (dueDay.isAtSameMomentAs(today)) {
      return isOverdue ? 'Overdue $timeStr' : 'Today $timeStr';
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow $timeStr';
    }

    if (dueDay.difference(today).inDays.abs() < 7) {
      final weekday = DateFormat('EEE').format(date);
      return '$weekday $timeStr';
    }

    return DateFormat('MMM d, h:mm a').format(date);
  }
}
