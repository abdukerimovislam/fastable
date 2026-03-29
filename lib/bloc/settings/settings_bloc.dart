import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

const String _legacyLocaleKey = 'app_locale';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HealthService _healthService;
  final NotificationService _notificationService;

  SettingsBloc(this._healthService, this._notificationService)
    : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleHealthSync>(_onToggleHealthSync);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleWaterReminder>(_onToggleWaterReminder);
    on<ToggleWeightReminder>(_onToggleWeightReminder);
    on<ToggleFastingStartReminder>(_onToggleFastingStartReminder);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await HealthSyncPreferences.migrateLegacy(prefs);

    String themeStr = prefs.getString('theme_mode') ?? 'system';
    ThemeMode themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    String? savedLang =
        prefs.getString('locale_code') ?? prefs.getString(_legacyLocaleKey);
    String langCode;

    if (savedLang != null) {
      langCode = savedLang;
      if (!prefs.containsKey('locale_code')) {
        await prefs.setString('locale_code', savedLang);
      }
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

    bool health = await HealthSyncPreferences.isEnabled(prefs);
    bool notif = prefs.getBool('notifications_enabled') ?? true;
    final notifyWater = prefs.getBool(kNotifyWaterKey) ?? false;
    final notifyWeight = prefs.getBool(kNotifyWeightKey) ?? false;
    final notifyFastingStart = prefs.getBool(kNotifyFastingStartKey) ?? false;

    emit(
      state.copyWith(
        themeMode: themeMode,
        locale: locale,
        isHealthSyncEnabled: health,
        areNotificationsEnabled: notif,
        notifyWater: notifyWater,
        notifyWeight: notifyWeight,
        notifyFastingStart: notifyFastingStart,
      ),
    );
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', event.themeMode.name);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));

    // 🔥 ПЕРЕВОДИМ УВЕДОМЛЕНИЯ ТОЛЬКО ЕСЛИ ОНИ ВКЛЮЧЕНЫ
    if (state.areNotificationsEnabled) {
      try {
        final l10n = lookupAppLocalizations(event.locale);
        await _notificationService.rescheduleAll(l10n);
        debugPrint(
          "✅ Notifications rescheduled to language: ${event.locale.languageCode}",
        );
      } catch (e) {
        debugPrint("⚠️ Failed to reschedule notifications: $e");
      }
    }
  }

  Future<void> _onToggleHealthSync(
    ToggleHealthSync event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final wasEnabled = await HealthSyncPreferences.isEnabled(prefs);

    if (event.isEnabled && !wasEnabled && event.requestPermissions) {
      bool granted = await _healthService.requestPermissions();
      if (!granted) return;
    }

    await HealthSyncPreferences.setEnabled(event.isEnabled, prefs);
    emit(state.copyWith(isHealthSyncEnabled: event.isEnabled));
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', event.isEnabled);
    emit(state.copyWith(areNotificationsEnabled: event.isEnabled));

    // 🔥 ФИКС: РЕАЛЬНОЕ ВКЛЮЧЕНИЕ / ВЫКЛЮЧЕНИЕ ПУШЕЙ В СИСТЕМЕ
    if (event.isEnabled) {
      try {
        final l10n = lookupAppLocalizations(state.locale);
        await _notificationService.rescheduleAll(l10n);
        debugPrint("✅ Notifications turned ON and rescheduled.");
      } catch (e) {
        debugPrint("⚠️ Failed to reschedule notifications: $e");
      }
    } else {
      await _notificationService.cancelAllNotifications();
      debugPrint("⏹ Notifications turned OFF. All scheduled pushes cancelled.");
    }
  }

  Future<void> _onToggleWaterReminder(
    ToggleWaterReminder event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifyWaterKey, event.isEnabled);
    emit(state.copyWith(notifyWater: event.isEnabled));

    if (event.isEnabled) {
      if (!state.areNotificationsEnabled) return;
      final l10n = lookupAppLocalizations(state.locale);
      await _notificationService.scheduleDailyWaterReminders(l10n);
      return;
    }

    await _notificationService.cancelWaterReminders();
  }

  Future<void> _onToggleWeightReminder(
    ToggleWeightReminder event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifyWeightKey, event.isEnabled);
    emit(state.copyWith(notifyWeight: event.isEnabled));

    if (event.isEnabled) {
      if (!state.areNotificationsEnabled) return;
      final l10n = lookupAppLocalizations(state.locale);
      await _notificationService.scheduleDailyWeightReminder(l10n);
      return;
    }

    await _notificationService.cancelWeightReminder();
  }

  Future<void> _onToggleFastingStartReminder(
    ToggleFastingStartReminder event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotifyFastingStartKey, event.isEnabled);
    emit(state.copyWith(notifyFastingStart: event.isEnabled));

    if (!event.isEnabled) {
      await _notificationService.cancelEatingNotifications();
      return;
    }

    if (!state.areNotificationsEnabled) return;

    final appState = prefs.getString('app_state');
    final cycleStart = prefs.getString('cycle_start_time');
    if (appState != FastingPhase.eating.name || cycleStart == null) {
      return;
    }

    final startTime = DateTime.tryParse(cycleStart);
    if (startTime == null) return;

    final planIndex = prefs.getInt('fast_plan_index') ?? 0;
    final customHours = prefs.getInt('custom_target_hours') ?? 14;
    final circadianMinutes =
        prefs.getInt('circadian_target_minutes') ??
        const Duration(hours: 14).inMinutes;

    final l10n = lookupAppLocalizations(state.locale);
    await _notificationService.scheduleEatingNotifications(
      startTime: startTime,
      duration: _resolveEatingDuration(
        planIndex: planIndex,
        customHours: customHours,
        circadianMinutes: circadianMinutes,
      ),
      l10n: l10n,
    );
  }

  Duration _resolveEatingDuration({
    required int planIndex,
    required int customHours,
    required int circadianMinutes,
  }) {
    if (planIndex == FastingState.customPlanIndex) {
      return Duration(hours: (24 - customHours).clamp(1, 23));
    }

    if (planIndex == FastingState.circadianPlanIndex) {
      return Duration(
        minutes: ((24 * 60) - circadianMinutes).clamp(60, 23 * 60),
      );
    }

    final resolvedIndex = planIndex.clamp(
      0,
      FastingPlan.defaultPlans.length - 1,
    );
    return FastingPlan.defaultPlans[resolvedIndex].eatingDuration;
  }
}
