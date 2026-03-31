/// Centralized registry of all SharedPreferences keys used in the app.
///
/// Rules:
/// - All keys must be defined here as `static const String`.
/// - Grouped by feature for readability.
/// - Never use raw string literals for prefs keys outside this file.
abstract final class AppPrefsKeys {
  // ─── ONBOARDING ────────────────────────────────────────────────────────────
  static const String onboardingComplete = 'onboarding_complete';
  static const String onboardingPrimaryGoal = 'onboarding_primary_goal';
  static const String onboardingFastingExperience = 'onboarding_fasting_experience';
  static const String onboardingSleepPattern = 'onboarding_sleep_pattern';

  /// User accepted Medical Disclaimer & Privacy Policy during onboarding.
  static const String disclaimerAccepted = 'disclaimer_accepted';

  // ─── USER PROFILE ───────────────────────────────────────────────────────────
  static const String userAge = 'user_age';
  static const String userGender = 'user_gender';
  static const String userActivity = 'user_activity';
  static const String userWeight = 'user_weight';
  static const String userCurrentWeight = 'user_current_weight';
  static const String userHeight = 'user_height';
  static const String userChest = 'user_chest';
  static const String userWaist = 'user_waist';
  static const String userHips = 'user_hips';

  // ─── FASTING ────────────────────────────────────────────────────────────────
  static const String appState = 'app_state';
  static const String cycleStartTime = 'cycle_start_time';
  static const String fastPlanIndex = 'fast_plan_index';
  static const String customTargetHours = 'custom_target_hours';
  static const String circadianTargetMinutes = 'circadian_target_minutes';
  static const String fastingHistoryV2 = 'fasting_history_v2';
  static const String currentFastMood = 'current_fast_mood';
  static const String currentFastSymptoms = 'current_fast_symptoms';

  // ─── WATER ──────────────────────────────────────────────────────────────────
  static const String waterLastDate = 'water_last_date';
  static const String todayDrinksJson = 'today_drinks_json';
  static const String waterGoal = 'water_goal';
  static const String waterGoalMl = 'water_goal_ml';
  static const String waterRecommended = 'water_recommended';
  static const String waterRecommendedMl = 'water_recommended_ml';
  static const String waterIsAuto = 'water_is_auto';
  static const String waterHistory = 'water_history_log';

  // ─── WEIGHT ─────────────────────────────────────────────────────────────────
  static const String weightHistory = 'weight_history';

  // ─── HEALTH ─────────────────────────────────────────────────────────────────
  /// Health Connect / Apple Health sync toggle.
  static const String healthSync = 'health_sync';

  /// Legacy key kept for migration only. Prefer [healthSync].
  static const String legacyHealthConnected = 'health_connected';

  /// Last water import from health (liters).
  static const String healthWaterLastLiters = 'health_water_last_liters';

  // ─── LOCALE ─────────────────────────────────────────────────────────────────
  static const String localeCode = 'locale_code';

  /// Legacy locale key kept for migration only. Prefer [localeCode].
  static const String legacyLocaleCode = 'app_locale';

  // ─── NOTIFICATIONS ──────────────────────────────────────────────────────────
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notifyWater = 'notify_water';
  static const String notifyWeight = 'notify_weight';
  static const String notifyFastingStart = 'notify_fasting_start';
  static const String dailyInsightEnabled = 'daily_insight_enabled';
}
