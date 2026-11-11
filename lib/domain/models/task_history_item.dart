import 'dart:convert';
import 'task_item.dart';

class TaskHistoryItem {
  final String id;
  final String taskId;
  final String taskTitle;
  final String action; // 'created', 'completed', 'in_progress', 'pending', 'ignored', 'deleted', 'edited'
  final String description;
  final DateTime timestamp;
  final TaskItem? previousTaskState;
  final TaskItem? newTaskState;

  const TaskHistoryItem({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.action,
    required this.description,
    required this.timestamp,
    this.previousTaskState,
    this.newTaskState,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'previousTaskState': previousTaskState?.toMap(),
      'newTaskState': newTaskState?.toMap(),
    };
  }

  factory TaskHistoryItem.fromMap(Map<String, dynamic> map) {
    return TaskHistoryItem(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskTitle: map['taskTitle'] ?? '',
      action: map['action'] ?? 'unknown',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      previousTaskState: map['previousTaskState'] != null
          ? TaskItem.fromMap(map['previousTaskState'])
          : null,
      newTaskState: map['newTaskState'] != null
          ? TaskItem.fromMap(map['newTaskState'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskHistoryItem.fromJson(String source) =>
      TaskHistoryItem.fromMap(json.decode(source));
}
