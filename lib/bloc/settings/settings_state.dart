import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isHealthSyncEnabled;
  final bool areNotificationsEnabled;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.isHealthSyncEnabled = false,
    this.areNotificationsEnabled = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isHealthSyncEnabled,
    bool? areNotificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isHealthSyncEnabled: isHealthSyncEnabled ?? this.isHealthSyncEnabled,
      areNotificationsEnabled: areNotificationsEnabled ?? this.areNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, isHealthSyncEnabled, areNotificationsEnabled];
}