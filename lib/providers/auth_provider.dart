import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loggedIn = false;
  User? _user;

  bool get loggedIn => _loggedIn;
  User? get user => _user;

  Future<bool> login(String username, String password) async {
    try {
      final token = await _auth.login(username, password);
      if (token != null) {
        _loggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    _loggedIn = false;
    _user = null;
    notifyListeners();
  }
}
