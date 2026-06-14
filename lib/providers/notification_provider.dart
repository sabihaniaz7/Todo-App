import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _key = 'notificationsEnabled';
  bool _enabled = true;
  bool get enabled => _enabled;

  NotificationProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _enabled = !_enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _enabled);
  }
}
