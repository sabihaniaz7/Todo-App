import 'package:flutter/material.dart';

enum TaskFilter { all, pending, completed, inProgress }

class TaskFilterProvider extends ChangeNotifier {
  TaskFilter _filter = TaskFilter.all;

  TaskFilter get filter => _filter;

  void setFilter(TaskFilter f) {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
  }

  // Returns true/false/null for Firestore query (isCompleted / inProgress)
  bool? get completedFilter {
    switch (_filter) {
      case TaskFilter.all:
        return null;
      case TaskFilter.pending:
        return false;
      case TaskFilter.completed:
        return true;
      case TaskFilter.inProgress:
        return null; // handled separately
    }
  }

  bool get isInProgressFilter => _filter == TaskFilter.inProgress;

  String get label {
    switch (_filter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.inProgress:
        return 'In Progress';
    }
  }
}
