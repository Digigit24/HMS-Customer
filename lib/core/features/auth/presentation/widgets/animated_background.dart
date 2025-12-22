// File Path: lib/core/features/auth/presentation/widgets/animated_background.dart

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                    ]
                  : [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFE3F2FD),
                    ],
            ),
          ),
        ),

        // Animated blob 1
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -150 + (_controller.value * 50),
              right: -100 + (_controller.value * 30),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.4),
                      const Color(0xFF764BA2).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(175),
                ),
              ),
            );
          },
        ),

        // Animated blob 2
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: -200 + (_controller.value * -40),
              left: -150 + (_controller.value * -20),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF093FB).withOpacity(0.3),
                      const Color(0xFFF5576C).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            );
          },
        ),

        // Animated blob 3
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: 200 + (_controller.value * 30),
              left: -50 + (_controller.value * 20),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.15),
                      const Color(0xFF059669).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
