import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://gread.fun/wp-json'));
  final _store = const FlutterSecureStorage();

  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/jwt-auth/v1/token',
        data: {
          "username": username,
          "password": password,
        },
      );

      final token = response.data['token'];
      if (token != null) {
        await _store.write(key: 'jwt', value: token);
        return token;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _store.delete(key: 'jwt');
  }

  Future<String?> getToken() async {
    return await _store.read(key: 'jwt');
  }
}
