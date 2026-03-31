import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class StorageService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- FASTING PLAN ---
  Future<int> getFastPlanIndex() async => (await _prefs).getInt('fast_plan_index') ?? 0;
  Future<void> setFastPlanIndex(int index) async => (await _prefs).setInt('fast_plan_index', index);

  Future<int> getCustomTargetHours() async => (await _prefs).getInt('custom_target_hours') ?? 14;
  Future<void> setCustomTargetHours(int hours) async => (await _prefs).setInt('custom_target_hours', hours);

  Future<int?> getCircadianTargetMinutes() async => (await _prefs).getInt('circadian_target_minutes');
  Future<void> setCircadianTargetMinutes(int minutes) async => (await _prefs).setInt('circadian_target_minutes', minutes);

  // --- FASTING STATE ---
  Future<String> getAppState() async => (await _prefs).getString('app_state') ?? 'stopped';
  Future<void> setAppState(String stateStr) async => (await _prefs).setString('app_state', stateStr);
  Future<void> removeAppState() async => (await _prefs).remove('app_state');

  Future<String?> getCycleStartTime() async => (await _prefs).getString('cycle_start_time');
  Future<void> setCycleStartTime(String timeIso) async => (await _prefs).setString('cycle_start_time', timeIso);
  Future<void> removeCycleStartTime() async => (await _prefs).remove('cycle_start_time');

  // --- MOOD & SYMPTOMS ---
  Future<String?> getCurrentFastMood() async => (await _prefs).getString('current_fast_mood');
  Future<void> removeCurrentFastMood() async => (await _prefs).remove('current_fast_mood');

  Future<List<String>> getCurrentFastSymptoms() async => (await _prefs).getStringList('current_fast_symptoms') ?? const <String>[];
  Future<void> removeCurrentFastSymptoms() async => (await _prefs).remove('current_fast_symptoms');

  // --- SETTINGS & PREFERENCES ---
  Future<String> getThemeMode() async => (await _prefs).getString('theme_mode') ?? 'system';
  Future<void> setThemeMode(String mode) async => (await _prefs).setString('theme_mode', mode);

  Future<String?> getLocaleCode() async => (await _prefs).getString('locale_code') ?? (await _prefs).getString('app_locale');
  Future<void> setLocaleCode(String code) async => (await _prefs).setString('locale_code', code);

  Future<bool> getNotificationsEnabled() async => (await _prefs).getBool('notifications_enabled') ?? true;
  Future<void> setNotificationsEnabled(bool enabled) async => (await _prefs).setBool('notifications_enabled', enabled);

  Future<bool> getNotifyWater() async => (await _prefs).getBool('notify_water') ?? false;
  Future<void> setNotifyWater(bool enabled) async => (await _prefs).setBool('notify_water', enabled);

  Future<bool> getNotifyWeight() async => (await _prefs).getBool('notify_weight') ?? false;
  Future<void> setNotifyWeight(bool enabled) async => (await _prefs).setBool('notify_weight', enabled);

  Future<bool> getNotifyFastingStart() async => (await _prefs).getBool('notify_fasting_start') ?? false;
  Future<void> setNotifyFastingStart(bool enabled) async => (await _prefs).setBool('notify_fasting_start', enabled);

  // --- UI PERFORMANCE ---
  Future<bool> getReducedAnimations() async => (await _prefs).getBool('reduced_animations') ?? false;
  Future<void> setReducedAnimations(bool enabled) async => (await _prefs).setBool('reduced_animations', enabled);
  
  // --- HEALTH SYNC ---
  Future<bool> getHealthSyncEnabled() async => (await _prefs).getBool('health_sync_enabled') ?? false;
  Future<void> setHealthSyncEnabled(bool enabled) async => (await _prefs).setBool('health_sync_enabled', enabled);

  // --- GENERAL PREFS ACCESS ---
  Future<SharedPreferences> getPrefsInstance() => _prefs;
}
