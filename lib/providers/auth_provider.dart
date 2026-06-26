import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }
}
