import 'dart:convert';

enum RecurrenceType {
  intervalBased,
  calendarBased,
  intervalAfterCompletion,
  fixedSchedule;

  static RecurrenceType fromString(String? value) {
    if (value == 'calendarBased' ||
        value == 'fixed_schedule' ||
        value == 'fixedSchedule' ||
        value == 'calendar_based') {
      return RecurrenceType.calendarBased;
    }
    return RecurrenceType.intervalBased;
  }

  bool get isInterval =>
      this == RecurrenceType.intervalBased ||
      this == RecurrenceType.intervalAfterCompletion;

  bool get isCalendar =>
      this == RecurrenceType.calendarBased ||
      this == RecurrenceType.fixedSchedule;

  String get asString {
    switch (this) {
      case RecurrenceType.calendarBased:
      case RecurrenceType.fixedSchedule:
        return 'calendar_based';
      case RecurrenceType.intervalBased:
      case RecurrenceType.intervalAfterCompletion:
        return 'interval_based';
    }
  }
}

enum ScheduleFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  static ScheduleFrequency fromString(String? value) {
    switch (value) {
      case 'daily':
        return ScheduleFrequency.daily;
      case 'monthly':
        return ScheduleFrequency.monthly;
      case 'yearly':
        return ScheduleFrequency.yearly;
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
      case ScheduleFrequency.yearly:
        return 'yearly';
    }
  }
}

class RecurrenceRule {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final RecurrenceType type;

  // Interval-based properties (e.g. every 3 days, or every 6 weeks after completion)
  final int intervalValue; // e.g. 3
  final String intervalUnit; // 'days', 'weeks', 'months'
  final bool afterCompletion; // true = "after completion", false = "since scheduled date"

  // Calendar-based properties (Google Calendar style)
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
    int? intervalDays,
    int? intervalValue,
    this.intervalUnit = 'days',
    this.afterCompletion = true,
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
  }) : intervalValue = intervalValue ?? intervalDays ?? 3;

  // Backward-compatibility getter for interval in days
  int get intervalDays {
    if (intervalUnit == 'weeks') return intervalValue * 7;
    if (intervalUnit == 'months') return intervalValue * 30;
    return intervalValue;
  }

  String get recurrenceSummary {
    if (type.isInterval) {
      final unitLabel = intervalValue == 1
          ? (intervalUnit == 'days' ? 'day' : intervalUnit == 'weeks' ? 'week' : 'month')
          : intervalUnit;
      final afterStr = afterCompletion ? ' after completion' : '';
      return 'Every $intervalValue $unitLabel$afterStr';
    } else {
      switch (frequency ?? ScheduleFrequency.weekly) {
        case ScheduleFrequency.daily:
          return 'Daily at $timeOfDay';
        case ScheduleFrequency.weekly:
          final days = daysOfWeek.isEmpty
              ? 'Wednesdays'
              : daysOfWeek.map((d) {
                  switch (d) {
                    case DateTime.monday:
                      return 'Mon';
                    case DateTime.tuesday:
                      return 'Tue';
                    case DateTime.wednesday:
                      return 'Wed';
                    case DateTime.thursday:
                      return 'Thu';
                    case DateTime.friday:
                      return 'Fri';
                    case DateTime.saturday:
                      return 'Sat';
                    case DateTime.sunday:
                      return 'Sun';
                    default:
                      return '';
                  }
                }).join(', ');
          return 'Every $days at $timeOfDay';
        case ScheduleFrequency.monthly:
          return 'Monthly on the ${dayOfMonth ?? 1}th at $timeOfDay';
        case ScheduleFrequency.yearly:
          return 'Yearly at $timeOfDay';
      }
    }
  }

  RecurrenceRule copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    RecurrenceType? type,
    int? intervalDays,
    int? intervalValue,
    String? intervalUnit,
    bool? afterCompletion,
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
      intervalValue: intervalValue ?? intervalDays ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      afterCompletion: afterCompletion ?? this.afterCompletion,
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
      'intervalValue': intervalValue,
      'intervalDays': intervalDays,
      'intervalUnit': intervalUnit,
      'afterCompletion': afterCompletion,
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
    final legacyInterval = map['intervalDays'] is int ? map['intervalDays'] as int : 3;
    final intervalVal = map['intervalValue'] is int
        ? map['intervalValue'] as int
        : legacyInterval;

    return RecurrenceRule(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      type: RecurrenceType.fromString(map['type']),
      intervalValue: intervalVal,
      intervalUnit: map['intervalUnit'] ?? 'days',
      afterCompletion: map['afterCompletion'] != false,
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
