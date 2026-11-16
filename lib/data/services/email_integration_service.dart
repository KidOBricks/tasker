import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/gemini_service.dart';
import '../local/app_database.dart';

class EmailIntegrationService {
  final PocketBase _pb;
  final AppDatabase _db;

  EmailIntegrationService(this._pb, this._db);

  Future<List<ExtractedTaskSuggestion>> getPendingSuggestions({required String userId}) async {
    if (userId.isEmpty) return const [];
    final rows = await (_db.select(_db.localTaskSuggestions)
          ..where((s) => s.userId.equals(userId) & s.status.equals('pending'))
          ..orderBy([(s) => OrderingTerm.desc(s.receivedAt)]))
        .get();

    return rows
        .map(
          (r) => ExtractedTaskSuggestion(
            id: r.pbId ?? r.id,
            emailId: r.emailId,
            title: r.title,
            description: r.description,
            categoryId: r.categoryId,
            importance: r.importance,
            suggestedDueDate: r.suggestedDueDate,
            emailSubject: r.subject,
            emailSender: r.sender,
            emailSnippet: r.snippet,
            status: r.status,
          ),
        )
        .toList();
  }

  Future<void> triggerInboxScan() async {
    if (!_pb.authStore.isValid) return;
    await _pb.send('/api/integrations/sync', method: 'POST');
  }

  Future<void> updateSuggestionStatus({
    required String userId,
    required ExtractedTaskSuggestion suggestion,
    required String status,
  }) async {
    final emailId = suggestion.emailId;
    if (emailId != null) {
      final compositeId = '$userId::$emailId';
      await (_db.update(_db.localTaskSuggestions)
            ..where((s) => s.id.equals(compositeId) & s.userId.equals(userId)))
          .write(LocalTaskSuggestionsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    }

    if (suggestion.id != null && _pb.authStore.isValid && !suggestion.id!.contains('::')) {
      try {
        await _pb.collection('task_suggestions').update(
          suggestion.id!,
          body: {'status': status},
        );
      } catch (_) {}
    }
  }
}
