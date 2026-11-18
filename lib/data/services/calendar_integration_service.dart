import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/task_item.dart';
import '../local/app_database.dart';

class ExternalCalendarEvent {
  final String id;
  final String? pbId;
  final String title;
  final String source; // 'google' | 'outlook'
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String description;
  final String? meetingUrl;
  final List<String> attendees;
  final bool hasLinkedTask;

  const ExternalCalendarEvent({
    required this.id,
    this.pbId,
    required this.title,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.description = '',
    this.meetingUrl,
    this.attendees = const [],
    this.hasLinkedTask = false,
  });

  ExternalCalendarEvent copyWith({bool? hasLinkedTask}) => ExternalCalendarEvent(
        id: id,
        pbId: pbId,
        title: title,
        source: source,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        meetingUrl: meetingUrl,
        attendees: attendees,
        hasLinkedTask: hasLinkedTask ?? this.hasLinkedTask,
      );
}

class ConnectedAccountInfo {
  final String provider; // 'google' | 'microsoft'
  final String email;
  final String displayName;
  final bool isConnected;
  final DateTime? lastSyncedAt;

  const ConnectedAccountInfo({
    required this.provider,
    required this.email,
    required this.displayName,
    required this.isConnected,
    this.lastSyncedAt,
  });

  factory ConnectedAccountInfo.fromJson(Map<String, dynamic> json) => ConnectedAccountInfo(
        provider: json['provider'] as String? ?? '',
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        isConnected: json['isConnected'] == true,
        lastSyncedAt: json['lastSyncedAt'] != null && (json['lastSyncedAt'] as String).isNotEmpty
            ? DateTime.tryParse(json['lastSyncedAt'] as String)
            : null,
      );
}

class GoogleCalendarInfo {
  final String id;
  final String summary;
  final bool primary;
  final String backgroundColor;
  final bool selected;

  const GoogleCalendarInfo({
    required this.id,
    required this.summary,
    this.primary = false,
    this.backgroundColor = '',
    this.selected = false,
  });

  factory GoogleCalendarInfo.fromJson(Map<String, dynamic> json) => GoogleCalendarInfo(
        id: json['id']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        primary: json['primary'] == true,
        backgroundColor: json['backgroundColor']?.toString() ?? '',
        selected: json['selected'] == true,
      );
}

class BulkTaskDraft {
  final String title;
  final String description;
  final String categoryId;
  final int importance;

  const BulkTaskDraft({
    required this.title,
    this.description = '',
    this.categoryId = 'work',
    this.importance = 2,
  });

  factory BulkTaskDraft.fromJson(Map<String, dynamic> json) => BulkTaskDraft(
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        categoryId: json['categoryId']?.toString() ?? 'work',
        importance: json['importance'] is num ? (json['importance'] as num).toInt().clamp(1, 5) : 2,
      );
}

class TrustedTaskgiver {
  final String id;
  final String name;
  final String email;
  final String token;
  final bool isActive;
  final String shareUrl;

  const TrustedTaskgiver({
    required this.id,
    required this.name,
    this.email = '',
    required this.token,
    this.isActive = true,
    required this.shareUrl,
  });
}

class IntegrationsStatusSnapshot {
  final ConnectedAccountInfo? google;
  final ConnectedAccountInfo? microsoft;
  final bool googleConfigured;
  final bool microsoftConfigured;

  const IntegrationsStatusSnapshot({
    this.google,
    this.microsoft,
    this.googleConfigured = false,
    this.microsoftConfigured = false,
  });
}

class CalendarIntegrationService {
  final PocketBase _pb;
  final AppDatabase _db;

  CalendarIntegrationService(this._pb, this._db);

  Future<IntegrationsStatusSnapshot> fetchConnectionStatus() async {
    if (!_pb.authStore.isValid) {
      return const IntegrationsStatusSnapshot();
    }
    try {
      final resp = await _pb.send<Map<String, dynamic>>('/api/integrations/status', method: 'GET');
      final configured = resp['configured'] is Map
          ? Map<String, dynamic>.from(resp['configured'] as Map)
          : const <String, dynamic>{};

      final gRaw = resp['google'];
      final mRaw = resp['microsoft'];

      return IntegrationsStatusSnapshot(
        google: gRaw is Map ? ConnectedAccountInfo.fromJson(Map<String, dynamic>.from(gRaw)) : null,
        microsoft: mRaw is Map ? ConnectedAccountInfo.fromJson(Map<String, dynamic>.from(mRaw)) : null,
        googleConfigured: configured['google'] == true,
        microsoftConfigured: configured['microsoft'] == true,
      );
    } catch (e) {
      debugPrint('Failed to fetch integration status: $e');
      return const IntegrationsStatusSnapshot();
    }
  }

