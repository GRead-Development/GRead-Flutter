import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://gread.fun/wp-json'));
  final _store = const FlutterSecureStorage();

  Future<String?> login(String username, String password) async {
    try {
      developer.log(
        'Attempting login for user: $username',
        name: 'AuthService',
      );

      final response = await _dio.post(
        '/jwt-auth/v1/token',
        data: {
          "username": username,
          "password": password,
        },
      );

      developer.log(
        'Login response status: ${response.statusCode}',
        name: 'AuthService',
      );

      final token = response.data['token'];
      if (token != null) {
        await _store.write(key: 'jwt', value: token);
        developer.log(
          'Token saved successfully (${token.substring(0, 20)}...)',
          name: 'AuthService',
        );
        return token;
      }
      developer.log('No token in response', name: 'AuthService');
      return null;
    } catch (e) {
      developer.log(
        'Login error: $e',
        name: 'AuthService',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _store.delete(key: 'jwt');
      developer.log('Logout successful - token deleted', name: 'AuthService');
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService', error: e);
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _store.read(key: 'jwt');
      if (token != null) {
        developer.log(
          'Retrieved JWT token (${token.substring(0, 20)}...)',
          name: 'AuthService',
        );
      } else {
        developer.log('No JWT token found in storage', name: 'AuthService');
      }
      return token;
    } catch (e) {
      developer.log('Error reading token: $e', name: 'AuthService', error: e);
      return null;
    }
  }
}
