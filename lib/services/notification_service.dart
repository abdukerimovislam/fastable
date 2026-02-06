import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/l10n/app_localizations.dart'; // Must import for ARB

const String kNotifyWaterKey = 'notify_water';
const String kNotifyWeightKey = 'notify_weight';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int _idWeight = 400;
  static const int _idDailyInsight = 888;

  bool _isInitialized = false;

  // --- INITIALIZATION ---
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // --- 🥑 NEW: DAILY AI INSIGHT NOTIFICATIONS ---

  // Теперь принимаем локализацию
  Future<void> scheduleDailyInsight(AppLocalizations l10n) async {
    // 1. Отменяем старое
    await cancelDailyInsight();

    // 2. Планируем на 9:00 утра с локализованным текстом
    await _notificationsPlugin.zonedSchedule(
      _idDailyInsight,
      l10n.notifyAiInsightTitle, // Текст из ARB
      l10n.notifyAiInsightBody,  // Текст из ARB
      _nextInstanceOf9AM(),
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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyInsight() async {
    await _notificationsPlugin.cancel(_idDailyInsight);
  }

  // --- SMART & CARING NOTIFICATIONS (FASTING) ---

  Future<void> scheduleFastingNotifications({
    required DateTime startTime,
    required Duration duration,
    required AppLocalizations l10n,
  }) async {
    final endTime = startTime.add(duration);
    final now = DateTime.now();

    await cancelFastingNotifications();

    final stages = _getLocalizedStages(l10n);

    stages.forEach((hour, content) {
      final stageTime = startTime.add(Duration(hours: hour));
      if (stageTime.isAfter(now) && stageTime.isBefore(endTime.add(const Duration(minutes: 15)))) {
        _scheduleOneShot(
          id: 1000 + hour,
          title: content.title,
          body: content.body,
          scheduledTime: stageTime,
        );
      }
    });

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
    final endTime = startTime.add(duration);
    final now = DateTime.now();

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
    final prefs = await SharedPreferences.getInstance();
    bool isWeightEnabled = prefs.getBool(kNotifyWeightKey) ?? false;

    if (!isWeightEnabled) {
      await cancelWeightReminder();
      return;
    }

    // Теперь используем l10n
    await _notificationsPlugin.zonedSchedule(
      _idWeight,
      l10n.notifyWeightTitle, // Текст из ARB
      l10n.notifyWeightBody,  // Текст из ARB
      _nextInstanceOf8AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          importance: Importance.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // --- CANCELLATION ---

  Future<void> cancelFastingNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelWeightReminder() async {
    await _notificationsPlugin.cancel(_idWeight);
  }

  Future<void> cancelAllFastingNotifications() async {
    await _notificationsPlugin.cancelAll();
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
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // print("Error scheduling notification $id: $e");
    }
  }

  tz.TZDateTime _nextInstanceOf8AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOf9AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9); // 9:00
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // --- DATA MAPPING (LOCALIZED) ---

  Map<int, ({String title, String body})> _getLocalizedStages(AppLocalizations l10n) {
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