import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

class MockHealthService extends Mock implements HealthService {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeAppLocalizations extends Fake implements AppLocalizations {}

void main() {
  late MockHealthService mockHealthService;
  late MockNotificationService mockNotificationService;
  late SettingsBloc settingsBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeAppLocalizations());
    registerFallbackValue(DateTime(2025));
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockHealthService = MockHealthService();
    mockNotificationService = MockNotificationService();

    when(
      () => mockNotificationService.rescheduleAll(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.cancelAllNotifications(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.scheduleDailyWaterReminders(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.cancelWaterReminders(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.scheduleDailyWeightReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.cancelWeightReminder(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.scheduleEatingNotifications(
        startTime: any(named: 'startTime'),
        duration: any(named: 'duration'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.cancelEatingNotifications(),
    ).thenAnswer((_) async {});
    when(
      () => mockHealthService.requestPermissions(),
    ).thenAnswer((_) async => true);

    settingsBloc = SettingsBloc(mockHealthService, mockNotificationService);
  });

  tearDown(() async {
    await settingsBloc.close();
  });

  blocTest<SettingsBloc, SettingsState>(
    'LoadSettings restores locale from legacy storage key',
    build: () {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      return SettingsBloc(mockHealthService, mockNotificationService);
    },
    act: (bloc) => bloc.add(LoadSettings()),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.locale.languageCode,
        'locale',
        'es',
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale_code'), 'es');
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'LoadSettings restores health sync from legacy storage key',
    build: () {
      SharedPreferences.setMockInitialValues({kLegacyHealthConnectedKey: true});
      return SettingsBloc(mockHealthService, mockNotificationService);
    },
    act: (bloc) => bloc.add(LoadSettings()),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.isHealthSyncEnabled,
        'isHealthSyncEnabled',
        true,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHealthSyncKey), true);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'LoadSettings restores individual reminder toggles',
    build: () {
      SharedPreferences.setMockInitialValues({
        kNotifyWaterKey: true,
        kNotifyWeightKey: true,
        kNotifyFastingStartKey: true,
      });
      return SettingsBloc(mockHealthService, mockNotificationService);
    },
    act: (bloc) => bloc.add(LoadSettings()),
    expect: () => [
      isA<SettingsState>()
          .having((state) => state.notifyWater, 'notifyWater', true)
          .having((state) => state.notifyWeight, 'notifyWeight', true)
          .having(
            (state) => state.notifyFastingStart,
            'notifyFastingStart',
            true,
          ),
    ],
  );

  blocTest<SettingsBloc, SettingsState>(
    'ChangeLocale stores locale and reschedules notifications in the chosen language',
    build: () => settingsBloc,
    seed: () => const SettingsState(
      locale: Locale('en'),
      areNotificationsEnabled: true,
    ),
    act: (bloc) => bloc.add(const ChangeLocale(Locale('ru'))),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.locale.languageCode,
        'locale',
        'ru',
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale_code'), 'ru');

      final capturedL10n =
          verify(
                () => mockNotificationService.rescheduleAll(captureAny()),
              ).captured.single
              as AppLocalizations;
      expect(capturedL10n.localeName, 'ru');
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleNotifications(false) cancels scheduled notifications',
    build: () => settingsBloc,
    seed: () => const SettingsState(areNotificationsEnabled: true),
    act: (bloc) => bloc.add(const ToggleNotifications(false)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.areNotificationsEnabled,
        'areNotificationsEnabled',
        false,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), false);
      verify(() => mockNotificationService.cancelAllNotifications()).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleNotifications(true) reschedules notifications with current locale',
    build: () => settingsBloc,
    seed: () => const SettingsState(
      locale: Locale('pt'),
      areNotificationsEnabled: false,
    ),
    act: (bloc) => bloc.add(const ToggleNotifications(true)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.areNotificationsEnabled,
        'areNotificationsEnabled',
        true,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), true);

      final capturedL10n =
          verify(
                () => mockNotificationService.rescheduleAll(captureAny()),
              ).captured.single
              as AppLocalizations;
      expect(capturedL10n.localeName, 'pt');
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleHealthSync persists both current and legacy flags',
    build: () => settingsBloc,
    act: (bloc) => bloc.add(const ToggleHealthSync(true)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.isHealthSyncEnabled,
        'isHealthSyncEnabled',
        true,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kHealthSyncKey), true);
      expect(prefs.getBool(kLegacyHealthConnectedKey), true);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleHealthSync skips duplicate permission request when UI already granted access',
    build: () => settingsBloc,
    act: (bloc) =>
        bloc.add(const ToggleHealthSync(true, requestPermissions: false)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.isHealthSyncEnabled,
        'isHealthSyncEnabled',
        true,
      ),
    ],
    verify: (_) {
      verifyNever(() => mockHealthService.requestPermissions());
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleWaterReminder schedules water reminders and persists preference',
    build: () => settingsBloc,
    seed: () => const SettingsState(
      locale: Locale('es'),
      areNotificationsEnabled: true,
    ),
    act: (bloc) => bloc.add(const ToggleWaterReminder(true)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.notifyWater,
        'notifyWater',
        true,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kNotifyWaterKey), true);

      final capturedL10n =
          verify(
                () => mockNotificationService.scheduleDailyWaterReminders(
                  captureAny(),
                ),
              ).captured.single
              as AppLocalizations;
      expect(capturedL10n.localeName, 'es');
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleWeightReminder cancels weight reminder when disabled',
    build: () => settingsBloc,
    seed: () => const SettingsState(notifyWeight: true),
    act: (bloc) => bloc.add(const ToggleWeightReminder(false)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.notifyWeight,
        'notifyWeight',
        false,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kNotifyWeightKey), false);
      verify(() => mockNotificationService.cancelWeightReminder()).called(1);
    },
  );

  blocTest<SettingsBloc, SettingsState>(
    'ToggleFastingStartReminder schedules eating reminder for active eating phase',
    build: () {
      SharedPreferences.setMockInitialValues({
        'app_state': 'eating',
        'cycle_start_time': DateTime(2025, 1, 1, 8).toIso8601String(),
        'fast_plan_index': 0,
      });
      return SettingsBloc(mockHealthService, mockNotificationService);
    },
    seed: () => const SettingsState(
      locale: Locale('pt'),
      areNotificationsEnabled: true,
    ),
    act: (bloc) => bloc.add(const ToggleFastingStartReminder(true)),
    expect: () => [
      isA<SettingsState>().having(
        (state) => state.notifyFastingStart,
        'notifyFastingStart',
        true,
      ),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kNotifyFastingStartKey), true);
      verify(
        () => mockNotificationService.scheduleEatingNotifications(
          startTime: any(named: 'startTime'),
          duration: any(named: 'duration'),
          l10n: any(named: 'l10n'),
        ),
      ).called(1);
    },
  );
}
