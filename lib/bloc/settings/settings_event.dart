import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузить настройки при старте
class LoadSettings extends SettingsEvent {}

/// Сменить тему
class ChangeTheme extends SettingsEvent {
  final ThemeMode themeMode;
  const ChangeTheme(this.themeMode);
}

/// Сменить язык
class ChangeLocale extends SettingsEvent {
  final Locale locale;
  const ChangeLocale(this.locale);
}

/// Переключить синхронизацию здоровья
class ToggleHealthSync extends SettingsEvent {
  final bool isEnabled;
  const ToggleHealthSync(this.isEnabled);
}

/// Переключить уведомления
class ToggleNotifications extends SettingsEvent {
  final bool isEnabled;
  const ToggleNotifications(this.isEnabled);
}