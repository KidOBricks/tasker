import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../local/app_database.dart';
import '../repositories/task_repository.dart';

enum SyncStatus {
  synced,
  syncing,
  offline,
  error;

  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Cloud Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline Cache';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }
}

class TaskGivenAlert {
  final String taskId;
  final String title;
  final String giverName;

  const TaskGivenAlert({
    required this.taskId,
    required this.title,
    required this.giverName,
  });
}

class DatabaseService {
  final PocketBase _pb;
  final AppDatabase _db;
  final TaskRepository _repo;
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _dataUpdatedController = StreamController<int>.broadcast();
  final _taskGivenController = StreamController<TaskGivenAlert>.broadcast();

  SyncStatus _currentStatus = SyncStatus.offline;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  bool _resyncQueued = false;
  String? _queuedUserId;
  Future<void>? _activeSyncFuture;
  int _dataRevision = 0;
  Timer? _debounceTimer;
  Timer? _retryTimer;
  final List<UnsubscribeFunc> _unsubscribers = [];

  DatabaseService(this._pb, this._db, this._repo) {
    _syncStatusController.add(_currentStatus);
  }

  SyncStatus get status => _currentStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get serverUrl => _pb.baseURL;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<int> get dataUpdatedStream => _dataUpdatedController.stream;
  Stream<TaskGivenAlert> get taskGivenStream => _taskGivenController.stream;

  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }

  /// Two-way PocketBase <-> Drift synchronization with Last-Write-Wins (updatedAt).
  Future<void> performCloudSync({String? userId}) {
    final activeUserId = userId ?? _repo.activeUserId;
    if (activeUserId.isEmpty || !_pb.authStore.isValid) {
      _setStatus(SyncStatus.offline);
      return Future.value();
    }
    if (_isSyncing) {
      _resyncQueued = true;
      _queuedUserId = activeUserId;
      return _activeSyncFuture ?? Future.value();
    }

    final future = _runSyncLoop(activeUserId);
    _activeSyncFuture = future;
    return future;
  }

  Future<void> _runSyncLoop(String initialUserId) async {
    _isSyncing = true;
    _retryTimer?.cancel();
    _setStatus(SyncStatus.syncing);
    var currentUserId = initialUserId;

    try {
      while (true) {
        _resyncQueued = false;
        await _pushOutbox(currentUserId);
        await _pullCollections(currentUserId);
        await _repo.reloadFromDb(currentUserId);

        _lastSyncTime = DateTime.now();
        _setStatus(SyncStatus.synced);
        if (!_dataUpdatedController.isClosed) {
          _dataUpdatedController.add(++_dataRevision);
        }

        if (!_resyncQueued) break;
        currentUserId = _queuedUserId ?? currentUserId;
      }
    } catch (e) {
      debugPrint('PocketBase sync error: $e');
      _setStatus(SyncStatus.offline);
      _scheduleRetryIfOutboxNonEmpty(currentUserId);
    } finally {
      _isSyncing = false;
      _resyncQueued = false;
      _queuedUserId = null;
      _activeSyncFuture = null;
    }
  }

  Future<void> _scheduleRetryIfOutboxNonEmpty(String userId) async {
    if (!_pb.authStore.isValid || _syncStatusController.isClosed) return;
    final pending = await (_db.select(_db.syncOutbox)
          ..where((o) => o.userId.equals(userId))
          ..limit(1))
        .get();
    if (pending.isEmpty || _syncStatusController.isClosed) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      if (!_syncStatusController.isClosed) {
        unawaited(performCloudSync(userId: userId));
      }
    });
  }

  Future<void> startRealtimeSync(String userId) async {
    await stopRealtimeSync();
    if (userId.isEmpty || !_pb.authStore.isValid) return;

    const collections = [
      'tasks',
      'categories',
      'recurrence_rules',
      'user_profiles',
      'external_events',
      'task_suggestions',
    ];

    for (final col in collections) {
      try {
        final unsub = await _pb.collection(col).subscribe('*', (e) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 350), () {
            performCloudSync(userId: userId);
          });
        });
        _unsubscribers.add(unsub);
      } catch (e) {
        debugPrint('Realtime subscribe skipped for $col: $e');
      }
    }
  }

  Future<void> stopRealtimeSync() async {
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    for (final unsub in _unsubscribers) {
      try {
        await unsub();
      } catch (_) {}
    }
    _unsubscribers.clear();
  }

  Future<void> _pushOutbox(String userId) async {
    final items = await (_db.select(_db.syncOutbox)
          ..where((o) => o.userId.equals(userId))
          ..orderBy([(o) => OrderingTerm.asc(o.id)]))
        .get();

    for (final item in items) {
      final payload = json.decode(item.payloadJson) as Map<String, dynamic>;
      await _pushSingleRecord(userId, item.collectionName, item.recordKey, payload);
      await (_db.delete(_db.syncOutbox)..where((o) => o.id.equals(item.id))).go();
    }
  }

  Future<void> _pushSingleRecord(
    String userId,
    String collection,
    String recordKey,
    Map<String, dynamic> payload,
  ) async {
    final body = _buildRemoteBody(userId, collection, recordKey, payload);
    final filter = collection == 'user_profiles'
        ? 'user = "${_escapeFilter(userId)}"'
        : 'user = "${_escapeFilter(userId)}" && clientId = "${_escapeFilter(recordKey)}"';

    RecordModel? existing;
    try {
      existing = await _pb.collection(collection).getFirstListItem(filter);
    } on ClientException catch (e) {
      if (e.statusCode != 404) rethrow;
    }

    if (existing != null) {
      await _pb.collection(collection).update(existing.id, body: body);
    } else {
      await _pb.collection(collection).create(body: body);
    }
  }

  Map<String, dynamic> _buildRemoteBody(
    String userId,
    String collection,
    String recordKey,
    Map<String, dynamic> payload,
  ) {
    switch (collection) {
      case 'tasks':
        return {
          'user': userId,
          'clientId': recordKey,
          'title': payload['title'] ?? '',
          'description': payload['description'] ?? '',
          'categoryId': payload['categoryId'] ?? 'all',
          'baseImportance': payload['baseImportance'] ?? 1,
          'effectiveImportance': payload['effectiveImportance'] ?? 1,
          'dueDate': payload['dueDate'] ?? '',
          'status': payload['status'] ?? 'pending',
          'isOverdue': payload['isOverdue'] == true,
          'clientCreatedAt': payload['clientCreatedAt'] ?? payload['createdAt'] ?? '',
          'completedAt': payload['completedAt'] ?? '',
          'ignoredAt': payload['ignoredAt'] ?? '',
          'inProgressAt': payload['inProgressAt'] ?? '',
          'attachmentPaths': payload['attachmentPaths'] ?? const [],
          'recurrenceRuleId': payload['recurrenceRuleId'] ?? '',
          'calendarEventId': payload['calendarEventId'] ?? '',
          'emailRef': payload['emailRef'],
          'subtasks': payload['subtasks'] ?? const [],
          'givenById': payload['givenById'] ?? '',
          'givenByName': payload['givenByName'] ?? '',
          'clientUpdatedAt': payload['clientUpdatedAt'] ?? DateTime.now().toUtc().toIso8601String(),
          'deletedAt': payload['deletedAt'] ?? '',
        };
      case 'categories':
        return {
          'user': userId,
          'clientId': recordKey,
          'name': payload['name'] ?? '',
          'colorValue': payload['colorValue'] ?? 0,
          'iconName': payload['iconName'] ?? 'folder',
          'sortOrder': payload['sortOrder'] ?? 0,
          'clientUpdatedAt': payload['clientUpdatedAt'] ?? DateTime.now().toUtc().toIso8601String(),
          'deletedAt': payload['deletedAt'] ?? '',
        };
      case 'recurrence_rules':
        return {
          'user': userId,
          'clientId': recordKey,
          'title': payload['title'] ?? '',
          'description': payload['description'] ?? '',
          'type': payload['type'] ?? 'interval_based',
          'intervalValue': payload['intervalValue'] ?? 3,
          'intervalUnit': payload['intervalUnit'] ?? 'days',
          'afterCompletion': payload['afterCompletion'] != false,
          'frequency': payload['frequency'] ?? '',
          'daysOfWeek': payload['daysOfWeek'] ?? const [],
          'dayOfMonth': payload['dayOfMonth'] ?? 0,
          'timeOfDay': payload['timeOfDay'] ?? '18:00',
          'baseImportance': payload['baseImportance'] ?? 1,
          'categoryId': payload['categoryId'] ?? 'all',
          'lastMissedDueDate': payload['lastMissedDueDate'] ?? '',
          'nextDueAt': payload['nextDueAt'] ?? DateTime.now().toUtc().toIso8601String(),
          'isActive': payload['isActive'] != false,
          'clientCreatedAt': payload['clientCreatedAt'] ?? payload['createdAt'] ?? '',
          'clientUpdatedAt': payload['clientUpdatedAt'] ?? DateTime.now().toUtc().toIso8601String(),
          'deletedAt': payload['deletedAt'] ?? '',
        };
      case 'user_profiles':
        return {
          'user': userId,
          'displayName': payload['displayName'] ?? '',
          'maxInProgressTasks': payload['maxInProgressTasks'] ?? 3,
          'numImportanceLevels': payload['numImportanceLevels'] ?? 3,
          'levelNames': payload['levelNames'] ?? const {},
          'level2WindowValue': payload['level2WindowValue'] ?? 7,
          'level2WindowUnit': payload['level2WindowUnit'] ?? 'days',
          'level3WindowValue': payload['level3WindowValue'] ?? 1,
          'level3WindowUnit': payload['level3WindowUnit'] ?? 'days',
          'twoWayTimeBlocking': payload['twoWayTimeBlocking'] == true,
          'vacationModeEnabled': payload['vacationModeEnabled'] == true,
          'vacationStartDate': payload['vacationStartDate'] ?? '',
          'vacationEndDate': payload['vacationEndDate'] ?? '',
          'vacationFrozenChoreIds': payload['vacationFrozenChoreIds'] ?? const [],
          'vacationNotificationFilter': payload['vacationNotificationFilter'] ?? 'urgent_only',
          'notificationsEnabled': payload['notificationsEnabled'] != false,
          'notifyPriorHours': payload['notifyPriorHours'] ?? 1,
          'notifyPriorMinutes': payload['notifyPriorMinutes'] ?? ((payload['notifyPriorHours'] ?? 1) * 60),
          'notifyForTier': payload['notifyForTier'] ?? 'all',
          'notifyForOverdue': payload['notifyForOverdue'] != false,
          'reviewTasksEnabled': payload['reviewTasksEnabled'] != false,
          'reviewTasksTime': payload['reviewTasksTime'] ?? '09:00',
          'reviewTasksPersistent': payload['reviewTasksPersistent'] != false,
          'clientUpdatedAt': payload['clientUpdatedAt'] ?? DateTime.now().toUtc().toIso8601String(),
        };
      default:
        return payload;
    }
  }

  Future<void> _pullCollections(String userId) async {
    final filter = 'user = "${_escapeFilter(userId)}"';

    // 1. Categories
    final remoteCats = await _pb.collection('categories').getFullList(filter: filter);
    for (final rec in remoteCats) {
      final clientId = rec.get<String>('clientId', rec.id);
      final remoteUpdated = _parseRemoteUpdated(rec);
      final local = await (_db.select(_db.localCategories)
            ..where((c) => c.id.equals(clientId) & c.userId.equals(userId)))
          .getSingleOrNull();
      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        final delStr = rec.get<String>('deletedAt', '');
        await _db.into(_db.localCategories).insertOnConflictUpdate(
              LocalCategoriesCompanion.insert(
                id: clientId,
                pbId: Value(rec.id),
                userId: userId,
                name: rec.get<String>('name', ''),
                colorValue: rec.get<num>('colorValue', 0xFF6366F1).toInt(),
                iconName: rec.get<String>('iconName', 'folder'),
                sortOrder: Value(rec.get<num>('sortOrder', 0).toInt()),
                updatedAt: remoteUpdated,
                deletedAt: Value(delStr.isNotEmpty ? DateTime.tryParse(delStr) : null),
              ),
            );
      }
    }

    // 2. Recurrence Rules
    final remoteRules = await _pb.collection('recurrence_rules').getFullList(filter: filter);
    for (final rec in remoteRules) {
      final clientId = rec.get<String>('clientId', rec.id);
      final remoteUpdated = _parseRemoteUpdated(rec);
      final local = await (_db.select(_db.localRecurrenceRules)
            ..where((r) => r.id.equals(clientId) & r.userId.equals(userId)))
          .getSingleOrNull();
      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        final delStr = rec.get<String>('deletedAt', '');
        final daysRaw = rec.data['daysOfWeek'];
        final dayOfMonthVal = rec.get<num>('dayOfMonth', 0).toInt();
        await _db.into(_db.localRecurrenceRules).insertOnConflictUpdate(
              LocalRecurrenceRulesCompanion.insert(
                id: clientId,
                pbId: Value(rec.id),
                userId: userId,
                title: rec.get<String>('title', ''),
                description: Value(_emptyToNull(rec.get<String>('description', ''))),
                type: rec.get<String>('type', 'interval_based'),
                intervalValue: Value(rec.get<num>('intervalValue', 3).toInt()),
                intervalUnit: Value(rec.get<String>('intervalUnit', 'days')),
                afterCompletion: Value(rec.get<bool>('afterCompletion', true)),
                frequency: Value(_emptyToNull(rec.get<String>('frequency', ''))),
                daysOfWeekJson: Value(json.encode(daysRaw is List ? daysRaw : const [])),
                dayOfMonth: Value(dayOfMonthVal > 0 ? dayOfMonthVal : null),
                timeOfDay: Value(rec.get<String>('timeOfDay', '18:00')),
                baseImportance: Value(rec.get<num>('baseImportance', 1).toInt()),
                categoryId: Value(rec.get<String>('categoryId', 'all')),
                lastMissedDueDate: Value(DateTime.tryParse(rec.get<String>('lastMissedDueDate', ''))),
                nextDueAt: DateTime.tryParse(rec.get<String>('nextDueAt', '')) ?? DateTime.now(),
                isActive: Value(rec.get<bool>('isActive', true)),
                createdAt: DateTime.tryParse(rec.get<String>('clientCreatedAt', '')) ?? DateTime.now(),
                updatedAt: remoteUpdated,
                deletedAt: Value(delStr.isNotEmpty ? DateTime.tryParse(delStr) : null),
              ),
            );
      }
    }

    // 3. Tasks
    final remoteTasks = await _pb.collection('tasks').getFullList(filter: filter);
    final pendingTaskKeys = await _pendingOutboxKeys(userId, 'tasks');
    for (final rec in remoteTasks) {
      final clientId = rec.get<String>('clientId', rec.id);
      if (pendingTaskKeys.contains(clientId)) continue;
      final remoteUpdated = _parseRemoteUpdated(rec);
      final local = await (_db.select(_db.localTasks)
            ..where((t) => t.id.equals(clientId) & t.userId.equals(userId)))
          .getSingleOrNull();
      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        final delStr = rec.get<String>('deletedAt', '');
        final attachRaw = rec.data['attachmentPaths'];
        final emailRefRaw = rec.data['emailRef'];
        final subtasksRaw = rec.data['subtasks'];
        final givenById = _emptyToNull(rec.get<String>('givenById', ''));
        final givenByName = _emptyToNull(rec.get<String>('givenByName', ''));
        final title = rec.get<String>('title', '');
        final status = rec.get<String>('status', 'pending');

        await _db.into(_db.localTasks).insertOnConflictUpdate(
              LocalTasksCompanion.insert(
                id: clientId,
                pbId: Value(rec.id),
                userId: userId,
                title: title,
                description: Value(_emptyToNull(rec.get<String>('description', ''))),
                categoryId: Value(rec.get<String>('categoryId', 'all')),
                baseImportance: Value(rec.get<num>('baseImportance', 1).toInt()),
                effectiveImportance: Value(rec.get<num>('effectiveImportance', 1).toInt()),
                dueDate: Value(DateTime.tryParse(rec.get<String>('dueDate', ''))),
                status: Value(status),
                isOverdue: Value(rec.get<bool>('isOverdue', false)),
                createdAt: DateTime.tryParse(rec.get<String>('clientCreatedAt', '')) ?? DateTime.now(),
                completedAt: Value(DateTime.tryParse(rec.get<String>('completedAt', ''))),
                ignoredAt: Value(DateTime.tryParse(rec.get<String>('ignoredAt', ''))),
                inProgressAt: Value(DateTime.tryParse(rec.get<String>('inProgressAt', ''))),
                attachmentPathsJson: Value(json.encode(attachRaw is List ? attachRaw : const [])),
                recurrenceRuleId: Value(_emptyToNull(rec.get<String>('recurrenceRuleId', ''))),
                calendarEventId: Value(_emptyToNull(rec.get<String>('calendarEventId', ''))),
                emailRefJson: Value(emailRefRaw is Map ? json.encode(emailRefRaw) : null),
                subtasksJson: Value(json.encode(subtasksRaw is List ? subtasksRaw : const [])),
                givenById: Value(givenById),
                givenByName: Value(givenByName),
                updatedAt: remoteUpdated,
                deletedAt: Value(delStr.isNotEmpty ? DateTime.tryParse(delStr) : null),
              ),
            );
        if (local == null && delStr.isEmpty && givenById != null && status == 'pending' && !_taskGivenController.isClosed) {
          _taskGivenController.add(TaskGivenAlert(
            taskId: clientId,
            title: title,
            giverName: givenByName ?? 'Trusted taskgiver',
          ));
        }
      }
    }

    // 4. User Profile
    final remoteProfiles = await _pb.collection('user_profiles').getFullList(filter: filter);
    if (remoteProfiles.isNotEmpty) {
      final rec = remoteProfiles.first;
      final remoteUpdated = _parseRemoteUpdated(rec);
      final local = await (_db.select(_db.localProfiles)
            ..where((p) => p.userId.equals(userId)))
          .getSingleOrNull();
      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        final merged = {
          ...rec.data,
          'uid': userId,
          'email': _pb.authStore.record?.get<String>('email', '') ?? '',
        };
        await _db.into(_db.localProfiles).insertOnConflictUpdate(
              LocalProfilesCompanion.insert(
                userId: userId,
                pbId: Value(rec.id),
                profileJson: json.encode(merged),
                updatedAt: remoteUpdated,
              ),
            );
      }
    }

    // 5. External Calendar Events (sync + prune deselected calendar events)
    final remoteEvents = await _pb.collection('external_events').getFullList(filter: filter);
    final remoteCompositeIds = <String>{};
    for (final rec in remoteEvents) {
      final extId = rec.get<String>('externalId', rec.id);
      final source = rec.get<String>('source', 'google');
      final compositeId = '$userId::$source::$extId';
      remoteCompositeIds.add(compositeId);
      final attendeesRaw = rec.data['attendees'];
      await _db.into(_db.localExternalEvents).insertOnConflictUpdate(
            LocalExternalEventsCompanion.insert(
              id: compositeId,
              pbId: Value(rec.id),
              userId: userId,
              externalId: extId,
              source: source,
              title: rec.get<String>('title', ''),
              startTime: DateTime.tryParse(rec.get<String>('startTime', '')) ?? DateTime.now(),
              endTime: DateTime.tryParse(rec.get<String>('endTime', '')) ?? DateTime.now(),
              location: Value(rec.get<String>('location', '')),
              description: Value(rec.get<String>('description', '')),
              meetingUrl: Value(_emptyToNull(rec.get<String>('meetingUrl', ''))),
              attendeesJson: Value(json.encode(attendeesRaw is List ? attendeesRaw : const [])),
              hasLinkedTask: Value(rec.get<bool>('hasLinkedTask', false)),
              updatedAt: _parseRemoteUpdated(rec),
            ),
          );
    }
    final localEvents = await (_db.select(_db.localExternalEvents)
          ..where((e) => e.userId.equals(userId)))
        .get();
    for (final localEv in localEvents) {
      if (!remoteCompositeIds.contains(localEv.id)) {
        await (_db.delete(_db.localExternalEvents)..where((e) => e.id.equals(localEv.id))).go();
      }
    }

    // 6. Task Suggestions (Gmail AI)
    final remoteSuggestions = await _pb.collection('task_suggestions').getFullList(filter: filter);
    for (final rec in remoteSuggestions) {
      final emailId = rec.get<String>('emailId', rec.id);
      final compositeId = '$userId::$emailId';
      await _db.into(_db.localTaskSuggestions).insertOnConflictUpdate(
            LocalTaskSuggestionsCompanion.insert(
              id: compositeId,
              pbId: Value(rec.id),
              userId: userId,
              emailId: emailId,
              sender: rec.get<String>('sender', ''),
              subject: rec.get<String>('subject', ''),
              snippet: rec.get<String>('snippet', ''),
              receivedAt: DateTime.tryParse(rec.get<String>('receivedAt', '')) ?? DateTime.now(),
              title: rec.get<String>('title', ''),
              description: rec.get<String>('description', ''),
              categoryId: Value(rec.get<String>('categoryId', 'work')),
              importance: Value(rec.get<num>('importance', 2).toInt()),
              suggestedDueDate: Value(DateTime.tryParse(rec.get<String>('suggestedDueDate', ''))),
              status: Value(rec.get<String>('status', 'pending')),
              updatedAt: _parseRemoteUpdated(rec),
            ),
          );
    }
  }

  void setOfflineMode(bool offline) {
    _setStatus(offline ? SyncStatus.offline : SyncStatus.synced);
  }

  void dispose() {
    stopRealtimeSync();
    _syncStatusController.close();
    _dataUpdatedController.close();
    _taskGivenController.close();
  }

  Future<Set<String>> _pendingOutboxKeys(String userId, String collection) async {
    final rows = await (_db.select(_db.syncOutbox)
          ..where((o) => o.userId.equals(userId) & o.collectionName.equals(collection)))
        .get();
    return rows.map((r) => r.recordKey).toSet();
  }

  static DateTime _parseRemoteUpdated(RecordModel rec) {
    final clientUpdated = rec.get<String>('clientUpdatedAt', '');
    if (clientUpdated.isNotEmpty) {
      final dt = DateTime.tryParse(clientUpdated);
      if (dt != null) return dt.toUtc();
    }
    final pbUpdated = rec.get<String>('updated', '');
    return DateTime.tryParse(pbUpdated)?.toUtc() ?? DateTime.now().toUtc();
  }

  static String? _emptyToNull(String val) => val.isEmpty ? null : val;

  static String _escapeFilter(String input) => input.replaceAll('"', '\\"');
}
