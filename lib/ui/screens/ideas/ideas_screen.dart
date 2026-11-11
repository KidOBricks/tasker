import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../state/app_state.dart';
import '../../../services/gemini_service.dart';
import '../../theme/app_theme.dart';
import '../home/widgets/add_edit_task_dialog.dart';

class IdeasScreen extends ConsumerWidget {
  const IdeasScreen({super.key});

  void _acceptSuggestion(BuildContext context, WidgetRef ref, ExtractedTaskSuggestion suggestion) {
    ref.read(tasksProvider.notifier).addTask(
          title: suggestion.title,
          description: suggestion.description,
          categoryId: suggestion.categoryId,
          baseImportance: suggestion.importance,
          dueDate: suggestion.suggestedDueDate,
        );

    ref.read(ideasProvider.notifier).removeSuggestion(suggestion);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${suggestion.title}" to your tasks!'),
        backgroundColor: AppColors.inProgress,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editAndAccept(BuildContext context, WidgetRef ref, ExtractedTaskSuggestion suggestion) {
    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (ctx) => AddEditTaskDialog(
        categories: categories,
        onSave: ({
          required String title,
          String? description,
          required String categoryId,
          required int baseImportance,
          DateTime? dueDate,
          List<String> attachmentPaths = const [],
          recurrenceRule,
        }) {
          ref.read(tasksProvider.notifier).addTask(
                title: title,
                description: description,
                categoryId: categoryId,
                baseImportance: baseImportance,
                dueDate: dueDate,
                attachmentPaths: attachmentPaths,
                recurrenceRule: recurrenceRule,
              );
          ref.read(ideasProvider.notifier).removeSuggestion(suggestion);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(ideasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas & Email Inbox AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.mark_email_read, size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Text('Gmail AI Active', style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
      body: suggestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('All email task suggestions have been reviewed!', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                final s = suggestions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source Email Reference
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'From: ${s.emailSender}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (s.importance >= 3 ? AppColors.level3 : AppColors.level2).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Level ${s.importance}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: s.importance >= 3 ? AppColors.level3 : AppColors.level2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Suggested Task Title
                        Text(
                          s.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),

                        // Source Email Snippet
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '"${s.emailSnippet}"',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Suggested Due Date
                        if (s.suggestedDueDate != null)
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 13, color: AppColors.level2),
                              const SizedBox(width: 4),
                              Text(
                                'Suggested Deadline: ${DateFormat('EEE, MMM d, yyyy').format(s.suggestedDueDate!)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.level2, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        const SizedBox(height: 14),

                        // Action Buttons: Dismiss, Edit Details, Accept
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => ref.read(ideasProvider.notifier).removeSuggestion(s),
                              child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _editAndAccept(context, ref, s),
                              child: const Text('Edit Details'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Accept & Add'),
                              onPressed: () => _acceptSuggestion(context, ref, s),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
