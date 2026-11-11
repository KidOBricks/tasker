import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class ExtractedTaskSuggestion {
  final String title;
  final String description;
  final String categoryId;
  final int importance;
  final DateTime? suggestedDueDate;
  final String emailSubject;
  final String emailSender;
  final String emailSnippet;

  const ExtractedTaskSuggestion({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.importance,
    this.suggestedDueDate,
    required this.emailSubject,
    required this.emailSender,
    required this.emailSnippet,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'importance': importance,
      'suggestedDueDate': suggestedDueDate?.toIso8601String(),
      'emailSubject': emailSubject,
      'emailSender': emailSender,
      'emailSnippet': emailSnippet,
    };
  }

  factory ExtractedTaskSuggestion.fromMap(Map<String, dynamic> map) {
    return ExtractedTaskSuggestion(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? 'work',
      importance: map['importance'] is int ? map['importance'] : 2,
      suggestedDueDate: map['suggestedDueDate'] != null
          ? DateTime.tryParse(map['suggestedDueDate'])
          : null,
      emailSubject: map['emailSubject'] ?? '',
      emailSender: map['emailSender'] ?? '',
      emailSnippet: map['emailSnippet'] ?? '',
    );
  }
}

class GeminiTaskExtractor {
  final String? apiKey;

  GeminiTaskExtractor({this.apiKey});

  /// Extracts task candidates from email subject and body snippet.
  Future<ExtractedTaskSuggestion> extractFromEmail({
    required String subject,
    required String sender,
    required String bodySnippet,
  }) async {
    // If Gemini API Key is provided, use Google Generative AI
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!.trim());
        final prompt = '''
You are an intelligent executive assistant extracting tasks from incoming emails.
Analyze this email:
Sender: $sender
Subject: $subject
Content: $bodySnippet

Extract a structured JSON response with:
- "title": Concise action-oriented task title (max 8 words)
- "description": Contextual explanation or instructions
- "categoryId": One of ["work", "personal", "study"]
- "importance": Integer from 1 to 3 (3 = urgent/immediate, 2 = medium, 1 = low)
- "daysUntilDue": Suggested days until due (e.g. 1 for tomorrow, 7 for a week, or null if open-ended)

Return ONLY valid raw JSON without markdown formatting.
''';

        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.trim() ?? '';
        final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final map = json.decode(cleanJson) as Map<String, dynamic>;

        final daysUntilDue = map['daysUntilDue'] is int ? map['daysUntilDue'] as int : null;
        final dueDate = daysUntilDue != null
            ? DateTime.now().add(Duration(days: daysUntilDue))
            : null;

        return ExtractedTaskSuggestion(
          title: map['title'] ?? subject,
          description: map['description'] ?? bodySnippet,
          categoryId: map['categoryId'] ?? 'work',
          importance: map['importance'] is int ? map['importance'] : 2,
          suggestedDueDate: dueDate,
          emailSubject: subject,
          emailSender: sender,
          emailSnippet: bodySnippet,
        );
      } catch (_) {
        // Fallback to heuristic parser if API call fails
      }
    }

    // Heuristic Fallback Engine
    return _heuristicFallback(subject, sender, bodySnippet);
  }

  ExtractedTaskSuggestion _heuristicFallback(String subject, String sender, String snippet) {
    final lower = '$subject $snippet'.toLowerCase();
    int importance = 2;
    String category = 'work';
    DateTime? dueDate;

    if (lower.contains('urgent') || lower.contains('asap') || lower.contains('immediately') || lower.contains('due tomorrow')) {
      importance = 3;
      dueDate = DateTime.now().add(const Duration(days: 1));
    } else if (lower.contains('invoice') || lower.contains('bill') || lower.contains('payment')) {
      importance = 3;
      dueDate = DateTime.now().add(const Duration(days: 3));
    } else if (lower.contains('flight') || lower.contains('vacation') || lower.contains('hotel') || lower.contains('family')) {
      category = 'personal';
      importance = 1;
    } else if (lower.contains('assignment') || lower.contains('homework') || lower.contains('lecture') || lower.contains('exam')) {
      category = 'study';
      importance = 3;
      dueDate = DateTime.now().add(const Duration(days: 2));
    }

    String title = subject;
    if (title.toLowerCase().startsWith('re: ') || title.toLowerCase().startsWith('fwd: ')) {
      title = title.substring(4);
    }

    return ExtractedTaskSuggestion(
      title: 'Action: $title',
      description: snippet,
      categoryId: category,
      importance: importance,
      suggestedDueDate: dueDate ?? DateTime.now().add(const Duration(days: 4)),
      emailSubject: subject,
      emailSender: sender,
      emailSnippet: snippet,
    );
  }
}
