import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/task_repository.dart';
import 'state/app_state.dart';
import 'ui/theme/app_theme.dart';
import 'ui/layout/adaptive_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first reactive repository layer
  final repository = await TaskRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
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
      title: 'SyncTask - Task & Calendar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const AdaptiveScaffold(),
    );
  }
}
