import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/category_item.dart';
import '../../domain/models/recurrence_rule.dart';
import '../../domain/models/user_profile.dart';

class TaskRepository {
  static const _tasksKey = 'app_tasks_v1';
  static const _categoriesKey = 'app_categories_v1';
  static const _rulesKey = 'app_rules_v1';
  static const _profileKey = 'app_profile_v1';

  final SharedPreferences _prefs;

  TaskRepository(this._prefs);

  static Future<TaskRepository> initWithPrefs(SharedPreferences prefs) async {
    final repo = TaskRepository(prefs);
    await repo._ensureInitialData();
    return repo;
  }

  static Future<TaskRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return initWithPrefs(prefs);
  }

  Future<void> _ensureInitialData() async {
    // 1. Initial Categories
    if (!_prefs.containsKey(_categoriesKey)) {
      final defaultCats = CategoryItem.defaultCategories();
      final catJson = json.encode(defaultCats.map((c) => c.toMap()).toList());
      await _prefs.setString(_categoriesKey, catJson);
    }

    // 2. Initial Profile
    if (!_prefs.containsKey(_profileKey)) {
      final defaultProfile = UserProfile.defaultProfile();
      await _prefs.setString(_profileKey, defaultProfile.toJson());
    }

    // 3. Initial Sample Tasks (to showcase overdue, in-progress, L3, L2, L1 right away)
    if (!_prefs.containsKey(_tasksKey)) {
      final now = DateTime.now();
      final sampleTasks = [
        TaskItem(
          id: 'sample_overdue',
          userId: 'user_1',
          title: 'Submit Monthly Expense Report',
          description: 'Attach receipts for travel and software subscriptions.',
          categoryId: 'work',
          baseImportance: 3,
          effectiveImportance: 3,
          dueDate: now.subtract(const Duration(hours: 4)),
          status: TaskStatus.pending,
          isOverdue: true,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        TaskItem(
          id: 'sample_in_prog',
          userId: 'user_1',
          title: 'Draft Project Architecture Blueprint',
          description: 'Finalize database schemas and multiplatform components.',
          categoryId: 'work',
          baseImportance: 3,
          effectiveImportance: 3,
          dueDate: now.add(const Duration(hours: 6)),
          status: TaskStatus.inProgress,
          inProgressAt: now.subtract(const Duration(hours: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        TaskItem(
          id: 'sample_l3',
          userId: 'user_1',
          title: 'Prepare Presentation Slides for Board',
          description: 'Review quarterly goals and team progress.',
          categoryId: 'work',
          baseImportance: 3,
          effectiveImportance: 3,
          dueDate: now.add(const Duration(hours: 18)), // due tomorrow
          status: TaskStatus.pending,
          createdAt: now,
        ),
        TaskItem(
          id: 'sample_l2',
          userId: 'user_1',
          title: 'Renew Passport & Travel Documents',
          description: 'Check photo requirements and schedule consular appointment.',
          categoryId: 'personal',
          baseImportance: 2,
          effectiveImportance: 2,
          dueDate: now.add(const Duration(days: 5)), // due in 5 days
          status: TaskStatus.pending,
          createdAt: now,
        ),
        TaskItem(
          id: 'sample_l1',
          userId: 'user_1',
          title: 'Read System Design Chapter 4',
          description: 'Distributed caches and replication strategies.',
          categoryId: 'study',
          baseImportance: 1,
          effectiveImportance: 1,
          status: TaskStatus.pending,
          createdAt: now,
        ),
      ];

      final tasksJson = json.encode(sampleTasks.map((t) => t.toMap()).toList());
      await _prefs.setString(_tasksKey, tasksJson);
    }

    // 4. Initial Sample Recurring Rules
    if (!_prefs.containsKey(_rulesKey)) {
      final now = DateTime.now();
      final sampleRules = [
        RecurrenceRule(
          id: 'rule_weekly_homework',
          userId: 'user_1',
          title: 'Weekly Homework & Problem Set',
          description: 'Complete problem sets and upload to student portal.',
          type: RecurrenceType.fixedSchedule,
          frequency: ScheduleFrequency.weekly,
          daysOfWeek: [DateTime.wednesday],
          timeOfDay: '18:00',
          baseImportance: 3,
          categoryId: 'study',
          nextDueAt: now.add(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 14)),
        ),
        RecurrenceRule(
          id: 'rule_water_plants',
          userId: 'user_1',
          title: 'Water Balcony Plants',
          description: 'Check soil moisture and add plant food.',
          type: RecurrenceType.intervalAfterCompletion,
          intervalDays: 4,
          baseImportance: 1,
          categoryId: 'personal',
          nextDueAt: now.add(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 20)),
        ),
      ];

      final rulesJson = json.encode(sampleRules.map((r) => r.toMap()).toList());
      await _prefs.setString(_rulesKey, rulesJson);
    }
  }

  // --- Task Methods ---

  List<TaskItem> getTasks() {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((item) => TaskItem.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(_tasksKey, json.encode(list));
  }

  // --- Category Methods ---

  List<CategoryItem> getCategories() {
    final raw = _prefs.getString(_categoriesKey);
    if (raw == null || raw.isEmpty) return CategoryItem.defaultCategories();
    try {
      final list = json.decode(raw) as List;
      return list.map((item) => CategoryItem.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return CategoryItem.defaultCategories();
    }
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    final list = categories.map((c) => c.toMap()).toList();
    await _prefs.setString(_categoriesKey, json.encode(list));
  }

  // --- Recurrence Rule Methods ---

  List<RecurrenceRule> getRecurrenceRules() {
    final raw = _prefs.getString(_rulesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((item) => RecurrenceRule.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecurrenceRules(List<RecurrenceRule> rules) async {
    final list = rules.map((r) => r.toMap()).toList();
    await _prefs.setString(_rulesKey, json.encode(list));
  }

  // --- User Profile & Settings ---

  UserProfile getProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return UserProfile.defaultProfile();
    try {
      return UserProfile.fromJson(raw);
    } catch (_) {
      return UserProfile.defaultProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, profile.toJson());
  }
}
