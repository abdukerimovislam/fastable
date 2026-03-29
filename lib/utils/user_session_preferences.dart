import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/services/notification_service.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

class UserSessionPreferences {
  const UserSessionPreferences._();

  static const String _snapshotPrefix = 'user_session_snapshot_';

  static const List<String> _stringKeys = <String>[
    'onboarding_primary_goal',
    'onboarding_fasting_experience',
    'onboarding_sleep_pattern',
    'app_state',
    'cycle_start_time',
    'current_fast_mood',
    'today_drinks_json',
    'water_last_date',
    'weight_history',
    'fasting_history_v2',
    'water_history_log',
  ];

  static const List<String> _intKeys = <String>[
    'user_age',
    'user_gender',
    'user_activity',
    'fast_plan_index',
    'custom_target_hours',
    'circadian_target_minutes',
    'water_goal',
    'water_goal_ml',
    'water_recommended',
    'water_recommended_ml',
  ];

  static const List<String> _doubleKeys = <String>[
    'user_weight',
    'user_current_weight',
    'user_height',
    'user_chest',
    'user_waist',
    'user_hips',
    'health_water_last_liters',
  ];

  static const List<String> _boolKeys = <String>[
    'onboarding_complete',
    'water_is_auto',
    kHealthSyncKey,
    kLegacyHealthConnectedKey,
    kNotifyWaterKey,
    kNotifyWeightKey,
    kNotifyFastingStartKey,
    kNotificationsEnabledKey,
    kDailyInsightEnabledKey,
  ];

  static const List<String> _stringListKeys = <String>['current_fast_symptoms'];

  static const List<String> _allKeys = <String>[
    ..._stringKeys,
    ..._intKeys,
    ..._doubleKeys,
    ..._boolKeys,
    ..._stringListKeys,
  ];

  static Future<void> mergeCurrentIntoUser(
    String uid, {
    SharedPreferences? prefs,
  }) async {
    if (uid.isEmpty) return;

    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    final existing =
        await _readSnapshot(uid, prefs: resolvedPrefs) ?? <String, dynamic>{};
    existing.addAll(_captureCurrent(resolvedPrefs));
    await _writeSnapshot(uid, existing, prefs: resolvedPrefs);
  }

  static Future<void> restoreForUser(
    String uid, {
    SharedPreferences? prefs,
  }) async {
    if (uid.isEmpty) return;

    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    await clearCurrentSessionData(prefs: resolvedPrefs);

    final snapshot = await _readSnapshot(uid, prefs: resolvedPrefs);
    if (snapshot == null || snapshot.isEmpty) {
      return;
    }

    for (final key in _allKeys) {
      if (!snapshot.containsKey(key)) continue;
      await _writeValue(resolvedPrefs, key, snapshot[key]);
    }
  }

  static Future<void> clearCurrentSessionData({
    SharedPreferences? prefs,
  }) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    for (final key in _allKeys) {
      await resolvedPrefs.remove(key);
    }
  }

  static Future<void> deleteSnapshotFor(
    String uid, {
    SharedPreferences? prefs,
  }) async {
    if (uid.isEmpty) return;

    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    await resolvedPrefs.remove(_snapshotKey(uid));
  }

  static Map<String, dynamic> _captureCurrent(SharedPreferences prefs) {
    final snapshot = <String, dynamic>{};
    for (final key in _allKeys) {
      final value = prefs.get(key);
      if (value != null) {
        snapshot[key] = value;
      }
    }
    return snapshot;
  }

  static Future<Map<String, dynamic>?> _readSnapshot(
    String uid, {
    SharedPreferences? prefs,
  }) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    final jsonString = resolvedPrefs.getString(_snapshotKey(uid));
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return null;
      }

      return decoded.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeSnapshot(
    String uid,
    Map<String, dynamic> snapshot, {
    SharedPreferences? prefs,
  }) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    if (snapshot.isEmpty) {
      await resolvedPrefs.remove(_snapshotKey(uid));
      return;
    }

    await resolvedPrefs.setString(_snapshotKey(uid), jsonEncode(snapshot));
  }

  static Future<void> _writeValue(
    SharedPreferences prefs,
    String key,
    Object? value,
  ) async {
    if (_stringKeys.contains(key) && value is String) {
      await prefs.setString(key, value);
      return;
    }

    if (_intKeys.contains(key) && value is num) {
      await prefs.setInt(key, value.toInt());
      return;
    }

    if (_doubleKeys.contains(key) && value is num) {
      await prefs.setDouble(key, value.toDouble());
      return;
    }

    if (_boolKeys.contains(key) && value is bool) {
      await prefs.setBool(key, value);
      return;
    }

    if (_stringListKeys.contains(key) && value is List) {
      await prefs.setStringList(
        key,
        value.map((item) => item.toString()).toList(),
      );
    }
  }

  static String _snapshotKey(String uid) => '$_snapshotPrefix$uid';
}
