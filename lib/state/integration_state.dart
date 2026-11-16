import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/calendar_integration_service.dart';
import '../data/services/email_integration_service.dart';
import 'auth_state.dart';

final calendarIntegrationServiceProvider = Provider<CalendarIntegrationService>((ref) {
  throw UnimplementedError('calendarIntegrationServiceProvider must be initialized');
});

final emailIntegrationServiceProvider = Provider<EmailIntegrationService>((ref) {
  throw UnimplementedError('emailIntegrationServiceProvider must be initialized');
});

// Connected Accounts State
class ConnectedAccountsState {
  final ConnectedAccountInfo? google;
  final ConnectedAccountInfo? outlook;
  final bool googleConfigured;
  final bool outlookConfigured;
  final bool isLoading;

  const ConnectedAccountsState({
    this.google,
    this.outlook,
    this.googleConfigured = false,
    this.outlookConfigured = false,
    this.isLoading = false,
  });

  bool get isGmailConnected => google?.isConnected == true;

  ConnectedAccountsState copyWith({
    ConnectedAccountInfo? google,
    bool clearGoogle = false,
    ConnectedAccountInfo? outlook,
    bool clearOutlook = false,
    bool? googleConfigured,
    bool? outlookConfigured,
    bool? isLoading,
  }) =>
      ConnectedAccountsState(
        google: clearGoogle ? null : (google ?? this.google),
        outlook: clearOutlook ? null : (outlook ?? this.outlook),
        googleConfigured: googleConfigured ?? this.googleConfigured,
        outlookConfigured: outlookConfigured ?? this.outlookConfigured,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ConnectedAccountsNotifier extends Notifier<ConnectedAccountsState> {
  @override
  ConnectedAccountsState build() {
    final user = ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    if (user != null) {
      Future.microtask(refreshStatus);
    }
    return const ConnectedAccountsState();
  }

  Future<void> refreshStatus() async {
    final user = ref.read(authProvider);
    if (user == null) {
      state = const ConnectedAccountsState();
      return;
    }
    state = state.copyWith(isLoading: true);
    final calService = ref.read(calendarIntegrationServiceProvider);
    final snapshot = await calService.fetchConnectionStatus();
    state = ConnectedAccountsState(
      google: snapshot.google,
      outlook: snapshot.microsoft,
      googleConfigured: snapshot.googleConfigured,
      outlookConfigured: snapshot.microsoftConfigured,
      isLoading: false,
    );
  }

  Future<void> connectProvider(String provider) async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.launchProviderOAuth(provider);
  }

  Future<void> syncNow() async {
    final user = ref.read(authProvider);
    if (user == null) return;
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.triggerServerSync();
    await ref.read(databaseServiceProvider).performCloudSync(userId: user.id);
    await refreshStatus();
    await ref.read(externalEventsProvider.notifier).refreshEvents();
  }

  Future<void> disconnectGoogle() async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.disconnectAccount('google');
    await refreshStatus();
    await ref.read(externalEventsProvider.notifier).refreshEvents();
  }

  Future<void> disconnectOutlook() async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.disconnectAccount('microsoft');
    await refreshStatus();
    await ref.read(externalEventsProvider.notifier).refreshEvents();
  }
}

final connectedAccountsProvider = NotifierProvider<ConnectedAccountsNotifier, ConnectedAccountsState>(() {
  return ConnectedAccountsNotifier();
});

// External Calendar Events Notifier
class ExternalEventsNotifier extends Notifier<AsyncValue<List<ExternalCalendarEvent>>> {
  @override
  AsyncValue<List<ExternalCalendarEvent>> build() {
    final user = ref.watch(authProvider);
    ref.watch(cloudDataRevisionProvider);
    if (user == null) {
      return const AsyncValue.data([]);
    }
    Future.microtask(refreshEvents);
    return const AsyncValue.loading();
  }

  Future<void> refreshEvents() async {
    final user = ref.read(authProvider);
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final calService = ref.read(calendarIntegrationServiceProvider);
      final events = await calService.fetchAllCalendarEvents(userId: user.id);
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markEventLinked(ExternalCalendarEvent event) async {
    final user = ref.read(authProvider);
    if (user == null) return;
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.markEventLinked(user.id, event);
    state.whenData((events) {
      final updated = events.map((ev) {
        if (ev.id == event.id && ev.source == event.source) {
          return ev.copyWith(hasLinkedTask: true);
        }
        return ev;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}

final externalEventsProvider = NotifierProvider<ExternalEventsNotifier, AsyncValue<List<ExternalCalendarEvent>>>(() {
  return ExternalEventsNotifier();
});
