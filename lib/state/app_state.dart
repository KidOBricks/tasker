import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/task_item.dart';
import '../domain/models/category_item.dart';
import '../domain/models/recurrence_rule.dart';
import '../domain/models/user_profile.dart';
import '../domain/models/task_history_item.dart';
import '../domain/engine/priority_engine.dart';
import '../domain/engine/recurrence_engine.dart';
import '../data/repositories/task_repository.dart';
import '../services/gemini_service.dart';
import 'auth_state.dart';
import 'integration_state.dart';

const _uuid = Uuid();

// --- Repository Provider ---
final repositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('Initialize repository in main()');
});

void _triggerBackgroundSync(Ref ref) {
  final user = ref.read(authProvider);
  if (user == null) return;
  unawaited(ref.read(databaseServiceProvider).performCloudSync(userId: user.id));
}

// --- Profile / Settings State ---
class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    return ref.watch(repositoryProvider).getProfile();
  }

  Future<void> updateSettings({
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
  }) async {
    final updated = state.copyWith(
      displayName: displayName,
      maxInProgressTasks: maxInProgressTasks,
      numImportanceLevels: numImportanceLevels,
      levelNames: levelNames,
      level2WindowValue: level2WindowValue,
      level2WindowUnit: level2WindowUnit,
      level3WindowValue: level3WindowValue,
      level3WindowUnit: level3WindowUnit,
      level2ThresholdDays: level2ThresholdDays,
      level3ThresholdDays: level3ThresholdDays,
      twoWayTimeBlocking: twoWayTimeBlocking,
      geminiApiKey: geminiApiKey,
      vacationModeEnabled: vacationModeEnabled,
      vacationStartDate: vacationStartDate,
      clearVacationStartDate: clearVacationStartDate,
      vacationEndDate: vacationEndDate,
      clearVacationEndDate: clearVacationEndDate,
      vacationFrozenChoreIds: vacationFrozenChoreIds,
      vacationNotificationFilter: vacationNotificationFilter,
      notificationsEnabled: notificationsEnabled,
      notifyPriorHours: notifyPriorHours,
      notifyForTier: notifyForTier,
      notifyForOverdue: notifyForOverdue,
      reviewTasksEnabled: reviewTasksEnabled,
      reviewTasksTime: reviewTasksTime,
      reviewTasksPersistent: reviewTasksPersistent,
      appOpenedToday: appOpenedToday,
    );
    state = updated;
    await ref.read(repositoryProvider).saveProfile(updated);
    _triggerBackgroundSync(ref);
  }

  Future<void> updateLevelName(int level, String name) async {
    final updatedMap = Map<int, String>.from(state.levelNames);
    updatedMap[level] = name;
    await updateSettings(levelNames: updatedMap);
  }

  Future<void> toggleVacationChore(String choreId) async {
    final list = List<String>.from(state.vacationFrozenChoreIds);
    if (list.contains(choreId)) {
      list.remove(choreId);
    } else {
      list.add(choreId);
    }
    await updateSettings(vacationFrozenChoreIds: list);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

// --- Task History State ---
class TaskHistoryNotifier extends Notifier<List<TaskHistoryItem>> {
  @override
  List<TaskHistoryItem> build() {
    ref.watch(authProvider);
    return [];
  }

  void logAction({
    required String taskId,
    required String taskTitle,
    required String action,
    required String description,
    TaskItem? previousState,
    TaskItem? newState,
  }) {
    final item = TaskHistoryItem(
      id: _uuid.v4(),
      taskId: taskId,
      taskTitle: taskTitle,
      action: action,
      description: description,
      timestamp: DateTime.now(),
      previousTaskState: previousState,
      newTaskState: newState,
    );
    state = [item, ...state].take(40).toList(); // keep recent 40 items
  }

  void removeEntry(String historyId) {
    state = state.where((h) => h.id != historyId).toList();
  }
}

final taskHistoryProvider =
    NotifierProvider<TaskHistoryNotifier, List<TaskHistoryItem>>(TaskHistoryNotifier.new);

// --- Categories State ---
class CategoriesNotifier extends Notifier<List<CategoryItem>> {
  @override
  List<CategoryItem> build() {
    ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    return ref.watch(repositoryProvider).getCategories();
  }

  Future<void> addCategory(String name, int colorValue, String iconName) async {
    final newCat = CategoryItem(
      id: 'cat_${_uuid.v4().substring(0, 8)}',
      name: name,
      colorValue: colorValue,
      iconName: iconName,
      sortOrder: state.length,
    );
    final updated = [...state, newCat];
    state = updated;
    await ref.read(repositoryProvider).saveCategories(updated);
    _triggerBackgroundSync(ref);
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<CategoryItem>>(CategoriesNotifier.new);

// --- Active Category Tab State ---
class ActiveCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setCategory(String categoryId) {
    state = categoryId;
  }
}

final activeCategoryTabProvider = NotifierProvider<ActiveCategoryNotifier, String>(ActiveCategoryNotifier.new);

// --- Recurrence Rules State ---
class RecurrenceRulesNotifier extends Notifier<List<RecurrenceRule>> {
  @override
  List<RecurrenceRule> build() {
    ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    return ref.watch(repositoryProvider).getRecurrenceRules();
  }

  Future<void> addRule(RecurrenceRule rule) async {
    final updated = [...state, rule];
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
    _triggerBackgroundSync(ref);
  }

  Future<void> updateRule(RecurrenceRule rule) async {
    final updated = state.map((r) => r.id == rule.id ? rule : r).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
    _triggerBackgroundSync(ref);
  }

  Future<void> deleteRule(String ruleId) async {
    final updated = state.where((r) => r.id != ruleId).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
    _triggerBackgroundSync(ref);
  }

  Future<void> toggleActive(String ruleId) async {
    final updated = state.map((r) {
      if (r.id == ruleId) return r.copyWith(isActive: !r.isActive);
      return r;
    }).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
    _triggerBackgroundSync(ref);
  }
}

final recurrenceRulesProvider =
    NotifierProvider<RecurrenceRulesNotifier, List<RecurrenceRule>>(RecurrenceRulesNotifier.new);

// --- Task List State ---
class TasksNotifier extends Notifier<List<TaskItem>> {
  @override
  List<TaskItem> build() {
    ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    final initial = ref.watch(repositoryProvider).getTasks();
    final profile = ref.watch(profileProvider);
    return initial.map((t) => PriorityEngine.evaluate(t, profile)).toList();
  }

  Future<void> addTask({
    required String title,
    String? description,
    required String categoryId,
    required int baseImportance,
    DateTime? dueDate,
    List<String> attachmentPaths = const [],
    RecurrenceRule? recurrenceRule,
    String? calendarEventId,
    Map<String, dynamic>? emailRef,
  }) async {
    final profile = ref.read(profileProvider);
    final now = DateTime.now();

    String? ruleId;
    if (recurrenceRule != null) {
      ruleId = recurrenceRule.id;
      await ref.read(recurrenceRulesProvider.notifier).addRule(recurrenceRule);
    }

    final rawTask = TaskItem(
      id: _uuid.v4(),
      userId: profile.uid,
      title: title,
      description: description,
      categoryId: categoryId,
      baseImportance: baseImportance,
      effectiveImportance: baseImportance,
      dueDate: dueDate,
      createdAt: now,
      attachmentPaths: attachmentPaths,
      recurrenceRuleId: ruleId,
      calendarEventId: calendarEventId,
      emailRef: emailRef,
    );

    final evaluatedTask = PriorityEngine.evaluate(rawTask, profile, currentTime: now);
    final updated = [...state, evaluatedTask];
    state = updated;
    await ref.read(repositoryProvider).saveTasks(updated);
    _triggerBackgroundSync(ref);

    ref.read(taskHistoryProvider.notifier).logAction(
          taskId: evaluatedTask.id,
          taskTitle: evaluatedTask.title,
          action: 'created',
          description: 'Created new task "${evaluatedTask.title}"',
          previousState: null,
          newState: evaluatedTask,
        );
  }

  Future<void> updateTask(TaskItem updatedTask) async {
    final profile = ref.read(profileProvider);
    final previous = state.firstWhere((t) => t.id == updatedTask.id, orElse: () => updatedTask);
    final evaluated = PriorityEngine.evaluate(updatedTask, profile);
    final updatedList = state.map((t) => t.id == evaluated.id ? evaluated : t).toList();
    state = updatedList;
    await ref.read(repositoryProvider).saveTasks(updatedList);
    _triggerBackgroundSync(ref);

    ref.read(taskHistoryProvider.notifier).logAction(
          taskId: evaluated.id,
          taskTitle: evaluated.title,
          action: 'edited',
          description: 'Updated task details for "${evaluated.title}"',
          previousState: previous,
          newState: evaluated,
        );
  }

  Future<bool> toggleInProgress(String taskId) async {
    final profile = ref.read(profileProvider);
    final currentTask = state.firstWhere((t) => t.id == taskId);

    if (currentTask.isInProgress) {
      final modified = currentTask.copyWith(
        status: TaskStatus.pending,
        clearInProgressAt: true,
      );
      await updateTask(modified);
      return true;
    } else {
      final currentInProgressCount = state.where((t) => t.isInProgress).length;
      if (currentInProgressCount >= profile.maxInProgressTasks) {
        return false;
      }

      final modified = currentTask.copyWith(
        status: TaskStatus.inProgress,
        inProgressAt: DateTime.now(),
      );
      await updateTask(modified);
      return true;
    }
  }

  Future<void> markCompleted(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final rules = ref.read(recurrenceRulesProvider);
    final profile = ref.read(profileProvider);

    if (task.isRecurring) {
      final rule = rules.firstWhere(
        (r) => r.id == task.recurrenceRuleId,
        orElse: () => RecurrenceRule(
          id: task.recurrenceRuleId!,
          userId: task.userId,
          title: task.title,
          type: RecurrenceType.intervalBased,
          baseImportance: task.baseImportance,
          nextDueAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      final result = RecurrenceEngine.handleTaskCompletion(
        task: task,
        rule: rule,
        finalStatus: TaskStatus.completed,
        userProfile: profile,
      );

      var updatedList = state.map((t) => t.id == taskId ? result.archivedTask : t).toList();

      if (result.spawnedTask != null) {
        final evaluatedSpawn = PriorityEngine.evaluate(result.spawnedTask!, profile);
        updatedList.add(evaluatedSpawn);
        await ref.read(recurrenceRulesProvider.notifier).updateRule(result.updatedRule);
      }

      state = updatedList;
      await ref.read(repositoryProvider).saveTasks(updatedList);
      _triggerBackgroundSync(ref);

      ref.read(taskHistoryProvider.notifier).logAction(
            taskId: task.id,
            taskTitle: task.title,
            action: 'completed',
            description: 'Completed recurring task "${task.title}" (Next cycle spawned)',
            previousState: task,
            newState: result.archivedTask,
          );
    } else {
      final completed = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        clearInProgressAt: true,
      );
      await updateTask(completed);
    }
  }

  Future<void> markIgnored(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final rules = ref.read(recurrenceRulesProvider);
    final profile = ref.read(profileProvider);

    if (task.isRecurring) {
      final rule = rules.firstWhere((r) => r.id == task.recurrenceRuleId!);
      final result = RecurrenceEngine.handleTaskCompletion(
        task: task,
        rule: rule,
        finalStatus: TaskStatus.ignored,
        userProfile: profile,
      );

      var updatedList = state.map((t) => t.id == taskId ? result.archivedTask : t).toList();
      if (result.spawnedTask != null) {
        final evaluatedSpawn = PriorityEngine.evaluate(result.spawnedTask!, profile);
        updatedList.add(evaluatedSpawn);
        await ref.read(recurrenceRulesProvider.notifier).updateRule(result.updatedRule);
      }
      state = updatedList;
      await ref.read(repositoryProvider).saveTasks(updatedList);
      _triggerBackgroundSync(ref);

      ref.read(taskHistoryProvider.notifier).logAction(
            taskId: task.id,
            taskTitle: task.title,
            action: 'ignored',
            description: 'Ignored task "${task.title}" (Dismissed without completion)',
            previousState: task,
            newState: result.archivedTask,
          );
    } else {
      final ignored = task.copyWith(
        status: TaskStatus.ignored,
        ignoredAt: DateTime.now(),
        clearInProgressAt: true,
      );
      await updateTask(ignored);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = state.where((t) => t.id != taskId).toList();
    state = updated;
    await ref.read(repositoryProvider).saveTasks(updated);
    _triggerBackgroundSync(ref);

    ref.read(taskHistoryProvider.notifier).logAction(
          taskId: task.id,
          taskTitle: task.title,
          action: 'deleted',
          description: 'Deleted task "${task.title}"',
          previousState: task,
          newState: null,
        );
  }

  /// Reverses an action from the history log
  Future<void> undoHistoryAction(String historyId) async {
    final historyList = ref.read(taskHistoryProvider);
    final historyItem = historyList.firstWhere((h) => h.id == historyId, orElse: () => throw Exception('Not found'));

    if (historyItem.action == 'created') {
      // Undo creation -> Delete the task
      await deleteTask(historyItem.taskId);
    } else if (historyItem.action == 'deleted' && historyItem.previousTaskState != null) {
      // Undo deletion -> Re-insert the previous task
      final restored = historyItem.previousTaskState!;
      state = [...state, restored];
      await ref.read(repositoryProvider).saveTasks(state);
      _triggerBackgroundSync(ref);
    } else if (historyItem.previousTaskState != null) {
      // Undo completion, ignore, edit -> Restore previous state
      final restored = historyItem.previousTaskState!;
      final updatedList = state.map((t) => t.id == restored.id ? restored : t).toList();
      if (!updatedList.any((t) => t.id == restored.id)) {
        updatedList.add(restored);
      }
      state = updatedList;
      await ref.read(repositoryProvider).saveTasks(updatedList);
      _triggerBackgroundSync(ref);
    }

    ref.read(taskHistoryProvider.notifier).removeEntry(historyId);
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<TaskItem>>(TasksNotifier.new);

// --- Sectioned & Filtered Task Groups (Home Screen) ---
class SectionedTasks {
  final List<TaskItem> overdueTasks;
  final List<TaskItem> inProgressTasks;
  final Map<int, List<TaskItem>> levelTasks; // e.g. 5, 4, 3, 2, 1

  // Convenience getters for standard levels
  List<TaskItem> get level3Tasks => levelTasks[3] ?? const [];
  List<TaskItem> get level2Tasks => levelTasks[2] ?? const [];
  List<TaskItem> get level1Tasks => levelTasks[1] ?? const [];

  const SectionedTasks({
    required this.overdueTasks,
    required this.inProgressTasks,
    required this.levelTasks,
  });
}

final sectionedTasksProvider = Provider<SectionedTasks>((ref) {
  final allTasks = ref.watch(tasksProvider);
  final activeCat = ref.watch(activeCategoryTabProvider);
  final profile = ref.watch(profileProvider);
  final now = DateTime.now();

  var activeTasks = allTasks.where((t) => !t.isCompleted && !t.isIgnored).toList();

  if (activeCat != 'all') {
    activeTasks = activeTasks.where((t) => t.categoryId == activeCat).toList();
  }

  final evaluated = activeTasks.map((t) => PriorityEngine.evaluate(t, profile, currentTime: now)).toList();

  final overdue = PriorityEngine.sortByUrgency(evaluated.where((t) => t.isOverdue).toList());
  final inProgress = PriorityEngine.sortByUrgency(evaluated.where((t) => t.isInProgress).toList());

  final Map<int, List<TaskItem>> levelsMap = {};
  for (int lvl = 1; lvl <= profile.numImportanceLevels; lvl++) {
    levelsMap[lvl] = PriorityEngine.sortByUrgency(
      evaluated.where((t) => !t.isOverdue && t.effectiveImportance == lvl).toList(),
    );
  }

  return SectionedTasks(
    overdueTasks: overdue,
    inProgressTasks: inProgress,
    levelTasks: levelsMap,
  );
});

// --- Ideas Tab Task Suggestions State ---
class IdeasNotifier extends Notifier<List<ExtractedTaskSuggestion>> {
  @override
  List<ExtractedTaskSuggestion> build() {
    final user = ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    if (user == null) {
      return const [];
    }
    Future.microtask(refreshSuggestions);
    return const [];
  }

  Future<void> refreshSuggestions() async {
    final user = ref.read(authProvider);
    if (user == null) {
      state = const [];
      return;
    }
    final emailService = ref.read(emailIntegrationServiceProvider);
    final pending = await emailService.getPendingSuggestions(userId: user.id);
    state = pending;
  }

  Future<int> scanInbox() async {
    final user = ref.read(authProvider);
    if (user == null) return 0;
    final emailService = ref.read(emailIntegrationServiceProvider);
    await emailService.triggerInboxScan();
    await ref.read(databaseServiceProvider).performCloudSync(userId: user.id);
    await refreshSuggestions();
    return state.length;
  }

  Future<void> markSuggestionStatus(ExtractedTaskSuggestion suggestion, String status) async {
    final user = ref.read(authProvider);
    state = state.where((s) => s != suggestion).toList();
    if (user != null) {
      await ref.read(emailIntegrationServiceProvider).updateSuggestionStatus(
            userId: user.id,
            suggestion: suggestion,
            status: status,
          );
    }
  }

  Future<void> acceptSuggestion(ExtractedTaskSuggestion suggestion) =>
      markSuggestionStatus(suggestion, 'accepted');

  Future<void> dismissSuggestion(ExtractedTaskSuggestion suggestion) =>
      markSuggestionStatus(suggestion, 'dismissed');
}

final ideasProvider = NotifierProvider<IdeasNotifier, List<ExtractedTaskSuggestion>>(IdeasNotifier.new);

