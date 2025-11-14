import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _loggedIn = false;
  User? _user;

  bool get loggedIn => _loggedIn;
  User? get user => _user;

  /// Initialize the auth state - check if user is already logged in
  Future<void> initializeAuth() async {
    developer.log(
      'Initializing auth provider',
      name: 'AuthProvider',
    );

    try {
      final token = await _auth.getToken();
      if (token != null) {
        developer.log(
          'Found existing token, user is already logged in',
          name: 'AuthProvider',
        );
        _loggedIn = true;
      } else {
        developer.log(
          'No existing token found',
          name: 'AuthProvider',
        );
        _loggedIn = false;
      }
      notifyListeners();
    } catch (e) {
      developer.log(
        'Error during auth initialization: $e',
        name: 'AuthProvider',
        error: e,
      );
      _loggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      developer.log(
        'AuthProvider.login() called for username: $username',
        name: 'AuthProvider',
      );

      final token = await _auth.login(username, password);

      developer.log(
        'AuthService.login() returned token: ${token != null}',
        name: 'AuthProvider',
      );

      if (token != null) {
        _loggedIn = true;
        developer.log(
          'Login successful, notifying listeners',
          name: 'AuthProvider',
        );
        notifyListeners();
        return true;
      }

      developer.log(
        'Login failed - no token returned',
        name: 'AuthProvider',
      );
      return false;
    } catch (e) {
      developer.log(
        'Login error: $e',
        name: 'AuthProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      developer.log(
        'Logout called',
        name: 'AuthProvider',
      );
      await _auth.logout();
      _loggedIn = false;
      _user = null;
      notifyListeners();
      developer.log(
        'Logout successful',
        name: 'AuthProvider',
      );
    } catch (e) {
      developer.log(
        'Logout error: $e',
        name: 'AuthProvider',
        error: e,
      );
    }
  }
}
