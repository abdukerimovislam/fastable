import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Для PlatformDispatcher
import 'package:fastable/core/app_prefs_keys.dart';

// Backward-compatible aliases — use AppPrefsKeys.* directly in new code
const String kLocaleKey = AppPrefsKeys.localeCode;
const String _legacyLocaleKey = AppPrefsKeys.legacyLocaleCode;

class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  // Слушатель изменений языка
  final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    const Locale('en'),
  );

  // Загрузка сохраненного языка
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode =
        prefs.getString(kLocaleKey) ?? prefs.getString(_legacyLocaleKey);

    if (languageCode != null) {
      // Если пользователь уже выбирал язык, используем его
      localeNotifier.value = Locale(languageCode);
      if (!prefs.containsKey(kLocaleKey)) {
        await prefs.setString(kLocaleKey, languageCode);
      }
    } else {
      // Если нет, пытаемся определить язык системы, если он поддерживается
      // (Для простоты, если ничего не сохранено, оставляем дефолтным или системным,
      // здесь мы просто не меняем значение по умолчанию, если оно совпадает с поддерживаемым)
      final systemLoc = PlatformDispatcher.instance.locale.languageCode;
      if (['en', 'ru', 'es', 'pt'].contains(systemLoc)) {
        localeNotifier.value = Locale(systemLoc);
      }
    }
  }

  // Смена языка
  Future<void> setLocale(String languageCode) async {
    localeNotifier.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLocaleKey, languageCode);
    if (prefs.containsKey(_legacyLocaleKey)) {
      await prefs.remove(_legacyLocaleKey);
    }
  }
}
