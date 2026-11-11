import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_sync/domain/models/task_item.dart';
import 'package:task_calendar_sync/domain/models/category_item.dart';
import 'package:task_calendar_sync/domain/models/recurrence_rule.dart';
import 'package:task_calendar_sync/domain/engine/priority_engine.dart';
import 'package:task_calendar_sync/ui/theme/app_theme.dart';

class AddEditTaskDialog extends StatefulWidget {
  final TaskItem? existingTask;
  final List<CategoryItem> categories;
  final Function({
    required String title,
    String? description,
    required String categoryId,
    required int baseImportance,
    DateTime? dueDate,
    List<String> attachmentPaths,
    RecurrenceRule? recurrenceRule,
  }) onSave;
  final Function(String taskId)? onMarkDone;
  final Function(String taskId)? onMarkInProgress;
  final Function(String taskId)? onMarkIgnored;
  final Function(String taskId)? onDelete;

  const AddEditTaskDialog({
    super.key,
    this.existingTask,
    required this.categories,
    required this.onSave,
    this.onMarkDone,
    this.onMarkInProgress,
    this.onMarkIgnored,
    this.onDelete,
  });

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _selectedCategoryId;
  late int _selectedImportance;
  DateTime? _selectedDueDate;
  List<String> _attachmentPaths = [];

