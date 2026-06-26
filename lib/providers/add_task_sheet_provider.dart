import 'package:flutter/material.dart';

class AddTaskSheetProvider extends ChangeNotifier {
  bool _saving = false;
  bool _disposed = false;

  bool get saving => _saving;

  Future<void> save(Future<void> Function() action) async {
    if (_saving) return;
    _saving = true;
    notifyListeners();

    try {
      await action();
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
