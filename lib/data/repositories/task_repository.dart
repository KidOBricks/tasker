import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/category_item.dart';
import '../../domain/models/recurrence_rule.dart';
import '../../domain/models/user_profile.dart';
import '../local/app_database.dart';

class TaskRepository {
  final AppDatabase _db;

  String _activeUserId = '';
  List<TaskItem> _tasks = [];
  List<CategoryItem> _categories = [];
  List<RecurrenceRule> _rules = [];
  UserProfile _profile = UserProfile.defaultProfile();

  TaskRepository(this._db);

  AppDatabase get db => _db;
  String get activeUserId => _activeUserId;

  Future<void> loadForUser(
    String userId, {
    String email = '',
    String displayName = '',
    bool seedSampleTasksIfEmpty = false,
    bool seedDefaults = true,
  }) async {
    _activeUserId = userId;
    if (userId.isEmpty) {
      _tasks = [];
      _categories = CategoryItem.defaultCategories();
      _rules = [];
      _profile = UserProfile.defaultProfile();
      return;
    }

    await reloadFromDb(userId);

    if (seedDefaults) {
      await ensureDefaultsIfMissing(email: email, displayName: displayName);
    }

    if (seedSampleTasksIfEmpty && _tasks.isEmpty) {
      await _seedSampleData(userId);
    }
  }

  /// Seeds default categories and profile only when neither local nor cloud data exists.
  /// Returns true if any new records were written to the local outbox.
  Future<bool> ensureDefaultsIfMissing({
    String email = '',
    String displayName = '',
  }) async {
    final uid = _activeUserId;
    if (uid.isEmpty) return false;
    var seeded = false;

    if (_categories.isEmpty) {
      await saveCategories(CategoryItem.defaultCategories());
      seeded = true;
    }

    final existingProfile = await (_db.select(_db.localProfiles)
          ..where((t) => t.userId.equals(uid)))
        .getSingleOrNull();
    if (existingProfile == null) {
      final initialProfile = UserProfile.defaultProfile().copyWith(
        uid: uid,
        email: email,
        displayName: displayName.isNotEmpty
            ? displayName
            : (email.contains('@') ? email.split('@').first : 'User'),
      );
      await saveProfile(initialProfile);
      seeded = true;
    } else if (email.isNotEmpty && _profile.email != email) {
      await saveProfile(_profile.copyWith(
        uid: uid,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : _profile.displayName,
      ));
      seeded = true;
    }
    return seeded;
  }

