import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/services/health_service.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HealthService _healthService;

  SettingsBloc(this._healthService) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleHealthSync>(_onToggleHealthSync);
    on<ToggleNotifications>(_onToggleNotifications);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Тема
    String themeStr = prefs.getString('theme_mode') ?? 'system';
    ThemeMode themeMode = ThemeMode.values.firstWhere(
            (e) => e.name == themeStr, orElse: () => ThemeMode.system
    );

    // 2. Язык
    String langCode = prefs.getString('locale_code') ?? 'en';
    // Если язык не сохранен, берем системный, но поддерживаемый
    if (!['en', 'ru', 'es', 'pt'].contains(langCode)) {
      langCode = 'en';
    }
    Locale locale = Locale(langCode);

    // 3. Настройки
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
  }

  Future<void> _onToggleHealthSync(ToggleHealthSync event, Emitter<SettingsState> emit) async {
    if (event.isEnabled) {
      // Запрашиваем права
      bool granted = await _healthService.requestPermissions();
      if (!granted) {
        // Если отказали, не включаем тоггл (можно добавить статус ошибки)
        return;
      }
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