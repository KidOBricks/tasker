import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/local/app_database.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/calendar_integration_service.dart';
import 'data/services/database_service.dart';
import 'data/services/email_integration_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/pocketbase_client.dart';
import 'data/services/server_config.dart';
import 'state/app_state.dart';
import 'state/auth_state.dart';
import 'state/integration_state.dart';
import 'ui/layout/adaptive_scaffold.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final serverConfig = ServerConfig(prefs);
  final db = AppDatabase();
  final pb = PocketBaseClientFactory.create(prefs, serverConfig);

  final repository = TaskRepository(db);
  final authService = AuthService(pb, serverConfig);
  final databaseService = DatabaseService(pb, db, repository);
  final calendarService = CalendarIntegrationService(pb, db);
  final emailService = EmailIntegrationService(pb, db);
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Hydrate cached user immediately so offline launch renders Drift data right away.
  final cachedUser = authService.currentUser;
  if (cachedUser != null) {
    await repository.loadForUser(
      cachedUser.id,
      email: cachedUser.email,
      displayName: cachedUser.displayName,
      seedDefaults: false,
    );
    unawaited(() async {
      final refreshed = await authService.refreshSessionIfPossible();
      if (refreshed != null) {
        await databaseService.performCloudSync(userId: refreshed.id);
        if (await repository.ensureDefaultsIfMissing(
          email: refreshed.email,
          displayName: refreshed.displayName,
        )) {
          await databaseService.performCloudSync(userId: refreshed.id);
        }
        unawaited(databaseService.startRealtimeSync(refreshed.id));
      } else {
        await repository.loadForUser('');
      }
    }());
  }

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        authServiceProvider.overrideWithValue(authService),
        databaseServiceProvider.overrideWithValue(databaseService),
        calendarIntegrationServiceProvider.overrideWithValue(calendarService),
        emailIntegrationServiceProvider.overrideWithValue(emailService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const TaskCalendarSyncApp(),
    ),
  );
}

class TaskCalendarSyncApp extends ConsumerStatefulWidget {
  const TaskCalendarSyncApp({super.key});

  @override
  ConsumerState<TaskCalendarSyncApp> createState() => _TaskCalendarSyncAppState();
}

class _TaskCalendarSyncAppState extends ConsumerState<TaskCalendarSyncApp> {
  StreamSubscription<Uri>? _linkSub;
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResumed,
    );
  }

  void _initDeepLinks() {
    if (kIsWeb) return;
    try {
      final appLinks = AppLinks();
      _linkSub = appLinks.uriLinkStream.listen(
        (uri) {
          if (uri.scheme == 'tasker' && uri.host == 'oauth-callback') {
            _refreshAfterOAuth();
          }
        },
        onError: (_) {},
      );
    } catch (_) {
      // Ignored in test or unsupported desktop shells
    }
  }

  void _onAppResumed() {
    final user = ref.read(authProvider);
    if (user == null) return;
    unawaited(ref.read(databaseServiceProvider).performCloudSync(userId: user.id));
    unawaited(ref.read(connectedAccountsProvider.notifier).refreshStatus());
  }

  void _refreshAfterOAuth() {
    final user = ref.read(authProvider);
    if (user == null) return;
    unawaited(ref.read(connectedAccountsProvider.notifier).syncNow());
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasker - Task & Calendar Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const AdaptiveScaffold(),
    );
  }
}