  Future<void> reloadFromDb(String userId) async {
    if (userId.isEmpty) return;

    final taskRows = await (_db.select(_db.localTasks)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
        .get();
    _tasks = taskRows.map(_rowToTask).toList();

    final catRows = await (_db.select(_db.localCategories)
          ..where((c) => c.userId.equals(userId) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
    _categories = catRows.map(_rowToCategory).toList();

    final ruleRows = await (_db.select(_db.localRecurrenceRules)
          ..where((r) => r.userId.equals(userId) & r.deletedAt.isNull()))
        .get();
    _rules = ruleRows.map(_rowToRule).toList();

    final profileRow = await (_db.select(_db.localProfiles)
          ..where((p) => p.userId.equals(userId)))
        .getSingleOrNull();
    if (profileRow != null) {
      try {
        _profile = UserProfile.fromJson(profileRow.profileJson);
      } catch (_) {
        _profile = UserProfile.defaultProfile().copyWith(uid: userId);
      }
    }
  }

  // --- Synchronous getters backed by per-user hydrated cache ---

  List<TaskItem> getTasks() => List.unmodifiable(_tasks);

  List<CategoryItem> getCategories() =>
      _categories.isEmpty ? CategoryItem.defaultCategories() : List.unmodifiable(_categories);

  List<RecurrenceRule> getRecurrenceRules() => List.unmodifiable(_rules);

  UserProfile getProfile() => _profile;

  // --- Persistence + Sync Outbox mutations ---

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final uid = _activeUserId;
    final previousById = {for (final t in _tasks) t.id: t};
    final previousIds = previousById.keys.toSet();
    final nextIds = tasks.map((t) => t.id).toSet();
    final deletedIds = previousIds.difference(nextIds);
    final now = DateTime.now().toUtc();

    _tasks = List<TaskItem>.from(tasks);
    if (uid.isEmpty) return;

    for (final task in tasks) {
      final normalized = task.userId == uid ? task : task.copyWith(userId: uid);
      final previous = previousById[normalized.id];
      if (previous != null && _sameTaskSyncFields(previous, normalized)) {
        continue;
      }
      await _db.into(_db.localTasks).insertOnConflictUpdate(
            LocalTasksCompanion.insert(
              id: normalized.id,
              userId: uid,
              title: normalized.title,
              description: Value(normalized.description),
              categoryId: Value(normalized.categoryId),
              baseImportance: Value(normalized.baseImportance),
              effectiveImportance: Value(normalized.effectiveImportance),
              dueDate: Value(normalized.dueDate),
              status: Value(normalized.status.asString),
              isOverdue: Value(normalized.isOverdue),
              createdAt: normalized.createdAt,
              completedAt: Value(normalized.completedAt),
              ignoredAt: Value(normalized.ignoredAt),
              inProgressAt: Value(normalized.inProgressAt),
              attachmentPathsJson: Value(json.encode(normalized.attachmentPaths)),
              recurrenceRuleId: Value(normalized.recurrenceRuleId),
              calendarEventId: Value(normalized.calendarEventId),
              emailRefJson: Value(normalized.emailRef != null ? json.encode(normalized.emailRef) : null),
              subtasksJson: Value(json.encode(normalized.subtasks.map((s) => s.toMap()).toList())),
              givenById: Value(normalized.givenById),
              givenByName: Value(normalized.givenByName),
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          );

      await _enqueue(
        userId: uid,
        collectionName: 'tasks',
        recordKey: normalized.id,
        operation: 'upsert',
        payload: {
          ...normalized.toMap(),
          'clientId': normalized.id,
          'clientCreatedAt': normalized.createdAt.toUtc().toIso8601String(),
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': '',
        },
        now: now,
      );
    }

    for (final delId in deletedIds) {
      final prev = previousById[delId];
      await (_db.update(_db.localTasks)
            ..where((t) => t.id.equals(delId) & t.userId.equals(uid)))
          .write(LocalTasksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue(
        userId: uid,
        collectionName: 'tasks',
        recordKey: delId,
        operation: 'delete',
        payload: {
          'clientId': delId,
          if (prev != null) 'title': prev.title,
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': now.toIso8601String(),
        },
        now: now,
      );
    }
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    final uid = _activeUserId;
    final previousById = {for (final c in _categories) c.id: c};
    final previousIds = previousById.keys.toSet();
    final nextIds = categories.map((c) => c.id).toSet();
    final deletedIds = previousIds.difference(nextIds);
    final now = DateTime.now().toUtc();

    _categories = List<CategoryItem>.from(categories);
    if (uid.isEmpty) return;

    for (final cat in categories) {
      await _db.into(_db.localCategories).insertOnConflictUpdate(
            LocalCategoriesCompanion.insert(
              id: cat.id,
              userId: uid,
              name: cat.name,
              colorValue: cat.colorValue,
              iconName: cat.iconName,
              sortOrder: Value(cat.sortOrder),
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          );

      await _enqueue(
        userId: uid,
        collectionName: 'categories',
        recordKey: cat.id,
        operation: 'upsert',
        payload: {
          ...cat.toMap(),
          'clientId': cat.id,
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': '',
        },
        now: now,
      );
    }

    for (final delId in deletedIds) {
      final prev = previousById[delId];
      await (_db.update(_db.localCategories)
            ..where((c) => c.id.equals(delId) & c.userId.equals(uid)))
          .write(LocalCategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue(
        userId: uid,
        collectionName: 'categories',
        recordKey: delId,
        operation: 'delete',
        payload: {
          'clientId': delId,
          if (prev != null) 'name': prev.name,
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': now.toIso8601String(),
        },
        now: now,
      );
    }
  }

  Future<void> saveRecurrenceRules(List<RecurrenceRule> rules) async {
    final uid = _activeUserId;
    final previousById = {for (final r in _rules) r.id: r};
    final previousIds = previousById.keys.toSet();
    final nextIds = rules.map((r) => r.id).toSet();
    final deletedIds = previousIds.difference(nextIds);
    final now = DateTime.now().toUtc();

    _rules = List<RecurrenceRule>.from(rules);
    if (uid.isEmpty) return;

    for (final rule in rules) {
      await _db.into(_db.localRecurrenceRules).insertOnConflictUpdate(
            LocalRecurrenceRulesCompanion.insert(
              id: rule.id,
              userId: uid,
              title: rule.title,
              description: Value(rule.description),
              type: rule.type.asString,
              intervalValue: Value(rule.intervalValue),
              intervalUnit: Value(rule.intervalUnit),
              afterCompletion: Value(rule.afterCompletion),
              frequency: Value(rule.frequency?.asString),
              daysOfWeekJson: Value(json.encode(rule.daysOfWeek)),
              dayOfMonth: Value(rule.dayOfMonth),
              timeOfDay: Value(rule.timeOfDay),
              baseImportance: Value(rule.baseImportance),
              categoryId: Value(rule.categoryId),
              lastMissedDueDate: Value(rule.lastMissedDueDate),
              nextDueAt: rule.nextDueAt,
              isActive: Value(rule.isActive),
              createdAt: rule.createdAt,
              updatedAt: now,
              deletedAt: const Value(null),
            ),
          );

      await _enqueue(
        userId: uid,
        collectionName: 'recurrence_rules',
        recordKey: rule.id,
        operation: 'upsert',
        payload: {
          ...rule.toMap(),
          'clientId': rule.id,
          'clientCreatedAt': rule.createdAt.toUtc().toIso8601String(),
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': '',
        },
        now: now,
      );
    }

    for (final delId in deletedIds) {
      final prev = previousById[delId];
      await (_db.update(_db.localRecurrenceRules)
            ..where((r) => r.id.equals(delId) & r.userId.equals(uid)))
          .write(LocalRecurrenceRulesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _enqueue(
        userId: uid,
        collectionName: 'recurrence_rules',
        recordKey: delId,
        operation: 'delete',
        payload: {
          'clientId': delId,
          if (prev != null) 'title': prev.title,
          'clientUpdatedAt': now.toIso8601String(),
          'deletedAt': now.toIso8601String(),
        },
        now: now,
      );
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final uid = _activeUserId.isNotEmpty ? _activeUserId : profile.uid;
    final normalized = profile.copyWith(uid: uid);
    final now = DateTime.now().toUtc();

    _profile = normalized;
    if (uid.isEmpty) return;

    await _db.into(_db.localProfiles).insertOnConflictUpdate(
          LocalProfilesCompanion.insert(
            userId: uid,
            profileJson: normalized.toJson(),
            updatedAt: now,
          ),
        );

    await _enqueue(
      userId: uid,
      collectionName: 'user_profiles',
      recordKey: uid,
      operation: 'upsert',
      payload: {
        ...normalized.toMap(),
        'clientUpdatedAt': now.toIso8601String(),
      },
      now: now,
    );
  }

  Future<void> _enqueue({
    required String userId,
    required String collectionName,
    required String recordKey,
    required String operation,
    required Map<String, dynamic> payload,
    required DateTime now,
  }) async {
    // Coalesce pending outbox item for same user/collection/record
    await (_db.delete(_db.syncOutbox)
          ..where((o) =>
              o.userId.equals(userId) &
              o.collectionName.equals(collectionName) &
              o.recordKey.equals(recordKey)))
        .go();

    await _db.into(_db.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            userId: userId,
            collectionName: collectionName,
            recordKey: recordKey,
            operation: operation,
            payloadJson: json.encode(payload),
            queuedAt: now,
          ),
        );
  }

  Future<void> _seedSampleData(String userId) async {
    final now = DateTime.now();
    await saveTasks([
      TaskItem(
        id: 'sample_overdue',
        userId: userId,
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
        userId: userId,
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
        userId: userId,
        title: 'Prepare Presentation Slides for Board',
        description: 'Review quarterly goals and team progress.',
        categoryId: 'work',
        baseImportance: 3,
        effectiveImportance: 3,
        dueDate: now.add(const Duration(hours: 18)),
        status: TaskStatus.pending,
        createdAt: now,
      ),
      TaskItem(
        id: 'sample_l2',
        userId: userId,
        title: 'Renew Passport & Travel Documents',
        description: 'Check photo requirements and schedule consular appointment.',
        categoryId: 'personal',
        baseImportance: 2,
        effectiveImportance: 2,
        dueDate: now.add(const Duration(days: 5)),
        status: TaskStatus.pending,
        createdAt: now,
      ),
      TaskItem(
        id: 'sample_l1',
        userId: userId,
        title: 'Read System Design Chapter 4',
        description: 'Distributed caches and replication strategies.',
        categoryId: 'study',
        baseImportance: 1,
        effectiveImportance: 1,
        status: TaskStatus.pending,
        createdAt: now,
      ),
    ]);

    await saveRecurrenceRules([
      RecurrenceRule(
        id: 'rule_weekly_homework',
        userId: userId,
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
        userId: userId,
        title: 'Water Balcony Plants',
        description: 'Check soil moisture and add plant food.',
        type: RecurrenceType.intervalAfterCompletion,
        intervalDays: 4,
        baseImportance: 1,
        categoryId: 'personal',
        nextDueAt: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ]);
  }

  static bool _sameTaskSyncFields(TaskItem a, TaskItem b) {
    if (a.userId != b.userId ||
        a.title != b.title ||
        a.description != b.description ||
        a.categoryId != b.categoryId ||
        a.baseImportance != b.baseImportance ||
        a.status != b.status ||
        a.recurrenceRuleId != b.recurrenceRuleId ||
        a.calendarEventId != b.calendarEventId ||
        a.givenById != b.givenById ||
        a.givenByName != b.givenByName ||
        a.dueDate?.toUtc().millisecondsSinceEpoch != b.dueDate?.toUtc().millisecondsSinceEpoch ||
        a.createdAt.toUtc().millisecondsSinceEpoch != b.createdAt.toUtc().millisecondsSinceEpoch ||
        a.completedAt?.toUtc().millisecondsSinceEpoch != b.completedAt?.toUtc().millisecondsSinceEpoch ||
        a.ignoredAt?.toUtc().millisecondsSinceEpoch != b.ignoredAt?.toUtc().millisecondsSinceEpoch ||
        a.inProgressAt?.toUtc().millisecondsSinceEpoch != b.inProgressAt?.toUtc().millisecondsSinceEpoch) {
      return false;
    }
    if (json.encode(a.attachmentPaths) != json.encode(b.attachmentPaths) ||
        json.encode(a.emailRef) != json.encode(b.emailRef) ||
        json.encode(a.subtasks.map((s) => s.toMap()).toList()) !=
            json.encode(b.subtasks.map((s) => s.toMap()).toList())) {
      return false;
    }
    return true;
  }

  static TaskItem _rowToTask(LocalTask row) {
    List<String> attachments = const [];
    try {
      attachments = (json.decode(row.attachmentPathsJson) as List).cast<String>();
    } catch (_) {}

    Map<String, dynamic>? emailRef;
    if (row.emailRefJson != null && row.emailRefJson!.isNotEmpty) {
      try {
        emailRef = Map<String, dynamic>.from(json.decode(row.emailRefJson!) as Map);
      } catch (_) {}
    }

    List<SubtaskItem> subtasks = const [];
    if (row.subtasksJson.isNotEmpty) {
      try {
        subtasks = (json.decode(row.subtasksJson) as List)
            .whereType<Map>()
            .map((m) => SubtaskItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      } catch (_) {}
    }

    return TaskItem(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      categoryId: row.categoryId,
      baseImportance: row.baseImportance,
      effectiveImportance: row.effectiveImportance,
      dueDate: row.dueDate,
      status: TaskStatus.fromString(row.status),
      isOverdue: row.isOverdue,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      ignoredAt: row.ignoredAt,
      inProgressAt: row.inProgressAt,
      attachmentPaths: attachments,
      recurrenceRuleId: row.recurrenceRuleId,
      calendarEventId: row.calendarEventId,
      emailRef: emailRef,
      subtasks: subtasks,
      givenById: row.givenById,
      givenByName: row.givenByName,
    );
  }

  static CategoryItem _rowToCategory(LocalCategory row) => CategoryItem(
        id: row.id,
        name: row.name,
        colorValue: row.colorValue,
        iconName: row.iconName,
        sortOrder: row.sortOrder,
      );

  static RecurrenceRule _rowToRule(LocalRecurrenceRule row) {
    List<int> days = const [];
    try {
      days = (json.decode(row.daysOfWeekJson) as List).cast<int>();
    } catch (_) {}

    return RecurrenceRule(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      type: RecurrenceType.fromString(row.type),
      intervalValue: row.intervalValue,
      intervalUnit: row.intervalUnit,
      afterCompletion: row.afterCompletion,
      frequency: row.frequency != null ? ScheduleFrequency.fromString(row.frequency) : null,
      daysOfWeek: days,
      dayOfMonth: row.dayOfMonth,
      timeOfDay: row.timeOfDay,
      baseImportance: row.baseImportance,
      categoryId: row.categoryId,
      lastMissedDueDate: row.lastMissedDueDate,
      nextDueAt: row.nextDueAt,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }
}
