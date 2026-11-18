import 'dart:convert';
import 'dart:math';

class SubtaskItem {
  final String id;
  final String title;
  final bool isCompleted;
  final int baseImportance;

  const SubtaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.baseImportance = 1,
  });

  SubtaskItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? baseImportance,
  }) {
    return SubtaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      baseImportance: baseImportance ?? this.baseImportance,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'baseImportance': baseImportance,
      };

  factory SubtaskItem.fromMap(Map<String, dynamic> map) {
    final imp = map['baseImportance'] is num ? (map['baseImportance'] as num).toInt() : 1;
    return SubtaskItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      baseImportance: imp.clamp(1, 5),
    );
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  ignored;

  static TaskStatus fromString(String? value) {
    switch (value) {
      case 'inProgress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'ignored':
        return TaskStatus.ignored;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  String get asString {
    switch (this) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.ignored:
        return 'ignored';
      case TaskStatus.pending:
        return 'pending';
    }
  }
}

class TaskItem {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String categoryId;
  final int baseImportance; // 1 (lowest), 2, 3 (highest)
  final int effectiveImportance; // computed based on proximity to due date
  final DateTime? dueDate;
  final TaskStatus status;
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? ignoredAt;
  final DateTime? inProgressAt;
  final List<String> attachmentPaths;
  final String? recurrenceRuleId;
  final String? calendarEventId;
  final Map<String, dynamic>? emailRef;
  final List<SubtaskItem> subtasks;
  final String? givenById;
  final String? givenByName;

  const TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.categoryId = 'all',
    required this.baseImportance,
    required this.effectiveImportance,
    this.dueDate,
    this.status = TaskStatus.pending,
    this.isOverdue = false,
    required this.createdAt,
    this.completedAt,
    this.ignoredAt,
    this.inProgressAt,
    this.attachmentPaths = const [],
    this.recurrenceRuleId,
    this.calendarEventId,
    this.emailRef,
    this.subtasks = const [],
    this.givenById,
    this.givenByName,
  });

  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isIgnored => status == TaskStatus.ignored;
  bool get isPending => status == TaskStatus.pending;
  bool get isRecurring => recurrenceRuleId != null && recurrenceRuleId!.isNotEmpty;
  bool get hasSubtasks => subtasks.isNotEmpty;
  int get completedSubtaskCount => subtasks.where((s) => s.isCompleted).length;

  /// Recomputes parent baseImportance and completion status from embedded subtasks.
  TaskItem recalculateFromSubtasks({DateTime? currentTime}) {
    if (subtasks.isEmpty) return this;
    final highest = subtasks.map((s) => s.baseImportance).reduce(max);
    final allDone = subtasks.every((s) => s.isCompleted);
    final now = currentTime ?? DateTime.now();

    if (allDone && !isCompleted) {
      return copyWith(
        baseImportance: highest,
        effectiveImportance: max(effectiveImportance, highest),
        status: TaskStatus.completed,
        completedAt: completedAt ?? now,
        clearInProgressAt: true,
      );
    }
    if (!allDone && isCompleted) {
      return copyWith(
        baseImportance: highest,
        status: TaskStatus.pending,
        clearCompletedAt: true,
      );
    }
    return copyWith(baseImportance: highest);
  }

  TaskItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? categoryId,
    int? baseImportance,
    int? effectiveImportance,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    bool? isOverdue,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? ignoredAt,
    bool clearIgnoredAt = false,
    DateTime? inProgressAt,
    bool clearInProgressAt = false,
    List<String>? attachmentPaths,
    String? recurrenceRuleId,
    bool clearRecurrenceRuleId = false,
    String? calendarEventId,
    Map<String, dynamic>? emailRef,
    List<SubtaskItem>? subtasks,
    String? givenById,
    String? givenByName,
  }) {
    return TaskItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      baseImportance: baseImportance ?? this.baseImportance,
      effectiveImportance: effectiveImportance ?? this.effectiveImportance,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      status: status ?? this.status,
      isOverdue: isOverdue ?? this.isOverdue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      ignoredAt: clearIgnoredAt ? null : (ignoredAt ?? this.ignoredAt),
      inProgressAt: clearInProgressAt ? null : (inProgressAt ?? this.inProgressAt),
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      recurrenceRuleId: clearRecurrenceRuleId ? null : (recurrenceRuleId ?? this.recurrenceRuleId),
      calendarEventId: calendarEventId ?? this.calendarEventId,
      emailRef: emailRef ?? this.emailRef,
      subtasks: subtasks ?? this.subtasks,
      givenById: givenById ?? this.givenById,
      givenByName: givenByName ?? this.givenByName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'baseImportance': baseImportance,
      'effectiveImportance': effectiveImportance,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.asString,
      'isOverdue': isOverdue,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'ignoredAt': ignoredAt?.toIso8601String(),
      'inProgressAt': inProgressAt?.toIso8601String(),
      'attachmentPaths': attachmentPaths,
      'recurrenceRuleId': recurrenceRuleId,
      'calendarEventId': calendarEventId,
      'emailRef': emailRef,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'givenById': givenById,
      'givenByName': givenByName,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final rawSubtasks = map['subtasks'];
    final parsedSubtasks = rawSubtasks is List
        ? rawSubtasks.whereType<Map>().map((m) => SubtaskItem.fromMap(Map<String, dynamic>.from(m))).toList()
        : const <SubtaskItem>[];

    return TaskItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      categoryId: map['categoryId'] ?? 'all',
      baseImportance: map['baseImportance'] is int ? map['baseImportance'] : 1,
      effectiveImportance: map['effectiveImportance'] is int ? map['effectiveImportance'] : 1,
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
      status: TaskStatus.fromString(map['status']),
      isOverdue: map['isOverdue'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
      ignoredAt: map['ignoredAt'] != null ? DateTime.tryParse(map['ignoredAt']) : null,
      inProgressAt: map['inProgressAt'] != null ? DateTime.tryParse(map['inProgressAt']) : null,
      attachmentPaths: map['attachmentPaths'] is List
          ? List<String>.from(map['attachmentPaths'])
          : const [],
      recurrenceRuleId: map['recurrenceRuleId'],
      calendarEventId: map['calendarEventId'],
      emailRef: map['emailRef'] is Map ? Map<String, dynamic>.from(map['emailRef']) : null,
      subtasks: parsedSubtasks,
      givenById: map['givenById']?.toString(),
      givenByName: map['givenByName']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskItem.fromJson(String source) => TaskItem.fromMap(json.decode(source));
}
