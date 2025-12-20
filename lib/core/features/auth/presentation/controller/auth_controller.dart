import 'package:get/get.dart';
import '../../../../network/api_exceptions.dart';
import '../../../../storage/token_storage.dart';
import '../../data/models/login_request.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository repo;
  AuthController({required this.repo});

  final isLoading = false.obs;
  final errorText = ''.obs;

  Future<void> checkAuthAndRoute() async {
    final token = await TokenStorage.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    errorText.value = '';
    isLoading.value = true;

    try {
      final res = await repo.login(LoginRequest(
        emailOrPhone: emailOrPhone.trim(),
        password: password,
      ));

      await TokenStorage.instance.saveTokens(
        accessToken: res.access,
        refreshToken: res.refresh,
      );

      Get.offAllNamed('/dashboard');
    } on ApiException catch (e) {
      errorText.value = e.message;
    } catch (_) {
      errorText.value = 'Something went wrong. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.instance.clear();
    Get.offAllNamed('/login');
  }
}
