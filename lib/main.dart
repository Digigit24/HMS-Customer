import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/features/auth/data/repositories/auth_repository.dart';
import 'core/features/auth/presentation/controller/auth_controller.dart';
import 'core/features/auth/presentation/pages/dashboard_page.dart';
import 'core/features/auth/presentation/pages/login_page.dart';
import 'core/features/auth/presentation/pages/splash_page.dart';
import 'core/network/dio_factory.dart';
import 'features/dashboard/presentation/pages/dashboard_shell.dart';
import 'features/appointments/presentation/pages/book_appointment_page.dart';

void main() {
  final authDio = DioFactory.createAuthDio();
  final authRepo = AuthRepository(authDio: authDio);

  Get.put(AuthController(repo: authRepo));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const DashboardShell()),
        GetPage(
            name: '/book-appointment', page: () => const BookAppointmentPage()),
      ],
    );
  }
}
