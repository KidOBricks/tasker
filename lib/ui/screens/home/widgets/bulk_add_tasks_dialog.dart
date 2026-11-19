import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_sync/data/services/calendar_integration_service.dart';
import 'package:task_calendar_sync/domain/models/category_item.dart';
import 'package:task_calendar_sync/ui/theme/app_theme.dart';

class _DraftRow {
  final TextEditingController titleController;
  String description;
  String categoryId;
  int importance;

  _DraftRow({
    required String title,
    this.description = '',
    required this.categoryId,
    required this.importance,
  }) : titleController = TextEditingController(text: title);

  void dispose() => titleController.dispose();
}

class BulkAddTasksDialog extends StatefulWidget {
  final List<CategoryItem> categories;
  final int numImportanceLevels;
  final Future<List<BulkTaskDraft>> Function(String rawText) onParseWithAi;
  final Future<void> Function(
    List<({String title, String? description, String categoryId, int baseImportance})> items,
    DateTime? sharedDueDate,
  ) onSaveBulk;

  const BulkAddTasksDialog({
    super.key,
    required this.categories,
    this.numImportanceLevels = 3,
    required this.onParseWithAi,
    required this.onSaveBulk,
  });

  /// Splits raw pasted lines/bullets cleanly offline.
  static List<BulkTaskDraft> splitLinesLocally(
    String rawText, {
    String defaultCategoryId = 'work',
    int defaultImportance = 2,
  }) {
    final lines = rawText.replaceAll('\r\n', '\n').split('\n');
    final drafts = <BulkTaskDraft>[];
    final bulletPrefix = RegExp(r'^([-*•]|\[\s*[xX ]?\s*\]|\d+[.)])\s+');
    for (final line in lines) {
      var clean = line.trim();
      while (bulletPrefix.hasMatch(clean)) {
        clean = clean.replaceFirst(bulletPrefix, '').trim();
      }
      if (clean.isEmpty) continue;
      drafts.add(BulkTaskDraft(
        title: clean,
        categoryId: defaultCategoryId,
        importance: defaultImportance,
      ));
    }
    return drafts;
  }

  @override
  State<BulkAddTasksDialog> createState() => _BulkAddTasksDialogState();
}

