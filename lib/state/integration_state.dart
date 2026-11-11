import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/calendar_integration_service.dart';
import '../data/services/email_integration_service.dart';

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
  final bool isGmailConnected;

  const ConnectedAccountsState({
    this.google,
    this.outlook,
    this.isGmailConnected = false,
  });

  ConnectedAccountsState copyWith({
    ConnectedAccountInfo? google,
    ConnectedAccountInfo? outlook,
    bool? isGmailConnected,
  }) =>
      ConnectedAccountsState(
        google: google ?? this.google,
        outlook: outlook ?? this.outlook,
        isGmailConnected: isGmailConnected ?? this.isGmailConnected,
      );
}

class ConnectedAccountsNotifier extends Notifier<ConnectedAccountsState> {
  @override
  ConnectedAccountsState build() {
    final calService = ref.watch(calendarIntegrationServiceProvider);
    final emailService = ref.watch(emailIntegrationServiceProvider);
    return ConnectedAccountsState(
      google: calService.getGoogleAccount(),
      outlook: calService.getOutlookAccount(),
      isGmailConnected: emailService.isGmailConnected(),
    );
  }

  Future<void> connectGoogle({required String email, String? accessToken, String? displayName}) async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    final emailService = ref.read(emailIntegrationServiceProvider);
    await calService.connectGoogleAccount(email: email, accessToken: accessToken, displayName: displayName);
    await emailService.connectGmail(email: email, accessToken: accessToken);

    state = ConnectedAccountsState(
      google: calService.getGoogleAccount(),
      outlook: calService.getOutlookAccount(),
      isGmailConnected: true,
    );

    // Trigger calendar refresh
    ref.read(externalEventsProvider.notifier).refreshEvents();
  }

  Future<void> connectOutlook({required String email, String? accessToken, String? displayName}) async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.connectOutlookAccount(email: email, accessToken: accessToken, displayName: displayName);

    state = ConnectedAccountsState(
      google: calService.getGoogleAccount(),
      outlook: calService.getOutlookAccount(),
      isGmailConnected: state.isGmailConnected,
    );

    // Trigger calendar refresh
    ref.read(externalEventsProvider.notifier).refreshEvents();
  }

  Future<void> disconnectGoogle() async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    final emailService = ref.read(emailIntegrationServiceProvider);
    await calService.disconnectAccount('google');
    await emailService.disconnectGmail();

    state = ConnectedAccountsState(
      google: null,
      outlook: calService.getOutlookAccount(),
      isGmailConnected: false,
    );

    ref.read(externalEventsProvider.notifier).refreshEvents();
  }

  Future<void> disconnectOutlook() async {
    final calService = ref.read(calendarIntegrationServiceProvider);
    await calService.disconnectAccount('microsoft');

    state = ConnectedAccountsState(
      google: calService.getGoogleAccount(),
      outlook: null,
      isGmailConnected: state.isGmailConnected,
    );

    ref.read(externalEventsProvider.notifier).refreshEvents();
  }
}

final connectedAccountsProvider = NotifierProvider<ConnectedAccountsNotifier, ConnectedAccountsState>(() {
  return ConnectedAccountsNotifier();
});

// External Calendar Events Notifier
class ExternalEventsNotifier extends Notifier<AsyncValue<List<ExternalCalendarEvent>>> {
  @override
  AsyncValue<List<ExternalCalendarEvent>> build() {
    refreshEvents();
    return const AsyncValue.loading();
  }

  Future<void> refreshEvents() async {
    state = const AsyncValue.loading();
    try {
      final calService = ref.read(calendarIntegrationServiceProvider);
      final events = await calService.fetchAllCalendarEvents();
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void markEventLinked(String eventId) {
    state.whenData((events) {
      final updated = events.map((ev) {
        if (ev.id == eventId) {
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
