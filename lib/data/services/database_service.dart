import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

class DatabaseService {
  final SharedPreferences _prefs;
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.synced;
  DateTime _lastSyncTime = DateTime.now();

  DatabaseService(this._prefs) {
    _syncStatusController.add(SyncStatus.synced);
  }

  SyncStatus get status => _currentStatus;
  DateTime get lastSyncTime => _lastSyncTime;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Simulates two-way cloud sync with Firestore / Firebase Realtime DB
  Future<void> performCloudSync({String? userId}) async {
    _currentStatus = SyncStatus.syncing;
    _syncStatusController.add(_currentStatus);

    await Future.delayed(const Duration(milliseconds: 600));

    _currentStatus = SyncStatus.synced;
    _lastSyncTime = DateTime.now();
    _syncStatusController.add(_currentStatus);

    await _prefs.setString('last_cloud_sync_${userId ?? "default"}', _lastSyncTime.toIso8601String());
  }

  void setOfflineMode(bool offline) {
    _currentStatus = offline ? SyncStatus.offline : SyncStatus.synced;
    _syncStatusController.add(_currentStatus);
  }

  void dispose() {
    _syncStatusController.close();
  }
}
