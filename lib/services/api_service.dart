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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
