import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isHealthSyncEnabled;
  final bool areNotificationsEnabled;
  final bool notifyWater;
  final bool notifyWeight;
  final bool notifyFastingStart;
  final bool reducedAnimations;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.isHealthSyncEnabled = false,
    this.areNotificationsEnabled = true,
    this.notifyWater = false,
    this.notifyWeight = false,
    this.notifyFastingStart = false,
    this.reducedAnimations = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isHealthSyncEnabled,
    bool? areNotificationsEnabled,
    bool? notifyWater,
    bool? notifyWeight,
    bool? notifyFastingStart,
    bool? reducedAnimations,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isHealthSyncEnabled: isHealthSyncEnabled ?? this.isHealthSyncEnabled,
      areNotificationsEnabled:
          areNotificationsEnabled ?? this.areNotificationsEnabled,
      notifyWater: notifyWater ?? this.notifyWater,
      notifyWeight: notifyWeight ?? this.notifyWeight,
      notifyFastingStart: notifyFastingStart ?? this.notifyFastingStart,
      reducedAnimations: reducedAnimations ?? this.reducedAnimations,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    locale,
    isHealthSyncEnabled,
    areNotificationsEnabled,
    notifyWater,
    notifyWeight,
    notifyFastingStart,
    reducedAnimations,
  ];
}
