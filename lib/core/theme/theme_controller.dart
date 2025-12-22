// File Path: lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_constants.dart';

class ThemeController extends GetxController {
  static const String _themeModeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';
  static const String _fontFamilyKey = 'font_family';

  // Observable properties
  final _themeMode = ThemeMode.light.obs;
  final _themeColor = AppThemeColor.blue.obs;
  final _fontFamily = AppFontFamily.inter.obs;

  // Getters
  ThemeMode get themeMode => _themeMode.value;
  AppThemeColor get themeColor => _themeColor.value;
  AppFontFamily get fontFamily => _fontFamily.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  /// Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeStr = prefs.getString(_themeModeKey);
    if (themeModeStr != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeStr,
        orElse: () => ThemeMode.light,
      );
    }

    // Load theme color
    final themeColorStr = prefs.getString(_themeColorKey);
    if (themeColorStr != null) {
      _themeColor.value = AppThemeColor.values.firstWhere(
        (color) => color.toString() == themeColorStr,
        orElse: () => AppThemeColor.blue,
      );
    }

    // Load font family
    final fontFamilyStr = prefs.getString(_fontFamilyKey);
    if (fontFamilyStr != null) {
      _fontFamily.value = AppFontFamily.values.firstWhere(
        (font) => font.toString() == fontFamilyStr,
        orElse: () => AppFontFamily.inter,
      );
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleThemeMode() async {
    _themeMode.value =
        isDarkMode ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.value.toString());

    Get.forceAppUpdate();
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());

    Get.forceAppUpdate();
  }

  /// Change theme color
  Future<void> setThemeColor(AppThemeColor color) async {
    _themeColor.value = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorKey, color.toString());

    Get.forceAppUpdate();
  }

  /// Change font family
  Future<void> setFontFamily(AppFontFamily font) async {
    _fontFamily.value = font;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, font.toString());

    Get.forceAppUpdate();
  }

  /// Get color by key
  Color getColor(String key) {
    final colors = ThemeColors.getColors(_themeColor.value);
    return colors[key] ?? colors['primary']!;
  }

  /// Get current font family name
  String getCurrentFontFamily() {
    return FontFamilies.getFontFamily(_fontFamily.value);
  }
}