  // Recurrence configuration
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.fixedSchedule;
  int _intervalDays = 3;
  final ScheduleFrequency _frequency = ScheduleFrequency.weekly;
  int _selectedDayOfWeek = DateTime.wednesday;
  final TimeOfDay _timeOfDay = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedCategoryId = task?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'all');
    _selectedImportance = task?.baseImportance ?? 3;
    _attachmentPaths = List.from(task?.attachmentPaths ?? []);
    _isRecurring = task?.isRecurring ?? false;

    if (task != null) {
      _selectedDueDate = task.dueDate;
    } else {
      // Live pre-populate smart default due date for new task
      _selectedDueDate = PriorityEngine.getDefaultDueDateForImportance(_selectedImportance);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onImportanceChanged(int level) {
    setState(() {
      _selectedImportance = level;
      // Live pre-population if user hasn't explicitly set a custom date
      _selectedDueDate = PriorityEngine.getDefaultDueDateForImportance(level);
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now.add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
      builder: (context, child) => Theme(data: AppTheme.darkTheme(), child: child!),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        59,
      );
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result.isNotEmpty) {
        setState(() {
          _attachmentPaths.addAll(
            result.where((f) => f.path != null).map((f) => f.path!),
          );
        });
      }
    } catch (_) {}
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    RecurrenceRule? rule;
    if (_isRecurring) {
      final timeStr =
          '${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}';
      final now = DateTime.now();
      DateTime nextDue = _selectedDueDate ?? now.add(Duration(days: _intervalDays));

      rule = RecurrenceRule(
        id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        type: _recurrenceType,
        intervalDays: _recurrenceType == RecurrenceType.intervalAfterCompletion ? _intervalDays : null,
        frequency: _recurrenceType == RecurrenceType.fixedSchedule ? _frequency : null,
        daysOfWeek: _recurrenceType == RecurrenceType.fixedSchedule ? [_selectedDayOfWeek] : const [],
        timeOfDay: timeStr,
        baseImportance: _selectedImportance,
        categoryId: _selectedCategoryId,
        nextDueAt: nextDue,
        createdAt: now,
      );
    }

    widget.onSave(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      categoryId: _selectedCategoryId,
      baseImportance: _selectedImportance,
      dueDate: _selectedDueDate,
      attachmentPaths: _attachmentPaths,
      recurrenceRule: rule,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog Header with Switch between One-Off and Recurring
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'New Task',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    if (!isEditing)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            _buildModeTab('One-off', !_isRecurring, () => setState(() => _isRecurring = false)),
                            _buildModeTab('Recurring', _isRecurring, () => setState(() => _isRecurring = true)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field (Mandatory)
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            hintText: 'e.g., Submit Weekly Assignment',
                            prefixIcon: const Icon(Icons.title, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Title is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Importance Level Selector (Mandatory)
                        const Text('Importance Level *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildImportanceChip(3, 'Level 3 (Urgent)', AppColors.level3),
                            const SizedBox(width: 8),
                            _buildImportanceChip(2, 'Level 2 (Medium)', AppColors.level2),
                            const SizedBox(width: 8),
                            _buildImportanceChip(1, 'Level 1 (Low)', AppColors.level1),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Category Selector
                        const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.categories.map<Widget>((cat) {
                            final isSelected = _selectedCategoryId == cat.id;
                            return ChoiceChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                              selectedColor: Color(cat.colorValue).withValues(alpha: 0.3),
                              backgroundColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: isSelected ? Color(cat.colorValue) : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Due Date Picker with Live Default Pre-population
                        const Text('Due Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedDueDate != null
                                      ? DateFormat('EEE, MMM d, yyyy  •  h:mm a').format(_selectedDueDate!)
                                      : 'No due date set',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _selectedDueDate != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _pickDateTime,
                                child: Text(_selectedDueDate == null ? 'Set Date' : 'Change'),
                              ),
                              if (_selectedDueDate != null)
                                IconButton(
                                  tooltip: 'Clear due date',
                                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                                  onPressed: () => setState(() => _selectedDueDate = null),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Recurrence Configuration Form
                        if (_isRecurring) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.repeat, size: 16, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Recurrence Rules', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SegmentedButton<RecurrenceType>(
                                  segments: [
                                    ButtonSegment(value: RecurrenceType.fixedSchedule, label: Text('Fixed Schedule')),
                                    ButtonSegment(value: RecurrenceType.intervalAfterCompletion, label: Text('Interval Cadence')),
                                  ],
                                  selected: {_recurrenceType},
                                  onSelectionChanged: (set) => setState(() => _recurrenceType = set.first),
                                ),
                                const SizedBox(height: 12),
                                if (_recurrenceType == RecurrenceType.intervalAfterCompletion)
                                  Row(
                                    children: [
                                      const Text('Repeats every', style: TextStyle(color: AppColors.textSecondary)),
                                      const SizedBox(width: 10),
                                      DropdownButton<int>(
                                        value: _intervalDays,
                                        dropdownColor: AppColors.surface,
                                        items: [1, 2, 3, 4, 7, 14, 30].map((d) => DropdownMenuItem(value: d, child: Text('$d days'))).toList(),
                                        onChanged: (val) => setState(() => _intervalDays = val ?? 3),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('after completed', style: TextStyle(color: AppColors.textSecondary)),
                                    ],
                                  )
                                else ...[
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      ('Mon', DateTime.monday),
                                      ('Tue', DateTime.tuesday),
                                      ('Wed', DateTime.wednesday),
                                      ('Thu', DateTime.thursday),
                                      ('Fri', DateTime.friday),
                                      ('Sat', DateTime.saturday),
                                      ('Sun', DateTime.sunday),
                                    ].map((day) {
                                      final isSelected = _selectedDayOfWeek == day.$2;
                                      return ChoiceChip(
                                        label: Text(day.$1),
                                        selected: isSelected,
                                        onSelected: (_) => setState(() => _selectedDayOfWeek = day.$2),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Description Field
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Add extra context, checklist, or instructions...',
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Attachments Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Attachments & Files', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            TextButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.attach_file, size: 16),
                              label: const Text('Add File'),
                            ),
                          ],
                        ),
                        if (_attachmentPaths.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _attachmentPaths.map((path) {
                              final name = path.split('/').last;
                              return Chip(
                                avatar: const Icon(Icons.insert_drive_file, size: 16, color: AppColors.primary),
                                label: Text(name, style: const TextStyle(fontSize: 12)),
                                onDeleted: () => setState(() => _attachmentPaths.remove(path)),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: AppColors.border, height: 24),

                // Dialog Action Buttons:
                // If editing: Ignore, In Progress, Done, Delete, and Save
                if (isEditing)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Delete
                      IconButton(
                        tooltip: 'Delete task',
                        icon: const Icon(Icons.delete_outline, color: AppColors.overdue),
                        onPressed: () {
                          widget.onDelete?.call(widget.existingTask!.id);
                          Navigator.of(context).pop();
                        },
                      ),

                      Wrap(
                        spacing: 8,
                        children: [
                          // Ignore Button (Dismisses without being done)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.textMuted),
                            onPressed: () {
                              widget.onMarkIgnored?.call(widget.existingTask!.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ignore'),
                          ),

                          // Mark In Progress
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.inProgress,
                              side: const BorderSide(color: AppColors.inProgress),
                            ),
                            onPressed: () {
                              widget.onMarkInProgress?.call(widget.existingTask!.id);
                              Navigator.of(context).pop();
                            },
                            child: Text(widget.existingTask!.isInProgress ? 'Unmark Progress' : 'In Progress'),
                          ),

                          // Mark Done
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inProgress,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              widget.onMarkDone?.call(widget.existingTask!.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Mark Done'),
                          ),

                          // Save Changes
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _submit,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  // New Task Creation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _submit,
                        child: const Text('Create Task'),
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

  Widget _buildModeTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildImportanceChip(int level, String label, Color color) {
    final isSelected = _selectedImportance == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onImportanceChanged(level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
