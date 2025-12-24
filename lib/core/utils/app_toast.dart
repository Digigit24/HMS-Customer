import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AppToast {
  AppToast._();

  static final FToast _fToast = FToast();
  static BuildContext? _lastContext;

  static void showSuccess(String message) {
    _show(
      message,
      accentColor: Colors.green,
    );
  }

  static void showError(String message) {
    _show(
      message,
      accentColor: Colors.red,
    );
  }

  static void showInfo(String message) {
    _show(
      message,
      accentColor: Colors.blue,
    );
  }

  static void _show(
    String message, {
    Color? accentColor,
  }) {
    if (message.isEmpty) return;
    _initIfNeeded();

    final context = _lastContext;
    if (context != null) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
      final borderColor =
          isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade300;
      final textColor = isDark ? Colors.white : Colors.black87;
      final indicator = (accentColor ?? theme.colorScheme.primary)
          .withOpacity(isDark ? 0.8 : 0.9);

      _fToast.removeQueuedCustomToasts();
      _fToast.showToast(
        toastDuration: const Duration(seconds: 2),
        gravity: ToastGravity.BOTTOM,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 32,
                decoration: BoxDecoration(
                  color: indicator,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Fallback if no context available.
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      fontSize: 14,
    );
  }

  static void _initIfNeeded() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx != null && ctx != _lastContext) {
      _lastContext = ctx;
      _fToast.init(ctx);
    }
  }
}
