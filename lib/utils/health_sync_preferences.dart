import 'package:shared_preferences/shared_preferences.dart';

const String kHealthSyncKey = 'health_sync';
const String kLegacyHealthConnectedKey = 'health_connected';

class HealthSyncPreferences {
  const HealthSyncPreferences._();

  static Future<bool> isEnabled([SharedPreferences? prefs]) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    return resolvedPrefs.getBool(kHealthSyncKey) ??
        resolvedPrefs.getBool(kLegacyHealthConnectedKey) ??
        false;
  }

  static Future<void> migrateLegacy([SharedPreferences? prefs]) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    if (!resolvedPrefs.containsKey(kHealthSyncKey) &&
        resolvedPrefs.containsKey(kLegacyHealthConnectedKey)) {
      await resolvedPrefs.setBool(
        kHealthSyncKey,
        resolvedPrefs.getBool(kLegacyHealthConnectedKey) ?? false,
      );
    }
  }

  static Future<void> setEnabled(
    bool isEnabled, [
    SharedPreferences? prefs,
  ]) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    await resolvedPrefs.setBool(kHealthSyncKey, isEnabled);
    await resolvedPrefs.setBool(kLegacyHealthConnectedKey, isEnabled);
  }
}
