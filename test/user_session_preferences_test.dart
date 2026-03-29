import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/services/notification_service.dart';
import 'package:fastable/utils/user_session_preferences.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('restoreForUser isolates user-scoped preferences by uid', () async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('locale_code', 'ru');
    await prefs.setDouble('user_weight', 81.5);
    await prefs.setInt('user_age', 31);
    await prefs.setString('app_state', 'fasting');
    await prefs.setStringList('current_fast_symptoms', ['headache']);
    await prefs.setBool(kNotifyWaterKey, true);
    await prefs.setString('water_history_log', '[{"cupCount":4}]');
    await UserSessionPreferences.mergeCurrentIntoUser('user-a', prefs: prefs);

    await prefs.setDouble('user_weight', 63.0);
    await prefs.setInt('user_age', 26);
    await prefs.setString('app_state', 'stopped');
    await prefs.setStringList('current_fast_symptoms', ['fatigue']);
    await prefs.setBool(kNotifyWaterKey, false);
    await prefs.setString('water_history_log', '[{"cupCount":1}]');
    await UserSessionPreferences.mergeCurrentIntoUser('user-b', prefs: prefs);

    await prefs.setDouble('user_weight', 99.0);
    await prefs.setInt('user_age', 99);
    await prefs.setString('app_state', 'eating');

    await UserSessionPreferences.restoreForUser('user-a', prefs: prefs);

    expect(prefs.getDouble('user_weight'), 81.5);
    expect(prefs.getInt('user_age'), 31);
    expect(prefs.getString('app_state'), 'fasting');
    expect(prefs.getStringList('current_fast_symptoms'), ['headache']);
    expect(prefs.getBool(kNotifyWaterKey), true);
    expect(prefs.getString('water_history_log'), '[{"cupCount":4}]');
    expect(prefs.getString('locale_code'), 'ru');
  });

  test('clearCurrentSessionData preserves global app preferences', () async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('locale_code', 'es');
    await prefs.setString('theme_mode', 'dark');
    await prefs.setDouble('user_height', 182.0);
    await prefs.setString('fasting_history_v2', '[]');

    await UserSessionPreferences.clearCurrentSessionData(prefs: prefs);

    expect(prefs.getString('locale_code'), 'es');
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getDouble('user_height'), isNull);
    expect(prefs.getString('fasting_history_v2'), isNull);
  });

  test('mergeCurrentIntoUser preserves existing snapshot fields', () async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('water_history_log', '[{"cupCount":2}]');
    await UserSessionPreferences.mergeCurrentIntoUser('user-a', prefs: prefs);

    await UserSessionPreferences.clearCurrentSessionData(prefs: prefs);
    await prefs.setInt('user_age', 42);

    await UserSessionPreferences.mergeCurrentIntoUser('user-a', prefs: prefs);
    await UserSessionPreferences.restoreForUser('user-a', prefs: prefs);

    expect(prefs.getBool('onboarding_complete'), true);
    expect(prefs.getInt('user_age'), 42);
    expect(prefs.getString('water_history_log'), '[{"cupCount":2}]');
  });
}
