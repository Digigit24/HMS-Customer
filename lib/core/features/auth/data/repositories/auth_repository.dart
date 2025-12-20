import 'package:dio/dio.dart';
import '../../../../config/api_config.dart';
import '../../../../network/api_exceptions.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepository {
  final Dio authDio;
  AuthRepository({required this.authDio});

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final res = await authDio.post(ApiConfig.login, data: request.toJson());

      print('LOGIN RAW RESPONSE: ${res.data}');

      if (res.data is Map) {
        final parsed =
            LoginResponse.fromJson(Map<String, dynamic>.from(res.data));

        if (parsed.access.isEmpty || parsed.refresh.isEmpty) {
          throw ApiException('Login succeeded but tokens are empty');
        }

        return parsed;
      }

      throw ApiException('Unexpected login response format');
    } on DioException catch (e) {
      final data = e.response?.data;

      String message = 'Login failed';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      throw ApiException(message, statusCode: e.response?.statusCode);
    }
  }
}
