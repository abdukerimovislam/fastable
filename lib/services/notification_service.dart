import 'package:fastable/utils/logger.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/core/app_prefs_keys.dart';
import 'dart:io'; // Для проверки платформы

// Backward-compatible aliases — use AppPrefsKeys.* directly in new code
const String kNotifyWaterKey = AppPrefsKeys.notifyWater;
const String kNotifyWeightKey = AppPrefsKeys.notifyWeight;
const String kNotifyFastingStartKey = AppPrefsKeys.notifyFastingStart;
const String kNotificationsEnabledKey = AppPrefsKeys.notificationsEnabled;
const String kDailyInsightEnabledKey = AppPrefsKeys.dailyInsightEnabled;

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _idWeight = 400;
  static const int _idDailyInsight = 888;
  static const List<int> _waterReminderIds = [3000, 3001, 3002];
  static const List<int> _waterReminderHours = [10, 14, 18];

  bool _isInitialized = false;

  // --- INITIALIZATION ---
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      // Вытаскиваем IANA идентификатор из объекта TimezoneInfo
      final String timeZoneName = timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      appLog("✅ Timezone set to: $timeZoneName");
    } catch (e) {
      appLog("⚠️ Could not get local timezone: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  // 🔥 ИСПРАВЛЕНИЕ: Правильный запрос прав на Уведомления для ОБЕИХ платформ (iOS и Android)
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        appLog("✅ iOS Notification Permissions Requested");
      }
    } else if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        appLog("✅ Android Notification Permissions Requested");
      }
    }
  }

  // --- 🥑 DAILY AI INSIGHT NOTIFICATIONS ---

  Future<void> scheduleDailyInsight(
    AppLocalizations l10n, {
    bool markEnabled = true,
  }) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    if (markEnabled) {
      await prefs.setBool(kDailyInsightEnabledKey, true);
    }
    await cancelDailyInsight();

    if (!await _areNotificationsEnabled(prefs)) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      _idDailyInsight,
      l10n.notifyAiInsightTitle,
      l10n.notifyAiInsightBody,
      _nextInstanceOfTime(9), // 9:00 AM Локального времени
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_insight_channel',
          'Daily Insights',
          channelDescription: 'Notifications for daily AI coaching',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyInsight({bool clearPreference = false}) async {
    await _notificationsPlugin.cancel(_idDailyInsight);
    if (clearPreference) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDailyInsightEnabledKey, false);
    }
  }

  // --- SMART & CARING NOTIFICATIONS (FASTING) ---

  // --- 🔥 МЕТОД ДЛЯ ПЕРЕВОДА УВЕДОМЛЕНИЙ ПРИ СМЕНЕ ЯЗЫКА ---
  Future<void> rescheduleAll(AppLocalizations l10n) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final shouldRestoreDailyInsight =
        prefs.getBool(kDailyInsightEnabledKey) ?? false;
    final shouldRestoreWeightReminder =
        prefs.getBool(kNotifyWeightKey) ?? false;
    final shouldRestoreWaterReminders = prefs.getBool(kNotifyWaterKey) ?? false;

    // 1. Отменяем всё старое
    await cancelAllFastingNotifications();
    await cancelDailyInsight();
    await cancelWeightReminder();
    await cancelWaterReminders();

    if (!await _areNotificationsEnabled(prefs)) {
      return;
    }

    // 2. Восстанавливаем только реально активные ежедневные уведомления
    if (shouldRestoreDailyInsight) {
      await scheduleDailyInsight(l10n, markEnabled: false);
    }

    if (shouldRestoreWeightReminder) {
      await scheduleDailyWeightReminder(l10n);
    }

    if (shouldRestoreWaterReminders) {
      await scheduleDailyWaterReminders(l10n);
    }

    // 3. Восстанавливаем таймеры голодания/окна еды (если они активны)
    final stateStr = prefs.getString(AppPrefsKeys.appState) ?? 'stopped';
    final startStr = prefs.getString(AppPrefsKeys.cycleStartTime);

    if (stateStr != 'stopped' && startStr != null) {
      final startTime = DateTime.tryParse(startStr) ?? DateTime.now();
      final phase = stateStr == FastingPhase.fasting.name
          ? FastingPhase.fasting
          : FastingPhase.eating;
      final planIdx = prefs.getInt(AppPrefsKeys.fastPlanIndex) ?? 0;
      final customHours = prefs.getInt(AppPrefsKeys.customTargetHours) ?? 14;
      final circadianTargetMinutes =
          prefs.getInt(AppPrefsKeys.circadianTargetMinutes) ??
          const Duration(hours: 14).inMinutes;
      final goal = _resolvePhaseDuration(
        phase: phase,
        planIndex: planIdx,
        customHours: customHours,
        circadianTargetMinutes: circadianTargetMinutes,
      );

      // Планируем заново с новым языком!
      if (phase == FastingPhase.fasting) {
        await scheduleFastingNotifications(
          startTime: startTime,
          duration: goal,
          l10n: l10n,
        );
      } else if (stateStr == 'eating') {
        await scheduleEatingNotifications(
          startTime: startTime,
          duration: goal,
          l10n: l10n,
        );
      }
    }
  }

  Future<void> scheduleFastingNotifications({
    required DateTime startTime,
    required Duration duration,
    required AppLocalizations l10n,
  }) async {
    await init();
    if (!await _areNotificationsEnabled()) {
      await cancelFastingNotifications();
      return;
    }

    final endTime = startTime.add(duration);
    final now = DateTime.now();

    await cancelCycleNotifications();

    final stages = _getLocalizedStages(l10n);

    for (final entry in stages.entries) {
      final hour = entry.key;
      final content = entry.value;
      final stageTime = startTime.add(Duration(hours: hour));
      if (stageTime.isAfter(now) &&
          stageTime.isBefore(endTime.add(const Duration(minutes: 15)))) {
        await _scheduleOneShot(
          id: 1000 + hour, // ID от 1000 до 1024
          title: content.title,
          body: content.body,
          scheduledTime: stageTime,
        );
      }
    }

    final halfTime = startTime.add(duration ~/ 2);
    if (halfTime.isAfter(now) && halfTime.isBefore(endTime)) {
      await _scheduleOneShot(
        id: 500,
        title: l10n.notifyHalfwayTitle,
        body: l10n.notifyHalfwayBody,
        scheduledTime: halfTime,
      );
    }

    if (duration.inHours > 2) {
      final oneHourLeft = endTime.subtract(const Duration(hours: 1));
      if (oneHourLeft.isAfter(now)) {
        await _scheduleOneShot(
          id: 900,
          title: l10n.notify1hTitle,
          body: l10n.notify1hBody,
          scheduledTime: oneHourLeft,
        );
      }
    }

    if (endTime.isAfter(now)) {
      await _scheduleOneShot(
        id: 999,
        title: l10n.notifyGoalTitle,
        body: l10n.notifyGoalBody,
        scheduledTime: endTime,
      );
    }
  }

  // --- SMART NOTIFICATIONS (EATING) ---

  Future<void> scheduleEatingNotifications({
    required DateTime startTime,
    required Duration duration,
    required AppLocalizations l10n,
  }) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = await _areNotificationsEnabled(prefs);
    final notifyFastingStart = prefs.getBool(kNotifyFastingStartKey) ?? false;

    if (!notificationsEnabled || !notifyFastingStart) {
      await cancelEatingNotifications();
      return;
    }

    final endTime = startTime.add(duration);
    final now = DateTime.now();

    await cancelCycleNotifications();

    if (endTime.isAfter(now)) {
      await _scheduleOneShot(
        id: 2000,
        title: l10n.notifyEatCloseTitle,
        body: l10n.notifyEatCloseBody,
        scheduledTime: endTime,
      );
    }

    final warningTime = endTime.subtract(const Duration(minutes: 30));
    if (warningTime.isAfter(now)) {
      await _scheduleOneShot(
        id: 2001,
        title: l10n.notifyEat30mTitle,
        body: l10n.notifyEat30mBody,
        scheduledTime: warningTime,
      );
    }
  }

  // --- OTHER REMINDERS ---

  Future<void> scheduleDailyWeightReminder(AppLocalizations l10n) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final isWeightEnabled = prefs.getBool(kNotifyWeightKey) ?? false;

    if (!isWeightEnabled || !await _areNotificationsEnabled(prefs)) {
      await cancelWeightReminder();
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      _idWeight,
      l10n.notifyWeightTitle,
      l10n.notifyWeightBody,
      _nextInstanceOfTime(8), // 8:00 AM Локального времени
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          importance: Importance.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyWaterReminders(AppLocalizations l10n) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final isWaterEnabled = prefs.getBool(kNotifyWaterKey) ?? false;

    if (!isWaterEnabled || !await _areNotificationsEnabled(prefs)) {
      await cancelWaterReminders();
      return;
    }

    await cancelWaterReminders();

    for (int index = 0; index < _waterReminderIds.length; index++) {
      await _notificationsPlugin.zonedSchedule(
        _waterReminderIds[index],
        l10n.notifWaterTitle,
        l10n.notifWaterBody,
        _nextInstanceOfTime(_waterReminderHours[index]),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder_channel',
            'Water Reminders',
            channelDescription: 'Daily reminders to stay hydrated',
            importance: Importance.low,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // --- CANCELLATION ---

  // 🔥 НОВЫЙ МЕТОД ДЛЯ ПОЛНОЙ ОТМЕНЫ УВЕДОМЛЕНИЙ (Вызывается из SettingsBloc)
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelFastingNotifications() async {
    await _notificationsPlugin.cancel(500);
    await _notificationsPlugin.cancel(900);
    await _notificationsPlugin.cancel(999);
    for (int i = 0; i <= 30; i++) {
      await _notificationsPlugin.cancel(1000 + i);
    }
  }

  Future<void> cancelEatingNotifications() async {
    await _notificationsPlugin.cancel(2000);
    await _notificationsPlugin.cancel(2001);
  }

  Future<void> cancelCycleNotifications() async {
    await cancelFastingNotifications();
    await cancelEatingNotifications();
  }

  Future<void> cancelWeightReminder() async {
    await _notificationsPlugin.cancel(_idWeight);
  }

  Future<void> cancelWaterReminders() async {
    for (final id in _waterReminderIds) {
      await _notificationsPlugin.cancel(id);
    }
  }

  Future<void> cancelAllFastingNotifications() async {
    await cancelCycleNotifications();
  }

  Duration _resolvePhaseDuration({
    required FastingPhase phase,
    required int planIndex,
    required int customHours,
    required int circadianTargetMinutes,
  }) {
    if (planIndex == FastingState.customPlanIndex) {
      final fastingDuration = Duration(hours: customHours.clamp(1, 23));
      final eatingDuration = Duration(hours: (24 - customHours).clamp(1, 23));
      return phase == FastingPhase.fasting ? fastingDuration : eatingDuration;
    }

    if (planIndex == FastingState.circadianPlanIndex) {
      final fastingMinutes = circadianTargetMinutes.clamp(60, 23 * 60);
      final fastingDuration = Duration(minutes: fastingMinutes);
      final eatingDuration = const Duration(hours: 24) - fastingDuration;
      return phase == FastingPhase.fasting ? fastingDuration : eatingDuration;
    }

    final plan = planIndex >= 0 && planIndex < FastingPlan.defaultPlans.length
        ? FastingPlan.defaultPlans[planIndex]
        : FastingPlan.defaultPlans.first;
    return phase == FastingPhase.fasting
        ? plan.fastingDuration
        : plan.eatingDuration;
  }

  Future<bool> _areNotificationsEnabled([SharedPreferences? prefs]) async {
    final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
    return resolvedPrefs.getBool(kNotificationsEnabledKey) ?? true;
  }

  // --- HELPERS ---

  Future<void> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fasting_channel_v2',
            'Fasting Updates',
            channelDescription: 'Notifications regarding fasting stages',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      appLog("Error scheduling notification $id: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // --- DATA MAPPING (LOCALIZED) ---

  Map<int, ({String title, String body})> _getLocalizedStages(
    AppLocalizations l10n,
  ) {
    return {
      2: (title: l10n.stage2Title, body: l10n.stage2Body),
      4: (title: l10n.stage4Title, body: l10n.stage4Body),
      8: (title: l10n.stage8Title, body: l10n.stage8Body),
      11: (title: l10n.stage11Title, body: l10n.stage11Body),
      12: (title: l10n.stage12Title, body: l10n.stage12Body),
      14: (title: l10n.stage14Title, body: l10n.stage14Body),
      16: (title: l10n.stage16Title, body: l10n.stage16Body),
      18: (title: l10n.stage18Title, body: l10n.stage18Body),
      24: (title: l10n.stage24Title, body: l10n.stage24Body),
    };
  }

  Future<void> scheduleFastCompletion(DateTime time, String text) async {}
  Future<void> scheduleEatingCompletion(DateTime time) async {}
}
