# Bug Diagnosis & Fix Plan (2026-11-19)

## Bug 1: Task Deletion Breaks Cloud Sync

### Observed Symptom
- Deleting a task (on Android or Web) causes cloud sync to break.
- The header/sidebar stays stuck on **Offline Cache**, no updates sync to or from the cloud, and tapping **Sync now** still reports `"Cloud sync complete"`.
- Undoing the task deletion immediately restores cloud sync.

### Root Cause
1. **Poisoned `sync_outbox` payload**: `TaskRepository.saveTasks()` (`lib/data/repositories/task_repository.dart`) enqueues `operation: 'delete'` with only `{clientId, clientUpdatedAt, deletedAt}` — omitting `title`. (`saveCategories()` and `saveRecurrenceRules()` had the same omission for `name` / `title` / `nextDueAt`.)
2. **PocketBase required-field rejection**: `DatabaseService._pushSingleRecord()` (`lib/data/services/database_service.dart`) always runs `_buildRemoteBody()`, which fills `'title': payload['title'] ?? ''`. Because PocketBase marks `tasks.title` as `Required: true` (`backend/internal/schema/bootstrap.go`), PocketBase rejects the request with `400 Bad Request` (`title: Cannot be blank`).
3. **Silent failure & poisoned retry loop**: `DatabaseService._runSyncLoop()` catches all exceptions, sets `SyncStatus.offline` (`"Offline Cache"`), skips `_pullCollections()`, and leaves the failing row in `sync_outbox`. Meanwhile, the Settings **Sync now** button awaits `performCloudSync()` (which swallows exceptions) and unconditionally displays `"Cloud sync complete"`.
4. **Why Undo fixed it**: `TasksNotifier.undoHistoryAction()` calls `saveTasks()`, whose `_enqueue()` coalesces by `(userId, collectionName, recordKey)` — deleting the poisoned `'delete'` row and replacing it with an `'upsert'` row that includes `title`.

### Fix
1. Pass `item.operation` into `DatabaseService._pushSingleRecord()`. When `operation == 'delete'` (and `collection != 'user_profiles'`):
   - If the remote record exists, `PATCH` only `{deletedAt, clientUpdatedAt}` so required fields like `title` are never overwritten with `""`.
   - If the remote record does not exist (created and deleted while offline), skip creating a stub record and clear the outbox row.
2. Also include `title`/`name` in delete outbox payloads from `TaskRepository` as defense-in-depth.
3. Distinguish HTTP `ClientException` (`SyncStatus.error`) from network offline (`SyncStatus.offline`), store `lastError`, show red exclamation warning text in `AdaptiveScaffold` when offline or in error, and have Settings **Sync now** report the real status instead of falsely claiming `"Cloud sync complete"`.
4. **Broadcast replay fix (`syncStatusStream`)**: `DatabaseService.syncStatusStream` previously returned a plain `.broadcast()` stream, causing late subscribers (`AdaptiveScaffold` mounting after login/startup sync) to miss `SyncStatus.synced` and fall back to `SyncStatus.offline`. Changed `syncStatusStream` to `async* { yield _currentStatus; yield* _syncStatusController.stream; }`.

---

## Bug 2: Priority Levels Sync, Save & Reindexing, 2-Part Scroll Wheel & Trusted Taskgivers

### Observed Symptom
- Adding or editing priority levels (count, labels, escalation rules) in Settings does not have a Save button, scrambles/drops labels, does not reindex existing tasks, and can break syncing or crash dropdowns.
- Escalation rules only offer fixed presets for levels 2 and 3.
- Trusted taskgivers (`/give/{token}`) always see 3 hardcoded levels (`Low`, `Medium`, `Urgent`) instead of the user's configured priority count and labels.

### Root Cause
1. **Unkeyed `TextFormField(initialValue: ...)` without Save/controllers**: `SettingsScreen` rendered level name fields without `Key` or `TextEditingController`, updating only on `onFieldSubmitted` (pressing Enter). Changing `numImportanceLevels` shifted Flutter widget state across levels, losing unsaved edits and immediately firing partial profile syncs without reindexing tasks.
2. **Unsafe `UserProfile.fromMap` deserialization**: Checked `is int` instead of `is num` and accepted PocketBase default `0` (`numImportanceLevels`, `maxInProgressTasks`, window values) or `""` (`level2WindowUnit`, `level3WindowUnit`, vacation dates), crashing `DropdownButton` assertions or zeroing priority levels after sync.
3. **Missing task/rule reindexing & level 4–5 escalation**: Reducing `numImportanceLevels` left existing tasks with `baseImportance` 4 or 5 hidden from `sectionedTasksProvider` (and `PriorityEngine.evaluate` returned early for tasks without due dates without clamping). `UserProfile` also lacked escalation windows for levels 4 and 5.
4. **Hardcoded Trusted Taskgivers HTML/API**: `backend/internal/integrations/taskgivers.go` clamped `importance` to `1..3` and hardcoded `Low`, `Medium`, `Urgent` radios instead of reading the owner's `user_profiles` record.

### Fix
1. **Schema & Models**: Add `escalationWindows` (`JSONField`) to `user_profiles` in `bootstrap.go` and `UserProfile` (`EscalationWindow` map for levels `2..5`, synced alongside `level2Window*` / `level3Window*`). Harden `UserProfile.fromMap` against `0`, `""`, and `num` types. Update `PriorityEngine.evaluate` to clamp `baseImportance` to `[1, numImportanceLevels]` and evaluate escalation windows from `numImportanceLevels` down to `2`.
2. **2-Part Scroll Wheel Picker**: Add reusable `DurationWheelDialog` (`numbers` on left, `minutes/hours/days/weeks/months` on right) for escalation windows in Settings (`levels 2..numImportanceLevels`).
3. **Explicit Save, Reindex & Sync**: Add local draft state + **Save & Sync Priority Settings** button in Settings that persists `numImportanceLevels`, `levelNames`, and `escalationWindows`, reindexes all tasks and recurrence rules (`baseImportance` clamped to `1..numImportanceLevels`, `effectiveImportance` & `isOverdue` recomputed), and pushes all changes to PocketBase.
4. **Trusted Taskgivers**: Update `taskgivers.go` to load the owner's `numImportanceLevels` and `levelNames` from `user_profiles`, render matching accessible radio buttons (`for`/`id`, `accent-color`), validate `1..numImportanceLevels` on `POST`, and show matching priority badges on requested tasks.
