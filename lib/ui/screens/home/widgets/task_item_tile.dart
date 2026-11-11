import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/domain/models/category_item.dart';
import 'package:task_calendar_sync/ui/theme/app_theme.dart';

class TaskItemTile extends StatelessWidget {
  final TaskItem task;
  final List<CategoryItem> categories;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleInProgress;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.categories,
    required this.onTap,
    required this.onToggleComplete,
    required this.onToggleInProgress,
  });

  Color _getPriorityColor() {
    if (task.isOverdue) return AppColors.overdue;
    if (task.effectiveImportance >= 3) return AppColors.level3;
    if (task.effectiveImportance == 2) return AppColors.level2;
    return AppColors.level1;
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final isInProgress = task.isInProgress;

    // Card background tint when In-Progress
    final cardBg = isInProgress
        ? AppColors.inProgress.withValues(alpha: 0.12)
        : (task.isOverdue ? AppColors.overdue.withValues(alpha: 0.08) : AppColors.surface);

    final borderColor = isInProgress
        ? AppColors.inProgress.withValues(alpha: 0.5)
        : (task.isOverdue ? AppColors.overdue.withValues(alpha: 0.4) : AppColors.border);

    final category = categories.firstWhere(
      (c) => c.id == task.categoryId,
      orElse: () => const CategoryItem(id: 'all', name: 'General', colorValue: 0xFF64748B),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isInProgress ? 1.5 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Priority Color Pip
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),

                // Center: Title, Category, Due Date, Attachments
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.isRecurring) ...[
                            const SizedBox(width: 6),
                            const Tooltip(
                              message: 'Recurring scheduled task',
                              child: Icon(Icons.repeat, size: 14, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(category.colorValue).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(category.colorValue),
                              ),
                            ),
                          ),

                          // Due Date Badge
                          if (task.dueDate != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 13,
                                  color: task.isOverdue ? AppColors.overdue : AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _formatDueDate(task.dueDate!, task.isOverdue),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.w400,
                                    color: task.isOverdue ? AppColors.overdue : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Attachment Indicator
                          if (task.attachmentPaths.isNotEmpty) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_file, size: 12, color: AppColors.textMuted),
                                Text(
                                  '${task.attachmentPaths.length}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Side Actions: "In Progress" Button + "Complete" Checkbox
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // In-Progress Button
                    IconButton(
                      tooltip: isInProgress ? 'Active In Progress (Tap to unmark)' : 'Mark as In Progress',
                      onPressed: onToggleInProgress,
                      style: IconButton.styleFrom(
                        backgroundColor: isInProgress
                            ? AppColors.inProgress.withValues(alpha: 0.25)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isInProgress ? AppColors.inProgress : AppColors.border,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        
                      ),
                      icon: Icon(
                        isInProgress ? Icons.play_arrow : Icons.play_arrow_outlined,
                        size: 18,
                        color: isInProgress ? AppColors.inProgress : AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Complete Checkbox
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onToggleComplete(),
                      activeColor: AppColors.inProgress,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
                    ),
                  ],
                ),
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
      return isOverdue ? 'Overdue Today ($timeStr)' : 'Today ($timeStr)';
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow ($timeStr)';
    }

    if (dueDay.difference(today).inDays.abs() < 7) {
      final weekday = DateFormat('EEE').format(date);
      return '$weekday ($timeStr)';
    }

    return DateFormat('MMM d, h:mm a').format(date);
  }
}
