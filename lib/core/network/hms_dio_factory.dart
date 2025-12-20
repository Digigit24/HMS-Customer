import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class HmsDioFactory {
  HmsDioFactory._();

  static Dio create({required String baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl, // ✅ should be https://hms.celiyo.com
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.instance.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }
}
