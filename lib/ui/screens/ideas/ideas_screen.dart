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
    ref.read(tasksProvider.notifier).addTask(
          title: suggestion.title,
          description: suggestion.description,
          categoryId: suggestion.categoryId,
          baseImportance: suggestion.importance,
          dueDate: suggestion.suggestedDueDate,
          emailRef: {
            if (suggestion.emailId != null) 'emailId': suggestion.emailId,
            'subject': suggestion.emailSubject,
            'sender': suggestion.emailSender,
          },
        );

    ref.read(ideasProvider.notifier).acceptSuggestion(suggestion);

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
        }) {
          ref.read(tasksProvider.notifier).addTask(
                title: title,
                description: description,
                categoryId: categoryId,
                baseImportance: baseImportance,
                dueDate: dueDate,
                attachmentPaths: attachmentPaths,
                recurrenceRule: recurrenceRule,
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
            content: Text('Complete Google authorization in your browser, then tap Scan Inbox.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.overdue,
          ),
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
            content: Text('Scanned Gmail inbox: $count actionable item${count == 1 ? "" : "s"} pending.'),
            backgroundColor: AppColors.inProgress,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inbox scan failed: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.overdue,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas & Email Inbox AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Scan Gmail Inbox',
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: isGmailConnected ? () => _scanInbox(context, ref) : () => _connectGmail(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gmail Connection Status Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.mark_email_read,
                        color: isGmailConnected ? Colors.redAccent : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGmailConnected
                                  ? 'Gmail Inbox AI Active (${accounts.google?.email.isNotEmpty == true ? accounts.google!.email : "Connected"})'
                                  : 'Gmail Inbox AI Disconnected',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isGmailConnected
                                  ? 'Server-side AI extracts deadlines from unread messages'
                                  : 'Connect Google account to parse unread emails for tasks',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGmailConnected ? AppColors.surface : Colors.redAccent,
                    foregroundColor: isGmailConnected ? AppColors.textSecondary : Colors.white,
                    side: isGmailConnected ? const BorderSide(color: AppColors.border) : null,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isGmailConnected ? () => _scanInbox(context, ref) : () => _connectGmail(context, ref),
                  child: Text(isGmailConnected ? 'Scan Inbox' : 'Connect Gmail'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Suggestions list
          if (suggestions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      isGmailConnected
                          ? 'No pending email task suggestions.'
                          : 'Connect your Gmail account to extract tasks from unread emails.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: Icon(isGmailConnected ? Icons.refresh : Icons.link, size: 16),
                      label: Text(isGmailConnected ? 'Scan Inbox for New Tasks' : 'Connect Gmail Account'),
                      onPressed: isGmailConnected ? () => _scanInbox(context, ref) : () => _connectGmail(context, ref),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            const Text('Actionable Tasks Detected in Email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Level ${suggestion.importance} (Priority)',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (suggestion.suggestedDueDate != null)
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 13, color: AppColors.level2),
                                const SizedBox(width: 4),
                                Text(
                                  'Due ${DateFormat('MMM d, h:mm a').format(suggestion.suggestedDueDate!.toLocal())}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.level2, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        suggestion.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      if (suggestion.emailSubject.isNotEmpty || suggestion.emailSender.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'From: ${suggestion.emailSender}  •  ${suggestion.emailSubject}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        suggestion.description.isNotEmpty ? suggestion.description : suggestion.emailSnippet,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => ref.read(ideasProvider.notifier).dismissSuggestion(suggestion),
                            child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _editAndAccept(context, ref, suggestion),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Edit Details', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Accept & Add', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _acceptSuggestion(context, ref, suggestion),
                          ),
                        ],
                      ),
                    ],
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

