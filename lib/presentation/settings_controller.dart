import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/preferences_service.dart';

class SettingsController extends GetxController {
  final PreferencesService prefs;

  SettingsController({required this.prefs});

  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    themeMode.value = await prefs.getThemeMode();
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    await prefs.setThemeMode(mode);
    Get.changeThemeMode(mode); // applies immediately
  }

  String themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }
}
