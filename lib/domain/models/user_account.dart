import 'dart:convert';

enum UserRole {
  admin,
  user;

  static UserRole fromString(String? val) {
    if (val?.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.user;
  }

  String get asString => this == UserRole.admin ? 'admin' : 'user';
  String get displayName => this == UserRole.admin ? 'Administrator' : 'Standard User';
}

class UserAccount {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int taskCount;

  const UserAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.user,
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
    this.taskCount = 0,
  });

  bool get isAdmin => role == UserRole.admin;

  UserAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? taskCount,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.asString,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'taskCount': taskCount,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: UserRole.fromString(map['role']),
      isActive: map['isActive'] != false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt']) ?? DateTime.now()
          : DateTime.now(),
      taskCount: map['taskCount'] is int ? map['taskCount'] : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAccount.fromJson(String source) =>
      UserAccount.fromMap(json.decode(source));
}
