// File Path: lib/core/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/auth_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          const AnimatedBackground(),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_hospital,
                              size: 50,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App Name
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            'Welcome to\nHealthCare',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              fontSize: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            'Your trusted healthcare partner for\nhealth and wellness',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Login Buttons
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Sign In
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 600),
                          child: Obx(
                            () => SocialLoginButton(
                              onPressed: () {
                                // TODO: Implement Google Sign In
                                Get.offAllNamed('/dashboard');
                              },
                              icon: Icons.g_mobiledata,
                              label: 'Continue with Google',
                              backgroundColor: Colors.white,
                              textColor: Colors.black87,
                              borderColor: const Color(0xFFE2E8F0),
                              isLoading: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Apple Sign In
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 800),
                          child: Obx(
                            () => SocialLoginButton(
                              onPressed: () {
                                // TODO: Implement Apple Sign In
                              },
                              icon: Icons.apple,
                              label: 'Continue with Apple',
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              isLoading: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Terms and Privacy
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 1000),
                          child: Text(
                            'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
