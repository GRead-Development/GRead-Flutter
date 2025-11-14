import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  late Dio dio;
  final _auth = AuthService();

  ApiService() {
    dio = Dio(BaseOptions(baseUrl: 'https://gread.fun/wp-json'));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _auth.getToken();
          developer.log(
            'API Request: ${options.method.toUpperCase()} ${options.baseUrl}${options.path}',
            name: 'ApiService',
          );
          developer.log(
            'Query params: ${options.queryParameters}',
            name: 'ApiService',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            developer.log(
              'Added JWT token (${token.substring(0, 20)}...)',
              name: 'ApiService',
            );
          } else {
            developer.log('No JWT token found', name: 'ApiService');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            'API Response: ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiService',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            'API Error: ${error.response?.statusCode} - ${error.message}',
            name: 'ApiService',
            error: error,
          );
          if (error.response != null) {
            developer.log(
              'Error response data: ${error.response?.data}',
              name: 'ApiService',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }
}
