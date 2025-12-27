// File Path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/features/auth/data/repositories/auth_repository.dart';
import 'core/features/auth/presentation/controller/auth_controller.dart';
import 'core/features/auth/presentation/pages/dashboard_page.dart';
import 'core/features/auth/presentation/pages/login_page.dart';
import 'core/features/auth/presentation/pages/splash_page.dart';
import 'core/network/dio_factory.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_constants.dart';
import 'core/theme/theme_controller.dart';
import 'core/data/repositories/order_repository.dart';
import 'core/services/payment_service.dart';
import 'features/dashboard/presentation/pages/dashboard_shell.dart';
import 'features/appointments/presentation/pages/book_appointment_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.instance.preload();

  final authDio = DioFactory.createAuthDio();
  final authRepo = AuthRepository(authDio: authDio);

  // Initialize core services
  Get.put(AuthController(repo: authRepo));
  Get.put(ThemeController());

  // Initialize payment-related services
  final hmsDio = DioFactory.createHmsDio();
  Get.put(OrderRepository(dio: hmsDio));
  Get.put(PaymentService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HealthCare App',

        // Theme configuration
        theme: AppTheme.getTheme(
          brightness: Brightness.light,
          themeColor: themeController.themeColor,
          fontFamily: themeController.fontFamily,
        ),
        darkTheme: AppTheme.getTheme(
          brightness: Brightness.dark,
          themeColor: themeController.themeColor,
          fontFamily: themeController.fontFamily,
        ),
        themeMode: themeController.themeMode,

        // Routes
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashPage()),
          GetPage(name: '/login', page: () => const LoginPage()),
          GetPage(name: '/dashboard', page: () => const DashboardShell()),
          GetPage(name: '/dashboard-old', page: () => const DashboardPage()),
        ],
      );
    });
  }
}
