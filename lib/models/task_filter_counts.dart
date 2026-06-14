import 'package:cloud_firestore/cloud_firestore.dart';

class TaskFilterCounts {
  final int total;
  final int pending;
  final int completed;
  final bool hasError;

  const TaskFilterCounts({
    required this.total,
    required this.pending,
    required this.completed,
    this.hasError = false,
  });

  const TaskFilterCounts.empty()
    : total = 0,
      pending = 0,
      completed = 0,
      hasError = false;

  const TaskFilterCounts.error()
    : total = -1,
      pending = -1,
      completed = -1,
      hasError = true;

  factory TaskFilterCounts.fromSnapshot(QuerySnapshot snapshot) {
    var completed = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isCompleted'] == true) {
        completed++;
      }
    }

    final total = snapshot.docs.length;
    return TaskFilterCounts(
      total: total,
      completed: completed,
      pending: total - completed,
    );
  }
}
