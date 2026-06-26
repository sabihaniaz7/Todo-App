import 'package:flutter/material.dart';

enum TaskFilter { all, pending, completed, inProgress }

class TaskFilterProvider extends ChangeNotifier {
  TaskFilter _filter = TaskFilter.all;
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentWeekStart = _getWeekStart(_selectedDate);

  TaskFilter get filter => _filter;
  DateTime get selectedDate => _selectedDate;
  DateTime get currentWeekStart => _currentWeekStart;

  void setFilter(TaskFilter f) {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    if (_isSameDay(_selectedDate, date)) return;
    _selectedDate = date;
    _currentWeekStart = _getWeekStart(date);
    notifyListeners();
  }

  void showPreviousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void showNextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday; // 1=monday, 7=sunday
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
