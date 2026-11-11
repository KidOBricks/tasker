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

const _uuid = Uuid();

// --- Repository Provider ---
final repositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('Initialize repository in main()');
});

// --- Profile / Settings State ---
class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return ref.watch(repositoryProvider).getProfile();
  }

  Future<void> updateSettings({
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
    return ref.watch(repositoryProvider).getRecurrenceRules();
  }

  Future<void> addRule(RecurrenceRule rule) async {
    final updated = [...state, rule];
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
  }

  Future<void> updateRule(RecurrenceRule rule) async {
    final updated = state.map((r) => r.id == rule.id ? rule : r).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
  }

  Future<void> deleteRule(String ruleId) async {
    final updated = state.where((r) => r.id != ruleId).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
  }

  Future<void> toggleActive(String ruleId) async {
    final updated = state.map((r) {
      if (r.id == ruleId) return r.copyWith(isActive: !r.isActive);
      return r;
    }).toList();
    state = updated;
    await ref.read(repositoryProvider).saveRecurrenceRules(updated);
  }
}

final recurrenceRulesProvider =
    NotifierProvider<RecurrenceRulesNotifier, List<RecurrenceRule>>(RecurrenceRulesNotifier.new);

// --- Task List State ---
class TasksNotifier extends Notifier<List<TaskItem>> {
  @override
  List<TaskItem> build() {
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
    );

    final evaluatedTask = PriorityEngine.evaluate(rawTask, profile, currentTime: now);
    final updated = [...state, evaluatedTask];
    state = updated;
    await ref.read(repositoryProvider).saveTasks(updated);

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
    } else if (historyItem.previousTaskState != null) {
      // Undo completion, ignore, edit -> Restore previous state
      final restored = historyItem.previousTaskState!;
      final updatedList = state.map((t) => t.id == restored.id ? restored : t).toList();
      if (!updatedList.any((t) => t.id == restored.id)) {
        updatedList.add(restored);
      }
      state = updatedList;
      await ref.read(repositoryProvider).saveTasks(updatedList);
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
    final now = DateTime.now();
    return [
      ExtractedTaskSuggestion(
        title: 'Action: Finalize Vendor SOW & Invoicing',
        description: 'Invoice #4928 attached. Due for review by end of week.',
        categoryId: 'work',
        importance: 3,
        suggestedDueDate: now.add(const Duration(days: 2)),
        emailSubject: 'Invoice #4928 Due for Review',
        emailSender: 'billing@cloudvendor.io',
        emailSnippet: 'Please find attached the monthly statement for software licenses.',
      ),
      ExtractedTaskSuggestion(
        title: 'Confirm Flight Check-in for Seattle Trip',
        description: 'Flight DL 1492 departs on Friday at 8:15 AM.',
        categoryId: 'personal',
        importance: 2,
        suggestedDueDate: now.add(const Duration(days: 4)),
        emailSubject: 'Flight Itinerary Confirmation: SEA-SFO',
        emailSender: 'reservations@delta.com',
        emailSnippet: 'Your flight is confirmed. Online check-in opens 24h prior.',
      ),
      ExtractedTaskSuggestion(
        title: 'Submit Distributed Systems Lab 3',
        description: 'Consensus algorithms assignment due on Canvas.',
        categoryId: 'study',
        importance: 3,
        suggestedDueDate: now.add(const Duration(days: 1)),
        emailSubject: 'Reminder: Lab 3 Submission Deadline',
        emailSender: 'prof.chen@cs.university.edu',
        emailSnippet: 'Late submissions will incur a 10% penalty per day.',
      ),
    ];
  }

  void addSuggestion(ExtractedTaskSuggestion suggestion) {
    if (!state.any((s) => s.title == suggestion.title)) {
      state = [...state, suggestion];
    }
  }

  void setSuggestions(List<ExtractedTaskSuggestion> suggestions) {
    state = suggestions;
  }

  void removeSuggestion(ExtractedTaskSuggestion suggestion) {
    state = state.where((s) => s != suggestion).toList();
  }
}

final ideasProvider = NotifierProvider<IdeasNotifier, List<ExtractedTaskSuggestion>>(IdeasNotifier.new);
