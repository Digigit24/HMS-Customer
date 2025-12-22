// File Path: lib/core/theme/theme_constants.dart

import 'package:flutter/material.dart';

/// Available theme colors
enum AppThemeColor {
  blue,
  purple,
  green,
  orange,
}

/// Available font families
enum AppFontFamily {
  inter,
  poppins,
  roboto,
  montserrat,
}

/// Theme color schemes
class ThemeColors {
  // Blue Theme (Default - matches screenshot)
  static const Map<String, Color> blue = {
    'primary': Color(0xFF4F46E5), // Indigo
    'primaryDark': Color(0xFF4338CA),
    'primaryLight': Color(0xFF818CF8),
    'secondary': Color(0xFF10B981), // Emerald
    'accent': Color(0xFFF59E0B), // Amber
    'error': Color(0xFFEF4444),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'info': Color(0xFF3B82F6),
  };

  // Purple Theme
  static const Map<String, Color> purple = {
    'primary': Color(0xFF9333EA), // Purple
    'primaryDark': Color(0xFF7C3AED),
    'primaryLight': Color(0xFFA855F7),
    'secondary': Color(0xFFEC4899), // Pink
    'accent': Color(0xFF8B5CF6),
    'error': Color(0xFFEF4444),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'info': Color(0xFF3B82F6),
  };

  // Green Theme
  static const Map<String, Color> green = {
    'primary': Color(0xFF059669), // Emerald
    'primaryDark': Color(0xFF047857),
    'primaryLight': Color(0xFF10B981),
    'secondary': Color(0xFF14B8A6), // Teal
    'accent': Color(0xFF06B6D4),
    'error': Color(0xFFEF4444),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'info': Color(0xFF3B82F6),
  };

  // Orange Theme
  static const Map<String, Color> orange = {
    'primary': Color(0xFFF97316), // Orange
    'primaryDark': Color(0xFFEA580C),
    'primaryLight': Color(0xFFFB923C),
    'secondary': Color(0xFFEF4444), // Red
    'accent': Color(0xFFFBBF24),
    'error': Color(0xFFEF4444),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'info': Color(0xFF3B82F6),
  };

  static Map<String, Color> getColors(AppThemeColor theme) {
    switch (theme) {
      case AppThemeColor.blue:
        return blue;
      case AppThemeColor.purple:
        return purple;
      case AppThemeColor.green:
        return green;
      case AppThemeColor.orange:
        return orange;
    }
  }
}

/// Font family names for Google Fonts
class FontFamilies {
  static const String inter = 'Inter';
  static const String poppins = 'Poppins';
  static const String roboto = 'Roboto';
  static const String montserrat = 'Montserrat';

  static String getFontFamily(AppFontFamily font) {
    switch (font) {
      case AppFontFamily.inter:
        return inter;
      case AppFontFamily.poppins:
        return poppins;
      case AppFontFamily.roboto:
        return roboto;
      case AppFontFamily.montserrat:
        return montserrat;
    }
  }

  static String getFontDisplayName(AppFontFamily font) {
    switch (font) {
      case AppFontFamily.inter:
        return 'Inter';
      case AppFontFamily.poppins:
        return 'Poppins';
      case AppFontFamily.roboto:
        return 'Roboto';
      case AppFontFamily.montserrat:
        return 'Montserrat';
    }
  }
}

/// Common spacing values
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Common border radius values
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

/// Common elevation values
class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;
}
