import 'dart:convert';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int maxInProgressTasks;
  final int numImportanceLevels;
  final int level2ThresholdDays;
  final int level3ThresholdDays;
  final bool twoWayTimeBlocking;
  final String? geminiApiKey;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.maxInProgressTasks = 3,
    this.numImportanceLevels = 3,
    this.level2ThresholdDays = 7,
    this.level3ThresholdDays = 1,
    this.twoWayTimeBlocking = true,
    this.geminiApiKey,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? maxInProgressTasks,
    int? numImportanceLevels,
    int? level2ThresholdDays,
    int? level3ThresholdDays,
    bool? twoWayTimeBlocking,
    String? geminiApiKey,
    bool clearGeminiApiKey = false,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      maxInProgressTasks: maxInProgressTasks ?? this.maxInProgressTasks,
      numImportanceLevels: numImportanceLevels ?? this.numImportanceLevels,
      level2ThresholdDays: level2ThresholdDays ?? this.level2ThresholdDays,
      level3ThresholdDays: level3ThresholdDays ?? this.level3ThresholdDays,
      twoWayTimeBlocking: twoWayTimeBlocking ?? this.twoWayTimeBlocking,
      geminiApiKey: clearGeminiApiKey ? null : (geminiApiKey ?? this.geminiApiKey),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'maxInProgressTasks': maxInProgressTasks,
      'numImportanceLevels': numImportanceLevels,
      'level2ThresholdDays': level2ThresholdDays,
      'level3ThresholdDays': level3ThresholdDays,
      'twoWayTimeBlocking': twoWayTimeBlocking,
      'geminiApiKey': geminiApiKey,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? 'default_user',
      email: map['email'] ?? 'user@antigravity.dev',
      displayName: map['displayName'] ?? 'Antigravity User',
      maxInProgressTasks: map['maxInProgressTasks'] is int ? map['maxInProgressTasks'] : 3,
      numImportanceLevels: map['numImportanceLevels'] is int ? map['numImportanceLevels'] : 3,
      level2ThresholdDays: map['level2ThresholdDays'] is int ? map['level2ThresholdDays'] : 7,
      level3ThresholdDays: map['level3ThresholdDays'] is int ? map['level3ThresholdDays'] : 1,
      twoWayTimeBlocking: map['twoWayTimeBlocking'] != false,
      geminiApiKey: map['geminiApiKey'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  static UserProfile defaultProfile() {
    return const UserProfile(
      uid: 'user_1',
      email: 'user@example.com',
      displayName: 'Alex Morgan',
    );
  }
}
