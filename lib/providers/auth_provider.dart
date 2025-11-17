import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.shared;

  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isGuestMode => _authService.isGuestMode;
  User? get currentUser => _authService.currentUser;

  Future<void> initialize() async {
    await _authService.initialize();
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    await _authService.login(username, password);
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    await _authService.register(username, email, password);
    notifyListeners();
  }

  void enterGuestMode() {
    _authService.enterGuestMode();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