class _BulkAddTasksDialogState extends State<BulkAddTasksDialog> {
  final _rawController = TextEditingController();
  final List<_DraftRow> _drafts = [];
  late String _defaultCategoryId;
  int _defaultImportance = 2;
  DateTime? _sharedDueDate;
  bool _isParsing = false;
  bool _isSaving = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _defaultCategoryId = widget.categories.isNotEmpty ? widget.categories.first.id : 'all';
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _sharedDueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0);
  }

  @override
  void dispose() {
    _rawController.dispose();
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _replaceDrafts(List<BulkTaskDraft> incoming) {
    for (final d in _drafts) {
      d.dispose();
    }
    _drafts.clear();
    final validCatIds = widget.categories.map((c) => c.id).toSet();
    for (final item in incoming) {
      final cat = validCatIds.contains(item.categoryId) ? item.categoryId : _defaultCategoryId;
      _drafts.add(_DraftRow(
        title: item.title,
        description: item.description,
        categoryId: cat,
        importance: item.importance.clamp(1, widget.numImportanceLevels),
      ));
    }
  }

  void _splitLines() {
    final text = _rawController.text.trim();
    if (text.isEmpty) return;
    final parsed = BulkAddTasksDialog.splitLinesLocally(
      text,
      defaultCategoryId: _defaultCategoryId,
      defaultImportance: _defaultImportance,
    );
    setState(() {
      _replaceDrafts(parsed);
      _statusMessage = 'Split into ${parsed.length} task${parsed.length == 1 ? '' : 's'}';
    });
  }

  Future<void> _autoSortWithAi() async {
    final text = _rawController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isParsing = true;
      _statusMessage = null;
    });
    try {
      final parsed = await widget.onParseWithAi(text);
      if (!mounted) return;
      setState(() {
        _replaceDrafts(parsed);
        _statusMessage = 'AI organized ${parsed.length} task${parsed.length == 1 ? '' : 's'}';
      });
    } catch (_) {
      if (!mounted) return;
      final fallback = BulkAddTasksDialog.splitLinesLocally(
        text,
        defaultCategoryId: _defaultCategoryId,
        defaultImportance: _defaultImportance,
      );
      setState(() {
        _replaceDrafts(fallback);
        _statusMessage = 'Offline fallback: split into ${fallback.length} task${fallback.length == 1 ? '' : 's'}';
      });
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  Future<void> _pickSharedDeadline() async {
    final now = DateTime.now();
    final initial = _sharedDueDate ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_sharedDueDate ?? DateTime(2026, 1, 1, 18, 0)),
      builder: (ctx, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );
    if (time == null || !mounted) return;
    setState(() {
      _sharedDueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveAll() async {
    if (_drafts.isEmpty && _rawController.text.trim().isNotEmpty) {
      _splitLines();
    }
    final items = _drafts
        .map((d) => (
              title: d.titleController.text.trim(),
              description: d.description.trim().isEmpty ? null : d.description.trim(),
              categoryId: d.categoryId,
              baseImportance: d.importance,
            ))
        .where((item) => item.title.isNotEmpty)
        .toList();
    if (items.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSaveBulk(items, _sharedDueDate);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bulk Add Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste notes, bullet points, or a list of titles, then split lines or let AI organize them under one shared deadline.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rawController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '- Finish lab report\n- Email advisor about draft\n- Buy groceries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickSharedDeadline,
                    icon: const Icon(Icons.event_outlined, size: 16),
                    label: Text(
                      _sharedDueDate != null
                          ? 'Deadline: ${DateFormat('MMM d, h:mm a').format(_sharedDueDate!)}'
                          : 'No shared deadline',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (_sharedDueDate != null)
                    IconButton(
                      tooltip: 'Clear deadline',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                      onPressed: () => setState(() => _sharedDueDate = null),
                    ),
                  DropdownButton<String>(
                    value: _defaultCategoryId,
                    dropdownColor: AppColors.surface,
                    items: widget.categories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _defaultCategoryId = val);
                    },
                  ),
                  DropdownButton<int>(
                    value: _defaultImportance.clamp(1, widget.numImportanceLevels),
                    dropdownColor: AppColors.surface,
                    items: List.generate(widget.numImportanceLevels, (i) => i + 1)
                        .map((lvl) => DropdownMenuItem(value: lvl, child: Text('Priority L$lvl', style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _defaultImportance = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isParsing ? null : _splitLines,
                    icon: const Icon(Icons.format_list_bulleted, size: 16),
                    label: const Text('Split lines'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isParsing ? null : _autoSortWithAi,
                    icon: _isParsing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, size: 16),
                    label: Text(_isParsing ? 'Organizing...' : 'AI auto-sort'),
                  ),
                  const SizedBox(width: 12),
                  if (_statusMessage != null)
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: AppTheme.mono(11, color: AppColors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const Divider(height: 20, color: AppColors.border),
              Expanded(
                child: _drafts.isEmpty
                    ? const Center(
                        child: Text(
                          'Preview list appears here (or click Add Tasks directly to split lines).',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _drafts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final row = _drafts[idx];
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: row.titleController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: row.importance.clamp(1, widget.numImportanceLevels),
                                dropdownColor: AppColors.surface,
                                items: List.generate(widget.numImportanceLevels, (i) => i + 1)
                                    .map((lvl) => DropdownMenuItem(value: lvl, child: Text('L$lvl', style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => row.importance = val);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                                onPressed: () => setState(() {
                                  row.dispose();
                                  _drafts.removeAt(idx);
                                }),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAll,
                    child: Text(
                      _drafts.isNotEmpty
                          ? 'Add ${_drafts.length} Task${_drafts.length == 1 ? '' : 's'}'
                          : 'Add Tasks',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
