import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // --- Базовые уведомления (уже были) ---

  Future<void> scheduleFastCompletion(
      DateTime scheduledTime, String fastType) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _scheduleNotification(
      id: 0,
      title: 'Fast Complete!',
      body: "Congratulations! You've completed your $fastType.",
      scheduledTime: scheduledTime,
    );
  }

  Future<void> scheduleEatingCompletion(DateTime scheduledTime) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _scheduleNotification(
      id: 1,
      title: 'Eating Window Over',
      body: 'Your eating window is complete. Time to start your next fast!',
      scheduledTime: scheduledTime,
    );
  }

  // --- НОВЫЕ УМНЫЕ УВЕДОМЛЕНИЯ ---

  // 1. Напоминание о воде (каждые 2 часа)
  Future<void> scheduleWaterReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_channel_id',
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails details = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      10, // ID
      'Time to Hydrate! 💧',
      'Drink a glass of water to stay energized.',
      RepeatInterval.everyMinute, // Для ТЕСТА используем минуту. В релизе: RepeatInterval.hourly (библиотека ограничена) или кастомная логика
      // Примечание: библиотека не поддерживает "каждые 2 часа" из коробки просто так.
      // Для простоты пока поставим 'hourly' (каждый час) или оставим минуту для теста.
      // Давайте поставим 'hourly' для реального использования.
      // RepeatInterval.hourly,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelWaterReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(10);
  }

  // 2. Напоминание о взвешивании (каждый день в 9:00)
  Future<void> scheduleDailyWeightReminder() async {
    await _scheduleDaily(
      id: 20,
      title: 'Morning Weigh-in ⚖️',
      body: 'Track your weight to see your progress!',
      hour: 9,
      minute: 0,
    );
  }

  Future<void> cancelWeightReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(20);
  }

  // 3. "Скоро голодание" (за 30 мин до конца еды)
  Future<void> scheduleFastingStartReminder(DateTime eatingEndTime) async {
    final reminderTime = eatingEndTime.subtract(const Duration(minutes: 30));

    if (reminderTime.isBefore(DateTime.now())) return;

    await _scheduleNotification(
      id: 30,
      title: 'Fasting Starts Soon ⏳',
      body: '30 minutes left in your eating window. Last chance for a snack!',
      scheduledTime: reminderTime,
    );
  }

  Future<void> cancelFastingStartReminder() async {
    await _flutterLocalNotificationsPlugin.cancel(30);
  }

  // --- Вспомогательные методы ---

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'fasting_channel_id',
      'Fasting Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails details = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Повторять каждый день в это время
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}