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
