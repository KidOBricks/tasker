import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  void _showConnectGmailDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController(text: 'user@gmail.com');
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text('Connect Gmail for Inbox AI'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authorize Tasker to scan incoming unread emails for actionable tasks, deadlines, and commitments.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Google / Gmail Address',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'OAuth 2.0 Bearer Token (Optional)',
                hintText: 'Leave empty for simulated cloud connection',
                prefixIcon: Icon(Icons.key_outlined, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              final email = emailController.text.trim();
              final token = tokenController.text.trim().isNotEmpty ? tokenController.text.trim() : null;
              if (email.isNotEmpty) {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(connectedAccountsProvider.notifier).connectGoogle(email: email, accessToken: token);
                if (ctx.mounted) nav.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('Connected Gmail account: $email! Scanning inbox...')),
                );
                if (context.mounted) {
                  _scanInbox(context, ref);
                }
              }
            },
            child: const Text('Connect Gmail'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanInbox(BuildContext context, WidgetRef ref) async {
    final emailService = ref.read(emailIntegrationServiceProvider);
    final emails = await emailService.fetchRecentEmails();
    final suggestions = emailService.extractTaskSuggestions(emails);

    for (final s in suggestions) {
      ref.read(ideasProvider.notifier).addSuggestion(s);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanned Gmail inbox: found ${suggestions.length} actionable items!'),
          backgroundColor: AppColors.inProgress,
        ),
      );
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
            onPressed: () => _scanInbox(context, ref),
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
                Row(
                  children: [
                    Icon(
                      Icons.mark_email_read,
                      color: isGmailConnected ? Colors.redAccent : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGmailConnected
                              ? 'Gmail Inbox AI Active (${accounts.google?.email ?? "Connected"})'
                              : 'Gmail Inbox AI Disconnected',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          isGmailConnected ? 'Auto-extracting deadlines from incoming messages' : 'Connect account to parse incoming emails for tasks',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGmailConnected ? AppColors.surface : Colors.redAccent,
                    foregroundColor: isGmailConnected ? AppColors.textSecondary : Colors.white,
                    side: isGmailConnected ? const BorderSide(color: AppColors.border) : null,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isGmailConnected ? () => _scanInbox(context, ref) : () => _showConnectGmailDialog(context, ref),
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
                    const Text('All email task suggestions have been reviewed!', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Scan Inbox for New Tasks'),
                      onPressed: () => _scanInbox(context, ref),
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
                                  'Due ${DateFormat('MMM d, h:mm a').format(suggestion.suggestedDueDate!)}',
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
                      const SizedBox(height: 6),
                      Text(
                        suggestion.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => ref.read(ideasProvider.notifier).removeSuggestion(suggestion),
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
