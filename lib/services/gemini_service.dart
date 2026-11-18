class ExtractedTaskSuggestion {
  final String? id;
  final String? emailId;
  final String title;
  final String description;
  final String categoryId;
  final int importance;
  final DateTime? suggestedDueDate;
  final String emailSubject;
  final String emailSender;
  final String emailSnippet;
  final String status;

  const ExtractedTaskSuggestion({
    this.id,
    this.emailId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.importance,
    this.suggestedDueDate,
    required this.emailSubject,
    required this.emailSender,
    required this.emailSnippet,
    this.status = 'pending',
  });

  ExtractedTaskSuggestion copyWith({String? status}) {
    return ExtractedTaskSuggestion(
      id: id,
      emailId: emailId,
      title: title,
      description: description,
      categoryId: categoryId,
      importance: importance,
      suggestedDueDate: suggestedDueDate,
      emailSubject: emailSubject,
      emailSender: emailSender,
      emailSnippet: emailSnippet,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailId': emailId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'importance': importance,
      'suggestedDueDate': suggestedDueDate?.toIso8601String(),
      'emailSubject': emailSubject,
      'emailSender': emailSender,
      'emailSnippet': emailSnippet,
      'status': status,
    };
  }

  factory ExtractedTaskSuggestion.fromMap(Map<String, dynamic> map) {
    return ExtractedTaskSuggestion(
      id: map['id'] as String?,
      emailId: map['emailId'] as String?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? 'work',
      importance: map['importance'] is num ? (map['importance'] as num).toInt() : 2,
      suggestedDueDate: map['suggestedDueDate'] != null && (map['suggestedDueDate'] as String).isNotEmpty
          ? DateTime.tryParse(map['suggestedDueDate'])
          : null,
      emailSubject: map['emailSubject'] ?? map['subject'] ?? '',
      emailSender: map['emailSender'] ?? map['sender'] ?? '',
      emailSnippet: map['emailSnippet'] ?? map['snippet'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}
