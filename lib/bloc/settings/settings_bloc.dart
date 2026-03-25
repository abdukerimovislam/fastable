import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/services/notification_service.dart'; // 🔥 ИМПОРТ НОТИФИКАЦИЙ
import 'package:fastable/l10n/app_localizations.dart'; // 🔥 ИМПОРТ ЛОКАЛИЗАЦИИ

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HealthService _healthService;
  final NotificationService _notificationService; // 🔥 ИНЪЕКЦИЯ

  // Обновленный конструктор
  SettingsBloc(this._healthService, this._notificationService) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleHealthSync>(_onToggleHealthSync);
    on<ToggleNotifications>(_onToggleNotifications);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    String themeStr = prefs.getString('theme_mode') ?? 'system';
    ThemeMode themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    String? savedLang = prefs.getString('locale_code');
    String langCode;

    if (savedLang != null) {
      langCode = savedLang;
    } else {
      try {
        final String systemLocale = Platform.localeName.split('_')[0];
        const supported = ['en', 'ru', 'es', 'pt'];

        if (supported.contains(systemLocale)) {
          langCode = systemLocale;
        } else {
          langCode = 'en';
        }
      } catch (e) {
        langCode = 'en';
      }
      await prefs.setString('locale_code', langCode);
    }

    Locale locale = Locale(langCode);

    bool health = prefs.getBool('health_sync') ?? false;
    bool notif = prefs.getBool('notifications_enabled') ?? true;

    emit(state.copyWith(
      themeMode: themeMode,
      locale: locale,
      isHealthSyncEnabled: health,
      areNotificationsEnabled: notif,
    ));
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', event.themeMode.name);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangeLocale(ChangeLocale event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));

    // 🔥 ПЕРЕВОДИМ УВЕДОМЛЕНИЯ ПРИ СМЕНЕ ЯЗЫКА!
    try {
      // Ищем загруженные локализации для выбранного языка (без контекста)
      final l10n = await lookupAppLocalizations(event.locale);
      await _notificationService.rescheduleAll(l10n);
      debugPrint("✅ Notifications rescheduled to language: ${event.locale.languageCode}");
    } catch (e) {
      debugPrint("⚠️ Failed to reschedule notifications: $e");
    }
  }

  Future<void> _onToggleHealthSync(ToggleHealthSync event, Emitter<SettingsState> emit) async {
    if (event.isEnabled) {
      bool granted = await _healthService.requestPermissions();
      if (!granted) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_sync', event.isEnabled);
    emit(state.copyWith(isHealthSyncEnabled: event.isEnabled));
  }

  Future<void> _onToggleNotifications(ToggleNotifications event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', event.isEnabled);
    emit(state.copyWith(areNotificationsEnabled: event.isEnabled));
  }
}