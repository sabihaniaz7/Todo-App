import 'package:cloud_firestore/cloud_firestore.dart';

class TodoTask {
  final String id;
  final String title;
  final String body;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime displayTime;

  const TodoTask({
    required this.id,
    required this.title,
    required this.body,
    required this.isCompleted,
    required this.createdAt,
    required this.displayTime,
  });

  factory TodoTask.fromDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = _timestampToDate(data['createdAt']);
    final displayTime = _timestampToDate(data['timestamp']) ?? createdAt;

    return TodoTask(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      body: data['body'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      displayTime: displayTime ?? DateTime.now(),
    );
  }

  static DateTime? _timestampToDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
