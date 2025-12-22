// File Path: lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_constants.dart';

class AppTheme {
  /// Get theme based on color scheme and font
  static ThemeData getTheme({
    required Brightness brightness,
    required AppThemeColor themeColor,
    required AppFontFamily fontFamily,
  }) {
    final colors = ThemeColors.getColors(themeColor);
    final isDark = brightness == Brightness.dark;

    final textTheme = _getTextTheme(fontFamily, isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _getColorScheme(colors, brightness),
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      appBarTheme: _getAppBarTheme(isDark, textTheme),

      // ✅ FIX: ThemeData.cardTheme expects CardThemeData? (not CardTheme widget)
      cardTheme: _getCardTheme(isDark),

      elevatedButtonTheme: _getElevatedButtonTheme(colors),
      outlinedButtonTheme: _getOutlinedButtonTheme(colors, isDark),
      textButtonTheme: _getTextButtonTheme(colors),
      inputDecorationTheme: _getInputDecorationTheme(isDark),
      bottomNavigationBarTheme: _getBottomNavTheme(colors, isDark),
      floatingActionButtonTheme: _getFloatingActionButtonTheme(colors),
      chipTheme: _getChipTheme(colors, isDark),
      dividerTheme: _getDividerTheme(isDark),
      switchTheme: _getSwitchTheme(colors),
    );
  }

  static ColorScheme _getColorScheme(
      Map<String, Color> colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ColorScheme(
      brightness: brightness,
      primary: colors['primary']!,
      onPrimary: Colors.white,
      primaryContainer:
          isDark ? colors['primaryDark']! : colors['primaryLight']!,
      onPrimaryContainer: isDark ? Colors.white : colors['primaryDark']!,
      secondary: colors['secondary']!,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? colors['secondary']!.withOpacity(0.3)
          : colors['secondary']!.withOpacity(0.1),
      onSecondaryContainer: isDark ? Colors.white : colors['secondary']!,
      error: colors['error']!,
      onError: Colors.white,
      errorContainer: isDark
          ? colors['error']!.withOpacity(0.3)
          : colors['error']!.withOpacity(0.1),
      onErrorContainer: isDark ? Colors.white : colors['error']!,
      surface: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSurface: isDark ? Colors.white : const Color(0xFF1F2937),
      surfaceContainerHighest:
          isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      onSurfaceVariant:
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      outline: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
      outlineVariant:
          isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      shadow: Colors.black.withOpacity(0.1),
      inverseSurface: isDark ? Colors.white : const Color(0xFF0F172A),
      onInverseSurface: isDark ? const Color(0xFF0F172A) : Colors.white,
      inversePrimary: colors['primaryLight']!,
    );
  }

  static TextTheme _getTextTheme(AppFontFamily fontFamily, bool isDark) {
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    switch (fontFamily) {
      case AppFontFamily.inter:
        return GoogleFonts.interTextTheme(baseTextTheme);
      case AppFontFamily.poppins:
        return GoogleFonts.poppinsTextTheme(baseTextTheme);
      case AppFontFamily.roboto:
        return GoogleFonts.robotoTextTheme(baseTextTheme);
      case AppFontFamily.montserrat:
        return GoogleFonts.montserratTextTheme(baseTextTheme);
    }
  }

  static AppBarTheme _getAppBarTheme(bool isDark, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      foregroundColor: isDark ? Colors.white : const Color(0xFF1F2937),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1F2937),
      ),
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  // ✅ FIXED: Return CardThemeData (ThemeData.cardTheme uses this)
  static CardThemeData _getCardTheme(bool isDark) {
    return CardThemeData(
      elevation: isDark ? 2 : 1,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _getElevatedButtonTheme(
      Map<String, Color> colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors['primary'],
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _getOutlinedButtonTheme(
      Map<String, Color> colors, bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors['primary'],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: BorderSide(color: colors['primary']!, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static TextButtonThemeData _getTextButtonTheme(Map<String, Color> colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors['primary'],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static InputDecorationTheme _getInputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static BottomNavigationBarThemeData _getBottomNavTheme(
      Map<String, Color> colors, bool isDark) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      selectedItemColor: colors['primary'],
      unselectedItemColor:
          isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static FloatingActionButtonThemeData _getFloatingActionButtonTheme(
      Map<String, Color> colors) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors['primary'],
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }

  static ChipThemeData _getChipTheme(Map<String, Color> colors, bool isDark) {
    return ChipThemeData(
      backgroundColor:
          isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      deleteIconColor: colors['primary'],
      labelStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static DividerThemeData _getDividerTheme(bool isDark) {
    return DividerThemeData(
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      thickness: 1,
      space: 1,
    );
  }

  static SwitchThemeData _getSwitchTheme(Map<String, Color> colors) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors['primary'];
        }
        return const Color(0xFFE2E8F0);
      }),
    );
  }
}
