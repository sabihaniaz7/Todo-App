import 'package:flutter/material.dart';

class ProfileScreenProvider extends ChangeNotifier {
  bool _uploading = false;

  bool get uploading => _uploading;

  Future<void> upload(Future<void> Function() action) async {
    if (_uploading) return;
    _uploading = true;
    notifyListeners();

    try {
      await action();
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }
}
