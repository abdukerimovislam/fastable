import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kThemeKey = 'app_theme';

class ThemeService {
  // Синглтон (единый экземпляр)
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // ValueNotifier - это специальный класс, который уведомляет "слушателей"
  // об изменении своего значения.
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String themeName =
        prefs.getString(kThemeKey) ?? ThemeMode.system.name;

    if (themeName == ThemeMode.light.name) {
      themeNotifier.value = ThemeMode.light;
    } else if (themeName == ThemeMode.dark.name) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    themeNotifier.value = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kThemeKey, themeMode.name);
  }
}
