import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/database_service.dart';
import 'data/services/calendar_integration_service.dart';
import 'data/services/email_integration_service.dart';
import 'state/app_state.dart';
import 'state/auth_state.dart';
import 'state/integration_state.dart';
import 'ui/theme/app_theme.dart';
import 'ui/layout/adaptive_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences and multi-tenant services
  final prefs = await SharedPreferences.getInstance();
  final repository = await TaskRepository.initWithPrefs(prefs);
  final authService = AuthService(prefs);
  final databaseService = DatabaseService(prefs);
  final calendarService = CalendarIntegrationService(prefs);
  final emailService = EmailIntegrationService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        authServiceProvider.overrideWithValue(authService),
        databaseServiceProvider.overrideWithValue(databaseService),
        calendarIntegrationServiceProvider.overrideWithValue(calendarService),
        emailIntegrationServiceProvider.overrideWithValue(emailService),
      ],
      child: const TaskCalendarSyncApp(),
    ),
  );
}

class TaskCalendarSyncApp extends StatelessWidget {
  const TaskCalendarSyncApp({super.key});

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
