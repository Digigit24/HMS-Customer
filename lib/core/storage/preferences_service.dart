import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PreferencesService {
  static const _kThemeMode = 'theme_mode'; // 0=system, 1=light, 2=dark

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kThemeMode) ?? 0;
    return ThemeMode.values[v.clamp(0, 2)];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode.index);
  }
}
