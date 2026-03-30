import 'package:fastable/utils/logger.dart';
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
import 'package:fastable/services/storage_service.dart';

const String _legacyLocaleKey = 'app_locale';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HealthService _healthService;
  final NotificationService _notificationService;
  final StorageService _storageService;

  SettingsBloc(this._healthService, this._notificationService, this._storageService)
    : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleHealthSync>(_onToggleHealthSync);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleWaterReminder>(_onToggleWaterReminder);
    on<ToggleWeightReminder>(_onToggleWeightReminder);
    on<ToggleFastingStartReminder>(_onToggleFastingStartReminder);
    on<ToggleReducedAnimations>(_onToggleReducedAnimations);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await _storageService.getPrefsInstance();
    await HealthSyncPreferences.migrateLegacy(prefs);

    String themeStr = await _storageService.getThemeMode();
    ThemeMode themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    String? savedLang = await _storageService.getLocaleCode() ?? prefs.getString(_legacyLocaleKey);
    String langCode;

    if (savedLang != null) {
      langCode = savedLang;
      if (!prefs.containsKey('locale_code')) {
        await _storageService.setLocaleCode(savedLang);
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
      await _storageService.setLocaleCode(langCode);
    }

    Locale locale = Locale(langCode);

    bool health = await HealthSyncPreferences.isEnabled(prefs);
    bool notif = await _storageService.getNotificationsEnabled();
    final notifyWater = await _storageService.getNotifyWater();
    final notifyWeight = await _storageService.getNotifyWeight();
    final notifyFastingStart = await _storageService.getNotifyFastingStart();
    final reducedAnimations = await _storageService.getReducedAnimations();

    emit(
      state.copyWith(
        themeMode: themeMode,
        locale: locale,
        isHealthSyncEnabled: health,
        areNotificationsEnabled: notif,
        notifyWater: notifyWater,
        notifyWeight: notifyWeight,
        notifyFastingStart: notifyFastingStart,
        reducedAnimations: reducedAnimations,
      ),
    );
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await _storageService.setThemeMode(event.themeMode.name);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    await _storageService.setLocaleCode(event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));

    // 🔥 ПЕРЕВОДИМ УВЕДОМЛЕНИЯ ТОЛЬКО ЕСЛИ ОНИ ВКЛЮЧЕНЫ
    if (state.areNotificationsEnabled) {
      try {
        final l10n = lookupAppLocalizations(event.locale);
        await _notificationService.rescheduleAll(l10n);
        appLog(
          "✅ Notifications rescheduled to language: ${event.locale.languageCode}",
        );
      } catch (e) {
        appLog("⚠️ Failed to reschedule notifications: $e");
      }
    }
  }

  Future<void> _onToggleHealthSync(
    ToggleHealthSync event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await _storageService.getPrefsInstance();
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
    await _storageService.setNotificationsEnabled(event.isEnabled);
    emit(state.copyWith(areNotificationsEnabled: event.isEnabled));

    // 🔥 ФИКС: РЕАЛЬНОЕ ВКЛЮЧЕНИЕ / ВЫКЛЮЧЕНИЕ ПУШЕЙ В СИСТЕМЕ
    if (event.isEnabled) {
      try {
        final l10n = lookupAppLocalizations(state.locale);
        await _notificationService.rescheduleAll(l10n);
        appLog("✅ Notifications turned ON and rescheduled.");
      } catch (e) {
        appLog("⚠️ Failed to reschedule notifications: $e");
      }
    } else {
      await _notificationService.cancelAllNotifications();
      appLog("⏹ Notifications turned OFF. All scheduled pushes cancelled.");
    }
  }

  Future<void> _onToggleWaterReminder(
    ToggleWaterReminder event,
    Emitter<SettingsState> emit,
  ) async {
    await _storageService.setNotifyWater(event.isEnabled);
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
    await _storageService.setNotifyWeight(event.isEnabled);
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
    await _storageService.setNotifyFastingStart(event.isEnabled);
    emit(state.copyWith(notifyFastingStart: event.isEnabled));

    if (!event.isEnabled) {
      await _notificationService.cancelEatingNotifications();
      return;
    }

    if (!state.areNotificationsEnabled) return;

    final appState = await _storageService.getAppState();
    final cycleStart = await _storageService.getCycleStartTime();
    if (appState != FastingPhase.eating.name || cycleStart == null) {
      return;
    }

    final startTime = DateTime.tryParse(cycleStart);
    if (startTime == null) return;

    final planIndex = await _storageService.getFastPlanIndex();
    final customHours = await _storageService.getCustomTargetHours();
    final circadianMinutes = (await _storageService.getCircadianTargetMinutes()) ?? const Duration(hours: 14).inMinutes;

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

  Future<void> _onToggleReducedAnimations(
    ToggleReducedAnimations event,
    Emitter<SettingsState> emit,
  ) async {
    await _storageService.setReducedAnimations(event.isEnabled);
    emit(state.copyWith(reducedAnimations: event.isEnabled));
  }
}
