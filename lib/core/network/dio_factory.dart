import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DioFactory {
  DioFactory._();

  static Dio createAuthDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.authBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return dio;
  }
}
