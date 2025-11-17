import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_manager.dart';

enum AuthError {
  invalidResponse,
  unauthorized,
  networkError,
  registrationFailed,
  httpError,
}

class AuthException implements Exception {
  final AuthError error;
  final String? message;

  AuthException(this.error, [this.message]);

  @override
  String toString() {
    return message ?? error.toString();
  }
}

class AuthService {
  static final AuthService shared = AuthService._internal();

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://gread.fun/wp-json'));
  final _store = const FlutterSecureStorage();

  bool isAuthenticated = false;
  bool isGuestMode = false;
  User? currentUser;
  String? jwtToken;

  AuthService._internal();

  Future<void> initialize() async {
    await _loadAuthState();
  }

  Future<void> login(String username, String password) async {
    try {
      developer.log('Attempting login for user: $username', name: 'AuthService');

      final response = await _dio.post(
        '/jwt-auth/v1/token',
        data: {
          'username': username,
          'password': password,
        },
      );

      developer.log('JWT Response: ${response.data}', name: 'AuthService');

      // Check for error response
      if (response.data['code'] != null) {
        final message = response.data['message'] ?? 'Unknown error';
        developer.log('JWT Error detected: $message', name: 'AuthService');
        throw AuthException(
          AuthError.registrationFailed,
          'If you are a new user and your username is unique, check your email and verify your account.',
        );
      }

      if (response.statusCode == 403 || response.statusCode == 401) {
        throw AuthException(AuthError.unauthorized);
      }

      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        developer.log('JWT Auth failed with status: ${response.statusCode}', name: 'AuthService');
        throw AuthException(AuthError.httpError, 'HTTP Error: ${response.statusCode}');
      }

      final token = response.data['token'];
      if (token != null) {
        jwtToken = token;
        await _store.write(key: 'jwt', value: token);
        developer.log('Token saved successfully', name: 'AuthService');

        // Fetch current user
        await fetchCurrentUser();

        isAuthenticated = true;
        isGuestMode = false;
        await _saveAuthState();
      } else {
        throw AuthException(AuthError.invalidResponse, 'No token in response');
      }
    } on DioException catch (e) {
      developer.log('Login error: $e', name: 'AuthService', error: e);
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw AuthException(
          AuthError.registrationFailed,
          'If you are a new user and your username is unique, check your email and verify your account.',
        );
      }
      throw AuthException(AuthError.networkError, e.message);
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      developer.log('Attempting registration for user: $username', name: 'AuthService');

      final response = await _dio.post(
        '/buddypress/v1/signup',
        data: {
          'user_login': username,
          'user_email': email,
          'password': password,
          'signup_field_data': [
            {
              'field_id': 1,
              'value': username,
            }
          ],
        },
      );

      developer.log('Registration Response: ${response.data}', name: 'AuthService');

      if (response.statusCode == 400 || response.statusCode == 409) {
        String? errorMessage;
        final data = response.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'];
        }

        if (errorMessage != null) {
          final lowercased = errorMessage.toLowerCase();
          if (lowercased.contains('email is already registered') ||
              lowercased.contains('email address is already in use') ||
              lowercased.contains('sorry, that email address is already used!')) {
            throw AuthException(
              AuthError.registrationFailed,
              'This email address is already registered.',
            );
          }
          if (lowercased.contains('sorry, that username already exists') ||
              lowercased.contains('username is already in use')) {
            throw AuthException(
              AuthError.registrationFailed,
              'This username is already taken. Please choose another.',
            );
          }
        }
        throw AuthException(
          AuthError.registrationFailed,
          'Registration failed. Please check your information.',
        );
      }

      if (response.statusCode! < 200 || response.statusCode! >= 300) {
        developer.log('Registration failed with status: ${response.statusCode}', name: 'AuthService');
        throw AuthException(
          AuthError.registrationFailed,
          'Registration failed. Please try again.',
        );
      }

      // Try to auto-login
      try {
        await login(username, password);
      } on AuthException catch (e) {
        if (e.error == AuthError.unauthorized) {
          throw AuthException(
            AuthError.registrationFailed,
            'Account created! Please check your email to activate your account before logging in.',
          );
        }
        rethrow;
      }
    } on DioException catch (e) {
      developer.log('Registration error: $e', name: 'AuthService', error: e);
      throw AuthException(AuthError.networkError, e.message);
    } catch (e) {
      developer.log('Registration error: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  void enterGuestMode() {
    isGuestMode = true;
    isAuthenticated = false;
  }

  Future<void> logout() async {
    try {
      jwtToken = null;
      currentUser = null;
      isAuthenticated = false;
      isGuestMode = false;
      await _store.delete(key: 'jwt');
      await _store.delete(key: 'userId');
      developer.log('Logout successful', name: 'AuthService');
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService', error: e);
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      currentUser = await APIManager.shared.getCurrentUser();
      developer.log('Current user fetched: ${currentUser?.name}', name: 'AuthService');
    } catch (e) {
      developer.log('Failed to fetch current user: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<String?> getToken() async {
    if (jwtToken != null) return jwtToken;

    try {
      final token = await _store.read(key: 'jwt');
      if (token != null) {
        jwtToken = token;
        developer.log('Retrieved JWT token from storage', name: 'AuthService');
      } else {
        developer.log('No JWT token found in storage', name: 'AuthService');
      }
      return token;
    } catch (e) {
      developer.log('Error reading token: $e', name: 'AuthService', error: e);
      return null;
    }
  }

  Future<void> _saveAuthState() async {
    if (jwtToken != null) {
      await _store.write(key: 'jwt', value: jwtToken!);
    }
    if (currentUser?.id != null) {
      await _store.write(key: 'userId', value: currentUser!.id.toString());
    }
  }

  Future<void> _loadAuthState() async {
    final token = await _store.read(key: 'jwt');
    if (token == null) return;

    jwtToken = token;
    isAuthenticated = true;

    try {
      await fetchCurrentUser();
    } catch (e) {
      // Token might be expired, logout
      developer.log('Token expired, logging out', name: 'AuthService');
      await logout();
    }
  }
}
