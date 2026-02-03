import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart'; // DI
import 'package:fastable/l10n/app_localizations.dart';

// Если файла notification_data.dart нет, закомментируй импорт ниже и логику bioMilestones
import 'package:fastable/data/notification_data.dart';

const String kNotifyWaterKey = 'notify_water';
const String kNotifyWeightKey = 'notify_weight';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int _idRangeBio = 100;
  static const int _idRangeProgress = 200;
  static const int _idRangeWater = 300;
  static const int _idWeight = 400;
  static const int _idFastComplete = 500;
  static const int _idEatingEnd = 501;
  static const int _idFastingStart = 502;

  bool _isInitialized = false;

  // ИНИЦИАЛИЗАЦИЯ
  // Мы убрали @PostConstruct, так как вызываем этот метод вручную в main.dart
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

  // --- МЕТОДЫ ДЛЯ HOMEPAGE ---

  Future<void> scheduleFastCompletion(DateTime scheduledTime, String title) async {
    await _scheduleOneShot(
      id: _idFastComplete,
      title: title,
      body: "You've successfully completed your fasting goal. Great job!",
      scheduledTime: scheduledTime,
    );
  }

  Future<void> scheduleEatingCompletion(DateTime scheduledTime) async {
    await _scheduleOneShot(
      id: _idEatingEnd,
      title: "Eating Window Ending Soon ⏳",
      body: "Your eating window is closing. Prepare for your fast.",
      scheduledTime: scheduledTime,
    );
  }

  Future<void> scheduleFastingStartReminder(DateTime scheduledTime) async {
    await _scheduleOneShot(
      id: _idFastingStart,
      title: "Fasting Started 🌱",
      body: "Your body is now entering the resting phase.",
      scheduledTime: scheduledTime,
    );
  }

  Future<void> scheduleWaterReminder() async {
    final nextReminder = DateTime.now().add(const Duration(hours: 2));
    await _scheduleOneShot(
      id: _idRangeWater + 999,
      title: "Time for Water! 💧",
      body: "Stay hydrated. Drink a glass of water.",
      scheduledTime: nextReminder,
    );
  }

  // --- ПРОДВИНУТАЯ ЛОГИКА ---

  Future<void> scheduleFastingSession({
    required DateTime startTime,
    required Duration goalDuration,
    required AppLocalizations l10n,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await cancelFastingNotifications();

    // БИО-ЭТАПЫ (Обернуто в try-catch на случай отсутствия bioMilestones)
    try {
      // ignore: undefined_identifier
      if (bioMilestones != null) {
        for (var milestone in bioMilestones) {
          final scheduledTime = startTime.add(milestone.triggerDuration);
          if (scheduledTime.isAfter(DateTime.now())) {
            await _scheduleOneShot(
              id: milestone.id,
              title: milestone.getTitle(l10n),
              body: milestone.getBody(l10n),
              scheduledTime: scheduledTime,
            );
          }
        }
      }
    } catch (e) {
      // Игнорируем, если переменная не найдена
    }

    // ПРОГРЕСС 50%
    final halfTime = startTime.add(Duration(minutes: goalDuration.inMinutes ~/ 2));
    if (halfTime.isAfter(DateTime.now())) {
      await _scheduleOneShot(
        id: _idRangeProgress + 1,
        title: l10n.notifProg50Title,
        body: l10n.notifProg50Body,
        scheduledTime: halfTime,
      );
    }

    // 1 час до конца
    if (goalDuration.inHours > 2) {
      final oneHourLeft = startTime.add(goalDuration - const Duration(hours: 1));
      if (oneHourLeft.isAfter(DateTime.now())) {
        await _scheduleOneShot(
          id: _idRangeProgress + 2,
          title: l10n.notifProg1hTitle,
          body: l10n.notifProg1hBody,
          scheduledTime: oneHourLeft,
        );
      }
    }

    // ФИНИШ
    final finishTime = startTime.add(goalDuration);
    if (finishTime.isAfter(DateTime.now())) {
      await _scheduleOneShot(
        id: _idRangeProgress + 3,
        title: l10n.notifProgFinishTitle,
        body: l10n.notifProgFinishBody,
        scheduledTime: finishTime,
      );
    }

    // ВОДА
    bool isWaterEnabled = prefs.getBool(kNotifyWaterKey) ?? false;
    if (isWaterEnabled) {
      for (int i = 1; i <= 12; i++) {
        final waterTime = startTime.add(Duration(hours: i * 2));
        if (waterTime.isAfter(finishTime)) break;
        if (waterTime.isBefore(DateTime.now())) continue;
        if (waterTime.hour >= 23 || waterTime.hour < 7) continue;

        await _scheduleOneShot(
          id: _idRangeWater + i,
          title: l10n.notifWaterTitle,
          body: l10n.notifWaterBody,
          scheduledTime: waterTime,
        );
      }
    }
  }

  Future<void> scheduleDailyWeightReminder(AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    bool isWeightEnabled = prefs.getBool(kNotifyWeightKey) ?? false;

    if (!isWeightEnabled) {
      await cancelWeightReminder();
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      _idWeight,
      l10n.notifWeightTitle,
      l10n.notifWeightBody,
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

  // --- ОТМЕНА ---

  Future<void> cancelFastingNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelWeightReminder() async {
    await _notificationsPlugin.cancel(_idWeight);
  }

  Future<void> cancelWaterReminder() async {}

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ ---

  Future<void> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fasting_channel',
          'Fasting Alerts',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOf8AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}