import 'dart:convert';

enum RecurrenceType {
  intervalAfterCompletion,
  fixedSchedule;

  static RecurrenceType fromString(String? value) {
    if (value == 'fixed_schedule' || value == 'fixedSchedule') {
      return RecurrenceType.fixedSchedule;
    }
    return RecurrenceType.intervalAfterCompletion;
  }

  String get asString {
    switch (this) {
      case RecurrenceType.fixedSchedule:
        return 'fixed_schedule';
      case RecurrenceType.intervalAfterCompletion:
        return 'interval_after_completion';
    }
  }
}

enum ScheduleFrequency {
  daily,
  weekly,
  monthly;

  static ScheduleFrequency fromString(String? value) {
    switch (value) {
      case 'daily':
        return ScheduleFrequency.daily;
      case 'monthly':
        return ScheduleFrequency.monthly;
      case 'weekly':
      default:
        return ScheduleFrequency.weekly;
    }
  }

  String get asString {
    switch (this) {
      case ScheduleFrequency.daily:
        return 'daily';
      case ScheduleFrequency.weekly:
        return 'weekly';
      case ScheduleFrequency.monthly:
        return 'monthly';
    }
  }
}

class RecurrenceRule {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final RecurrenceType type;
  final int? intervalDays; // e.g. 3 days after completion
  final ScheduleFrequency? frequency;
  final List<int> daysOfWeek; // e.g. [DateTime.wednesday]
  final int? dayOfMonth; // e.g. 21 for 21st of every month
  final String timeOfDay; // "HH:mm", e.g. "17:00"
  final int baseImportance;
  final String categoryId;
  final DateTime? lastMissedDueDate; // for sequential catch-up tracking
  final DateTime nextDueAt;
  final bool isActive;
  final DateTime createdAt;

  const RecurrenceRule({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    this.intervalDays,
    this.frequency,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    this.timeOfDay = '18:00',
    required this.baseImportance,
    this.categoryId = 'all',
    this.lastMissedDueDate,
    required this.nextDueAt,
    this.isActive = true,
    required this.createdAt,
  });

  RecurrenceRule copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    RecurrenceType? type,
    int? intervalDays,
    ScheduleFrequency? frequency,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    String? timeOfDay,
    int? baseImportance,
    String? categoryId,
    DateTime? lastMissedDueDate,
    bool clearLastMissedDueDate = false,
    DateTime? nextDueAt,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurrenceRule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      intervalDays: intervalDays ?? this.intervalDays,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      baseImportance: baseImportance ?? this.baseImportance,
      categoryId: categoryId ?? this.categoryId,
      lastMissedDueDate: clearLastMissedDueDate
          ? null
          : (lastMissedDueDate ?? this.lastMissedDueDate),
      nextDueAt: nextDueAt ?? this.nextDueAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.asString,
      'intervalDays': intervalDays,
      'frequency': frequency?.asString,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'timeOfDay': timeOfDay,
      'baseImportance': baseImportance,
      'categoryId': categoryId,
      'lastMissedDueDate': lastMissedDueDate?.toIso8601String(),
      'nextDueAt': nextDueAt.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      type: RecurrenceType.fromString(map['type']),
      intervalDays: map['intervalDays'] is int ? map['intervalDays'] : null,
      frequency: map['frequency'] != null
          ? ScheduleFrequency.fromString(map['frequency'])
          : null,
      daysOfWeek: map['daysOfWeek'] is List
          ? List<int>.from(map['daysOfWeek'])
          : const [],
      dayOfMonth: map['dayOfMonth'] is int ? map['dayOfMonth'] : null,
      timeOfDay: map['timeOfDay'] ?? '18:00',
      baseImportance: map['baseImportance'] is int ? map['baseImportance'] : 1,
      categoryId: map['categoryId'] ?? 'all',
      lastMissedDueDate: map['lastMissedDueDate'] != null
          ? DateTime.tryParse(map['lastMissedDueDate'])
          : null,
      nextDueAt: map['nextDueAt'] != null
          ? DateTime.tryParse(map['nextDueAt']) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['isActive'] != false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RecurrenceRule.fromJson(String source) =>
      RecurrenceRule.fromMap(json.decode(source));
}