  /// Initiates server-side OAuth2 flow in the user's browser.
  Future<void> launchProviderOAuth(
    String provider, {
    String? redirectUri,
    Future<void> Function(Uri url)? launcher,
  }) async {
    final effectiveRedirect = redirectUri ?? (kIsWeb ? Uri.base.origin : 'tasker://oauth-callback');
    final resp = await _pb.send<Map<String, dynamic>>(
      '/api/integrations/$provider/start',
      method: 'POST',
      body: {'redirectUri': effectiveRedirect},
    );
    final authUrl = resp['authUrl'] as String?;
    if (authUrl == null || authUrl.isEmpty) {
      throw Exception('Server did not return an OAuth URL for $provider.');
    }
    final uri = Uri.parse(authUrl);
    if (launcher != null) {
      await launcher(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> disconnectAccount(String provider) async {
    await _pb.send('/api/integrations/$provider', method: 'DELETE');
  }

  Future<void> triggerServerSync() async {
    if (!_pb.authStore.isValid) return;
    await _pb.send('/api/integrations/sync', method: 'POST');
  }

  Future<List<GoogleCalendarInfo>> fetchGoogleCalendars() async {
    if (!_pb.authStore.isValid) return const [];
    final resp = await _pb.send<Map<String, dynamic>>('/api/integrations/google/calendars', method: 'GET');
    final raw = resp['calendars'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => GoogleCalendarInfo.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> saveGoogleCalendars(List<String> calendarIds) async {
    if (!_pb.authStore.isValid) return;
    await _pb.send(
      '/api/integrations/google/calendars',
      method: 'PUT',
      body: {'calendarIds': calendarIds},
    );
  }

  Future<List<BulkTaskDraft>> parseBulkTasks(String text) async {
    if (!_pb.authStore.isValid) {
      throw Exception('Not signed in');
    }
    final resp = await _pb.send<Map<String, dynamic>>(
      '/api/tasks/parse-bulk',
      method: 'POST',
      body: {'text': text},
    );
    final raw = resp['tasks'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => BulkTaskDraft.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<List<TrustedTaskgiver>> listTaskgivers(String userId) async {
    if (!_pb.authStore.isValid || userId.isEmpty) return const [];
    final records = await _pb.collection('trusted_taskgivers').getFullList(
          filter: 'user = "${userId.replaceAll('"', '\\"')}"',
          sort: '-created',
        );
    final base = _pb.baseURL.replaceAll(RegExp(r'/+$'), '');
    return records
        .map((r) => TrustedTaskgiver(
              id: r.id,
              name: r.get<String>('name', ''),
              email: r.get<String>('email', ''),
              token: r.get<String>('token', ''),
              isActive: r.get<bool>('isActive', true),
              shareUrl: '$base/give/${r.get<String>('token', '')}',
            ))
        .toList();
  }

  Future<TrustedTaskgiver> createTaskgiver({required String name, String email = ''}) async {
    final resp = await _pb.send<Map<String, dynamic>>(
      '/api/taskgivers',
      method: 'POST',
      body: {'name': name.trim(), 'email': email.trim()},
    );
    return TrustedTaskgiver(
      id: resp['id']?.toString() ?? '',
      name: resp['name']?.toString() ?? name.trim(),
      email: resp['email']?.toString() ?? email.trim(),
      token: resp['token']?.toString() ?? '',
      isActive: resp['isActive'] != false,
      shareUrl: resp['shareUrl']?.toString() ?? '',
    );
  }

  Future<void> updateTaskgiver(String id, {String? name, String? email, bool? isActive}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (email != null) body['email'] = email.trim();
    if (isActive != null) body['isActive'] = isActive;
    await _pb.collection('trusted_taskgivers').update(id, body: body);
  }

  Future<void> deleteTaskgiver(String id) async {
    await _pb.collection('trusted_taskgivers').delete(id);
  }

  /// Loads synced calendar events from Drift local SQLite for the active user.
  Future<List<ExternalCalendarEvent>> fetchAllCalendarEvents({required String userId}) async {
    if (userId.isEmpty) return const [];
    final rows = await (_db.select(_db.localExternalEvents)
          ..where((e) => e.userId.equals(userId))
          ..orderBy([(e) => OrderingTerm.asc(e.startTime)]))
        .get();

    return rows.map((r) {
      List<String> attendees = const [];
      try {
        attendees = (json.decode(r.attendeesJson) as List).cast<String>();
      } catch (_) {}
      return ExternalCalendarEvent(
        id: r.externalId,
        pbId: r.pbId,
        title: r.title,
        source: r.source,
        startTime: r.startTime,
        endTime: r.endTime,
        location: r.location,
        description: r.description,
        meetingUrl: r.meetingUrl,
        attendees: attendees,
        hasLinkedTask: r.hasLinkedTask,
      );
    }).toList();
  }

  Future<void> markEventLinked(String userId, ExternalCalendarEvent event) async {
    final compositeId = '$userId::${event.source}::${event.id}';
    await (_db.update(_db.localExternalEvents)
          ..where((e) => e.id.equals(compositeId) & e.userId.equals(userId)))
        .write(LocalExternalEventsCompanion(
      hasLinkedTask: const Value(true),
      updatedAt: Value(DateTime.now().toUtc()),
    ));

    if (event.pbId != null && _pb.authStore.isValid) {
      try {
        await _pb.collection('external_events').update(
          event.pbId!,
          body: {'hasLinkedTask': true},
        );
      } catch (_) {}
    }
  }

  /// Creates a preparation task linked to the calendar event with a default 2h prior deadline.
  TaskItem generatePrepTask(
    ExternalCalendarEvent event, {
    required String userId,
    Duration leadTime = const Duration(hours: 2),
  }) {
    final now = DateTime.now();
    final prepDueDate = event.startTime.subtract(leadTime);
    return TaskItem(
      id: 'prep_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'Prepare for "${event.title}"',
      description:
          'Prep task linked to ${event.source == "google" ? "Google Calendar" : "Outlook"} event at ${event.location}.\nMeeting link: ${event.meetingUrl ?? "None"}',
      categoryId: 'work',
      baseImportance: 3,
      effectiveImportance: 3,
      dueDate: prepDueDate,
      createdAt: now,
      calendarEventId: event.id,
    );
  }
}
