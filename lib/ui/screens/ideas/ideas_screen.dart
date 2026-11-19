import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/task_item.dart';
import '../../../services/gemini_service.dart';
import '../../../state/app_state.dart';
import '../../../state/integration_state.dart';
import '../../theme/app_theme.dart';
import '../home/widgets/add_edit_task_dialog.dart';

class IdeasScreen extends ConsumerWidget {
  const IdeasScreen({super.key});

  void _acceptSuggestion(BuildContext context, WidgetRef ref, ExtractedTaskSuggestion suggestion) {
    final maxLevels = ref.read(profileProvider).numImportanceLevels;
    ref.read(tasksProvider.notifier).addTask(
          title: suggestion.title,
          description: suggestion.description,
          categoryId: suggestion.categoryId,
          baseImportance: suggestion.importance.clamp(1, maxLevels),
          dueDate: suggestion.suggestedDueDate,
          emailRef: {
            if (suggestion.emailId != null) 'emailId': suggestion.emailId,
            'subject': suggestion.emailSubject,
            'sender': suggestion.emailSender,
          },
        );

    ref.read(ideasProvider.notifier).acceptSuggestion(suggestion);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "${suggestion.title}"')),
    );
  }

  void _editAndAccept(BuildContext context, WidgetRef ref, ExtractedTaskSuggestion suggestion) {
    final categories = ref.read(categoriesProvider);
    final profile = ref.read(profileProvider);
    final draftTask = TaskItem(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.uid,
      title: suggestion.title,
      description: suggestion.description,
      categoryId: categories.any((c) => c.id == suggestion.categoryId)
          ? suggestion.categoryId
          : (categories.isNotEmpty ? categories.first.id : 'all'),
      baseImportance: suggestion.importance.clamp(1, profile.numImportanceLevels),
      effectiveImportance: suggestion.importance.clamp(1, profile.numImportanceLevels),
      dueDate: suggestion.suggestedDueDate,
      createdAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AddEditTaskDialog(
        existingTask: draftTask,
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
          recurrenceRule,
          subtasks = const [],
        }) {
          ref.read(tasksProvider.notifier).addTask(
                title: title,
                description: description,
                categoryId: categoryId,
                baseImportance: baseImportance,
                dueDate: dueDate,
                attachmentPaths: attachmentPaths,
                recurrenceRule: recurrenceRule,
                subtasks: subtasks,
                emailRef: {
                  if (suggestion.emailId != null) 'emailId': suggestion.emailId,
                  'subject': suggestion.emailSubject,
                  'sender': suggestion.emailSender,
                },
              );
          ref.read(ideasProvider.notifier).acceptSuggestion(suggestion);
        },
      ),
    );
  }

  Future<void> _connectGmail(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(connectedAccountsProvider.notifier).connectProvider('google');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete Google sign-in in your browser, then scan inbox'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _scanInbox(BuildContext context, WidgetRef ref) async {
    try {
      final count = await ref.read(ideasProvider.notifier).scanInbox();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned inbox: $count item${count == 1 ? "" : "s"} pending'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inbox scan failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(ideasProvider);
    final accounts = ref.watch(connectedAccountsProvider);
    final isGmailConnected = accounts.isGmailConnected || accounts.google != null;
    final isWide = MediaQuery.of(context).size.width >= 840;
    final pad = isWide ? 24.0 : 16.0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          Row(
            children: [
              const Text(
                'Inbox Ideas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: isGmailConnected
                    ? () => _scanInbox(context, ref)
                    : () => _connectGmail(context, ref),
                icon: Icon(
                  isGmailConnected ? Icons.refresh : Icons.link,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                label: Text(isGmailConnected ? 'Scan inbox' : 'Connect Gmail'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Connection status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isGmailConnected ? AppColors.inProgress : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGmailConnected
                              ? 'Gmail connected (${accounts.google?.email.isNotEmpty == true ? accounts.google!.email : "Active"})'
                              : 'Gmail disconnected',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGmailConnected
                              ? 'Scans unread messages for deadlines and suggested tasks'
                              : 'Connect your Google account to extract tasks from unread mail',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (suggestions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 32, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    isGmailConnected
                        ? 'No pending email task suggestions'
                        : 'Connect Gmail to turn unread emails into tasks',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: isGmailConnected
                        ? () => _scanInbox(context, ref)
                        : () => _connectGmail(context, ref),
                    child: Text(isGmailConnected ? 'Scan inbox' : 'Connect Gmail'),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'Suggested tasks (${suggestions.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${suggestion.importance}',
                              style: AppTheme.mono(12, color: AppColors.primary, weight: FontWeight.w500),
                            ),
                            if (suggestion.suggestedDueDate != null)
                              Text(
                                'Due ${DateFormat('MMM d, h:mm a').format(suggestion.suggestedDueDate!.toLocal())}',
                                style: AppTheme.mono(12, color: AppColors.level2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          suggestion.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (suggestion.emailSubject.isNotEmpty || suggestion.emailSender.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${suggestion.emailSender} • ${suggestion.emailSubject}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          suggestion.description.isNotEmpty ? suggestion.description : suggestion.emailSnippet,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => ref.read(ideasProvider.notifier).dismissSuggestion(suggestion),
                              child: const Text('Dismiss'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _editAndAccept(context, ref, suggestion),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _acceptSuggestion(context, ref, suggestion),
                              child: const Text('Add task'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
