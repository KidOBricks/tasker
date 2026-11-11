import 'dart:convert';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int maxInProgressTasks;
  final int numImportanceLevels;
  final Map<int, String> levelNames;

  // Escalation windows (number on left, modifier on right)
  final int level2WindowValue;
  final String level2WindowUnit; // 'hours', 'days', 'weeks', 'months'
  final int level3WindowValue;
  final String level3WindowUnit; // 'hours', 'days', 'weeks', 'months'

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
  final int notifyPriorHours; // e.g. 1, 2, 24
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
    this.notifyForTier = 'all',
    this.notifyForOverdue = true,
    this.reviewTasksEnabled = true,
    this.reviewTasksTime = '09:00',
    this.reviewTasksPersistent = true,
    this.appOpenedToday = true,
  });

  String getLevelName(int level) {
    if (levelNames.containsKey(level)) {
      return levelNames[level]!;
    }
    return 'Level $level';
  }

  Duration getThresholdDuration(int level) {
    int val = level == 3 ? level3WindowValue : level2WindowValue;
    String unit = level == 3 ? level3WindowUnit : level2WindowUnit;

    switch (unit) {
      case 'hours':
        return Duration(hours: val);
      case 'weeks':
        return Duration(days: val * 7);
      case 'months':
        return Duration(days: val * 30);
      case 'days':
      default:
        return Duration(days: val);
    }
  }

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
    String? notifyForTier,
    bool? notifyForOverdue,
    bool? reviewTasksEnabled,
    String? reviewTasksTime,
    bool? reviewTasksPersistent,
    bool? appOpenedToday,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      maxInProgressTasks: maxInProgressTasks ?? this.maxInProgressTasks,
      numImportanceLevels: numImportanceLevels ?? this.numImportanceLevels,
      levelNames: levelNames ?? this.levelNames,
      level2WindowValue: level2WindowValue ?? this.level2WindowValue,
      level2WindowUnit: level2WindowUnit ?? this.level2WindowUnit,
      level3WindowValue: level3WindowValue ?? this.level3WindowValue,
      level3WindowUnit: level3WindowUnit ?? this.level3WindowUnit,
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
      notifyPriorHours: notifyPriorHours ?? this.notifyPriorHours,
      notifyForTier: notifyForTier ?? this.notifyForTier,
      notifyForOverdue: notifyForOverdue ?? this.notifyForOverdue,
      reviewTasksEnabled: reviewTasksEnabled ?? this.reviewTasksEnabled,
      reviewTasksTime: reviewTasksTime ?? this.reviewTasksTime,
      reviewTasksPersistent: reviewTasksPersistent ?? this.reviewTasksPersistent,
      appOpenedToday: appOpenedToday ?? this.appOpenedToday,
    );
  }

  Map<String, dynamic> toMap() {
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
        if (intKey != null && v != null) {
          parsedLevelNames[intKey] = v.toString();
        }
      });
    }

    final l2Days = map['level2ThresholdDays'] is int ? map['level2ThresholdDays'] as int : 7;
    final l3Days = map['level3ThresholdDays'] is int ? map['level3ThresholdDays'] as int : 1;

    return UserProfile(
      uid: map['uid'] ?? 'default_user',
      email: map['email'] ?? 'user@antigravity.dev',
      displayName: map['displayName'] ?? 'Alex Morgan',
      maxInProgressTasks: map['maxInProgressTasks'] is int ? map['maxInProgressTasks'] : 3,
      numImportanceLevels: map['numImportanceLevels'] is int ? map['numImportanceLevels'] : 3,
      levelNames: parsedLevelNames,
      level2WindowValue: map['level2WindowValue'] is int ? map['level2WindowValue'] : l2Days,
      level2WindowUnit: map['level2WindowUnit'] ?? 'days',
      level3WindowValue: map['level3WindowValue'] is int ? map['level3WindowValue'] : l3Days,
      level3WindowUnit: map['level3WindowUnit'] ?? 'days',
      level2ThresholdDays: l2Days,
      level3ThresholdDays: l3Days,
      twoWayTimeBlocking: map['twoWayTimeBlocking'] != false,
      geminiApiKey: map['geminiApiKey'],
      vacationModeEnabled: map['vacationModeEnabled'] == true,
      vacationStartDate: map['vacationStartDate'] != null ? DateTime.tryParse(map['vacationStartDate']) : null,
      vacationEndDate: map['vacationEndDate'] != null ? DateTime.tryParse(map['vacationEndDate']) : null,
      vacationFrozenChoreIds: map['vacationFrozenChoreIds'] is List ? List<String>.from(map['vacationFrozenChoreIds']) : const [],
      vacationNotificationFilter: map['vacationNotificationFilter'] ?? 'urgent_only',
      notificationsEnabled: map['notificationsEnabled'] != false,
      notifyPriorHours: map['notifyPriorHours'] is int ? map['notifyPriorHours'] : 1,
      notifyForTier: map['notifyForTier'] ?? 'all',
      notifyForOverdue: map['notifyForOverdue'] != false,
      reviewTasksEnabled: map['reviewTasksEnabled'] != false,
      reviewTasksTime: map['reviewTasksTime'] ?? '09:00',
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
