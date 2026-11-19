import 'dart:convert';

class EscalationWindow {
  static const List<String> validUnits = ['minutes', 'hours', 'days', 'weeks', 'months'];

  final int value;
  final String unit;

  const EscalationWindow({required this.value, required this.unit});

  Duration get duration {
    final safeVal = value < 1 ? 1 : value;
    switch (unit) {
      case 'minutes':
        return Duration(minutes: safeVal);
      case 'hours':
        return Duration(hours: safeVal);
      case 'weeks':
        return Duration(days: safeVal * 7);
      case 'months':
        return Duration(days: safeVal * 30);
      case 'days':
      default:
        return Duration(days: safeVal);
    }
  }

  String get displayLabel {
    final singular = unit.endsWith('s') ? unit.substring(0, unit.length - 1) : unit;
    return '$value ${value == 1 ? singular : unit}';
  }

  Map<String, dynamic> toMap() => {'value': value, 'unit': unit};

  factory EscalationWindow.fromMap(
    Map<String, dynamic> map, {
    required int fallbackValue,
    required String fallbackUnit,
  }) {
    final rawVal = map['value'];
    final parsedVal = rawVal is num && rawVal.toInt() >= 1 ? rawVal.toInt() : fallbackValue;
    final rawUnit = map['unit']?.toString().trim() ?? '';
    final parsedUnit = validUnits.contains(rawUnit) ? rawUnit : fallbackUnit;
    return EscalationWindow(value: parsedVal, unit: parsedUnit);
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int maxInProgressTasks;
  final int numImportanceLevels;
  final Map<int, String> levelNames;

  // Escalation windows (number on left, modifier on right)
  final int level2WindowValue;
  final String level2WindowUnit; // 'minutes', 'hours', 'days', 'weeks', 'months'
  final int level3WindowValue;
  final String level3WindowUnit; // 'minutes', 'hours', 'days', 'weeks', 'months'
  final Map<int, EscalationWindow> escalationWindows;

  // Backward compatibility legacy fields
  final int level2ThresholdDays;
  final int level3ThresholdDays;

  // Calendar & Gemini
  final bool twoWayTimeBlocking;
  final String? geminiApiKey;

  // Vacation Mode
  final bool vacationModeEnabled;
  final DateTime? vacationStartDate;
  final DateTime? vacationEndDate;
  final List<String> vacationFrozenChoreIds;
  final String vacationNotificationFilter; // 'urgent_only', 'none', 'all'

  // Notification customization
  final bool notificationsEnabled;
  final int notifyPriorHours; // legacy hours fallback
  final int notifyPriorMinutes; // primary reminder lead time in minutes
  final String notifyForTier; // 'all', 'urgent_only', 'in_progress_only'
  final bool notifyForOverdue;
  final bool reviewTasksEnabled;
  final String reviewTasksTime; // 'HH:mm', e.g. '09:00'
  final bool reviewTasksPersistent;
  final bool appOpenedToday;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.maxInProgressTasks = 3,
    this.numImportanceLevels = 3,
    this.levelNames = const {
      1: 'Level 1 (Low)',
      2: 'Level 2 (Medium)',
      3: 'Level 3 (Urgent)',
      4: 'Level 4 (Critical)',
      5: 'Level 5 (Emergency)',
    },
    this.level2WindowValue = 7,
    this.level2WindowUnit = 'days',
    this.level3WindowValue = 1,
    this.level3WindowUnit = 'days',
    this.escalationWindows = const {},
    this.level2ThresholdDays = 7,
    this.level3ThresholdDays = 1,
    this.twoWayTimeBlocking = true,
    this.geminiApiKey,
    this.vacationModeEnabled = false,
    this.vacationStartDate,
    this.vacationEndDate,
    this.vacationFrozenChoreIds = const [],
    this.vacationNotificationFilter = 'urgent_only',
    this.notificationsEnabled = true,
    this.notifyPriorHours = 1,
    this.notifyPriorMinutes = 60,
    this.notifyForTier = 'all',
    this.notifyForOverdue = true,
    this.reviewTasksEnabled = true,
    this.reviewTasksTime = '09:00',
    this.reviewTasksPersistent = true,
    this.appOpenedToday = true,
  });

  String getLevelName(int level) {
    if (levelNames.containsKey(level) && levelNames[level]!.trim().isNotEmpty) {
      return levelNames[level]!;
    }
    return 'Level $level';
  }

  EscalationWindow getEscalationWindow(int level) {
    if (escalationWindows.containsKey(level)) {
      return escalationWindows[level]!;
    }
    if (level == 2) {
      return EscalationWindow(value: level2WindowValue, unit: level2WindowUnit);
    }
    if (level == 3) {
      return EscalationWindow(value: level3WindowValue, unit: level3WindowUnit);
    }
    if (level == 4) {
      return const EscalationWindow(value: 12, unit: 'hours');
    }
    return const EscalationWindow(value: 4, unit: 'hours');
  }

  Duration getThresholdDuration(int level) => getEscalationWindow(level).duration;

  bool isChoreFrozenInVacation(String? ruleId) {
    if (!vacationModeEnabled || ruleId == null) return false;
    final now = DateTime.now();
    if (vacationStartDate != null && now.isBefore(vacationStartDate!)) return false;
    if (vacationEndDate != null && now.isAfter(vacationEndDate!)) return false;
    return vacationFrozenChoreIds.contains(ruleId);
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? maxInProgressTasks,
    int? numImportanceLevels,
    Map<int, String>? levelNames,
    int? level2WindowValue,
    String? level2WindowUnit,
    int? level3WindowValue,
    String? level3WindowUnit,
    Map<int, EscalationWindow>? escalationWindows,
    int? level2ThresholdDays,
    int? level3ThresholdDays,
    bool? twoWayTimeBlocking,
    String? geminiApiKey,
    bool clearGeminiApiKey = false,
    bool? vacationModeEnabled,
    DateTime? vacationStartDate,
    bool clearVacationStartDate = false,
    DateTime? vacationEndDate,
    bool clearVacationEndDate = false,
    List<String>? vacationFrozenChoreIds,
    String? vacationNotificationFilter,
    bool? notificationsEnabled,
    int? notifyPriorHours,
    int? notifyPriorMinutes,
    String? notifyForTier,
    bool? notifyForOverdue,
    bool? reviewTasksEnabled,
    String? reviewTasksTime,
    bool? reviewTasksPersistent,
    bool? appOpenedToday,
  }) {
    final nextWindows = Map<int, EscalationWindow>.from(escalationWindows ?? this.escalationWindows);
    final nextL2Val = level2WindowValue ?? nextWindows[2]?.value ?? this.level2WindowValue;
    final nextL2Unit = level2WindowUnit ?? nextWindows[2]?.unit ?? this.level2WindowUnit;
    final nextL3Val = level3WindowValue ?? nextWindows[3]?.value ?? this.level3WindowValue;
    final nextL3Unit = level3WindowUnit ?? nextWindows[3]?.unit ?? this.level3WindowUnit;
    nextWindows[2] = EscalationWindow(value: nextL2Val, unit: nextL2Unit);
    nextWindows[3] = EscalationWindow(value: nextL3Val, unit: nextL3Unit);

    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      maxInProgressTasks: maxInProgressTasks ?? this.maxInProgressTasks,
      numImportanceLevels: numImportanceLevels ?? this.numImportanceLevels,
      levelNames: levelNames ?? this.levelNames,
      level2WindowValue: nextL2Val,
      level2WindowUnit: nextL2Unit,
      level3WindowValue: nextL3Val,
      level3WindowUnit: nextL3Unit,
      escalationWindows: nextWindows,
      level2ThresholdDays: level2ThresholdDays ?? this.level2ThresholdDays,
      level3ThresholdDays: level3ThresholdDays ?? this.level3ThresholdDays,
      twoWayTimeBlocking: twoWayTimeBlocking ?? this.twoWayTimeBlocking,
      geminiApiKey: clearGeminiApiKey ? null : (geminiApiKey ?? this.geminiApiKey),
      vacationModeEnabled: vacationModeEnabled ?? this.vacationModeEnabled,
      vacationStartDate: clearVacationStartDate ? null : (vacationStartDate ?? this.vacationStartDate),
      vacationEndDate: clearVacationEndDate ? null : (vacationEndDate ?? this.vacationEndDate),
      vacationFrozenChoreIds: vacationFrozenChoreIds ?? this.vacationFrozenChoreIds,
      vacationNotificationFilter: vacationNotificationFilter ?? this.vacationNotificationFilter,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyPriorHours: notifyPriorHours ??
          (notifyPriorMinutes != null ? (notifyPriorMinutes / 60).round() : this.notifyPriorHours),
      notifyPriorMinutes: notifyPriorMinutes ??
          (notifyPriorHours != null ? notifyPriorHours * 60 : this.notifyPriorMinutes),
      notifyForTier: notifyForTier ?? this.notifyForTier,
      notifyForOverdue: notifyForOverdue ?? this.notifyForOverdue,
      reviewTasksEnabled: reviewTasksEnabled ?? this.reviewTasksEnabled,
      reviewTasksTime: reviewTasksTime ?? this.reviewTasksTime,
      reviewTasksPersistent: reviewTasksPersistent ?? this.reviewTasksPersistent,
      appOpenedToday: appOpenedToday ?? this.appOpenedToday,
    );
  }

  Map<String, dynamic> toMap() {
    final serializedWindows = <String, dynamic>{};
    for (int lvl = 2; lvl <= 5; lvl++) {
      serializedWindows[lvl.toString()] = getEscalationWindow(lvl).toMap();
    }
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'maxInProgressTasks': maxInProgressTasks,
      'numImportanceLevels': numImportanceLevels,
      'levelNames': levelNames.map((k, v) => MapEntry(k.toString(), v)),
      'level2WindowValue': level2WindowValue,
      'level2WindowUnit': level2WindowUnit,
      'level3WindowValue': level3WindowValue,
      'level3WindowUnit': level3WindowUnit,
      'escalationWindows': serializedWindows,
      'level2ThresholdDays': level2ThresholdDays,
      'level3ThresholdDays': level3ThresholdDays,
      'twoWayTimeBlocking': twoWayTimeBlocking,
      'geminiApiKey': geminiApiKey,
      'vacationModeEnabled': vacationModeEnabled,
      'vacationStartDate': vacationStartDate?.toIso8601String(),
      'vacationEndDate': vacationEndDate?.toIso8601String(),
      'vacationFrozenChoreIds': vacationFrozenChoreIds,
      'vacationNotificationFilter': vacationNotificationFilter,
      'notificationsEnabled': notificationsEnabled,
      'notifyPriorHours': notifyPriorHours,
      'notifyPriorMinutes': notifyPriorMinutes,
      'notifyForTier': notifyForTier,
      'notifyForOverdue': notifyForOverdue,
      'reviewTasksEnabled': reviewTasksEnabled,
      'reviewTasksTime': reviewTasksTime,
      'reviewTasksPersistent': reviewTasksPersistent,
      'appOpenedToday': appOpenedToday,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    Map<int, String> parsedLevelNames = {
      1: 'Level 1 (Low)',
      2: 'Level 2 (Medium)',
      3: 'Level 3 (Urgent)',
      4: 'Level 4 (Critical)',
      5: 'Level 5 (Emergency)',
    };
    if (map['levelNames'] is Map) {
      final m = map['levelNames'] as Map;
      m.forEach((k, v) {
        final intKey = int.tryParse(k.toString());
        final text = v?.toString().trim() ?? '';
        if (intKey != null && text.isNotEmpty) {
          parsedLevelNames[intKey] = text;
        }
      });
    }

    int parsePosInt(dynamic raw, int fallback, {int min = 1, int max = 1000}) {
      if (raw is num) {
        final v = raw.toInt();
        if (v >= min) return v > max ? max : v;
      }
      return fallback;
    }

    String parseUnit(dynamic raw, String fallback) {
      final s = raw?.toString().trim() ?? '';
      return EscalationWindow.validUnits.contains(s) ? s : fallback;
    }

    final l2Days = parsePosInt(map['level2ThresholdDays'], 7);
    final l3Days = parsePosInt(map['level3ThresholdDays'], 1);

    var l2Val = parsePosInt(map['level2WindowValue'], l2Days);
    var l2Unit = parseUnit(map['level2WindowUnit'], 'days');
    var l3Val = parsePosInt(map['level3WindowValue'], l3Days);
    var l3Unit = parseUnit(map['level3WindowUnit'], 'days');

    final parsedWindows = <int, EscalationWindow>{
      2: EscalationWindow(value: l2Val, unit: l2Unit),
      3: EscalationWindow(value: l3Val, unit: l3Unit),
      4: const EscalationWindow(value: 12, unit: 'hours'),
      5: const EscalationWindow(value: 4, unit: 'hours'),
    };
    if (map['escalationWindows'] is Map) {
      final wMap = map['escalationWindows'] as Map;
      wMap.forEach((k, v) {
        final lvl = int.tryParse(k.toString());
        if (lvl != null && lvl >= 2 && lvl <= 5 && v is Map) {
          final fallback = parsedWindows[lvl]!;
          parsedWindows[lvl] = EscalationWindow.fromMap(
            Map<String, dynamic>.from(v),
            fallbackValue: fallback.value,
            fallbackUnit: fallback.unit,
          );
        }
      });
      l2Val = parsedWindows[2]!.value;
      l2Unit = parsedWindows[2]!.unit;
      l3Val = parsedWindows[3]!.value;
      l3Unit = parsedWindows[3]!.unit;
    }

    final priorHours = map['notifyPriorHours'] is num ? (map['notifyPriorHours'] as num).toInt() : 1;
    final priorMins = map['notifyPriorMinutes'] is num
        ? (map['notifyPriorMinutes'] as num).toInt()
        : priorHours * 60;

    final rawVacStart = map['vacationStartDate']?.toString() ?? '';
    final rawVacEnd = map['vacationEndDate']?.toString() ?? '';
    final vacFilter = map['vacationNotificationFilter']?.toString() ?? '';
    final tierFilter = map['notifyForTier']?.toString() ?? '';
    final reviewTime = map['reviewTasksTime']?.toString() ?? '';

    return UserProfile(
      uid: (map['uid']?.toString() ?? '').isNotEmpty ? map['uid'].toString() : 'default_user',
      email: map['email']?.toString() ?? 'user@antigravity.dev',
      displayName: map['displayName']?.toString() ?? 'Alex Morgan',
      maxInProgressTasks: parsePosInt(map['maxInProgressTasks'], 3, min: 1, max: 20),
      numImportanceLevels: parsePosInt(map['numImportanceLevels'], 3, min: 3, max: 5),
      levelNames: parsedLevelNames,
      level2WindowValue: l2Val,
      level2WindowUnit: l2Unit,
      level3WindowValue: l3Val,
      level3WindowUnit: l3Unit,
      escalationWindows: parsedWindows,
      level2ThresholdDays: l2Days,
      level3ThresholdDays: l3Days,
      twoWayTimeBlocking: map['twoWayTimeBlocking'] != false,
      geminiApiKey: map['geminiApiKey']?.toString(),
      vacationModeEnabled: map['vacationModeEnabled'] == true,
      vacationStartDate: rawVacStart.isNotEmpty ? DateTime.tryParse(rawVacStart) : null,
      vacationEndDate: rawVacEnd.isNotEmpty ? DateTime.tryParse(rawVacEnd) : null,
      vacationFrozenChoreIds: map['vacationFrozenChoreIds'] is List
          ? List<String>.from(map['vacationFrozenChoreIds'].map((e) => e.toString()))
          : const [],
      vacationNotificationFilter: vacFilter.isNotEmpty ? vacFilter : 'urgent_only',
      notificationsEnabled: map['notificationsEnabled'] != false,
      notifyPriorHours: priorHours,
      notifyPriorMinutes: priorMins,
      notifyForTier: tierFilter.isNotEmpty ? tierFilter : 'all',
      notifyForOverdue: map['notifyForOverdue'] != false,
      reviewTasksEnabled: map['reviewTasksEnabled'] != false,
      reviewTasksTime: reviewTime.isNotEmpty ? reviewTime : '09:00',
      reviewTasksPersistent: map['reviewTasksPersistent'] != false,
      appOpenedToday: map['appOpenedToday'] != false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  static UserProfile defaultProfile() {
    return const UserProfile(
      uid: 'user_1',
      email: 'alex.morgan@antigravity.dev',
      displayName: 'Alex Morgan',
    );
  }
}
