import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:live_activities/live_activities.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@lazySingleton
class LiveActivityService {
  static const String _iosAppGroupId = String.fromEnvironment(
    'FASTABLE_IOS_APP_GROUP',
    defaultValue: '',
  );
  final _liveActivitiesPlugin = LiveActivities();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _currentIosActivityId;
  static const int _androidNotificationId = 888;
  bool _isIosReady = false;
  bool _hasLoggedIosUnavailable = false;

  Future<void> init() async {
    if (Platform.isIOS) {
      await _initIos();
    } else if (Platform.isAndroid) {
      try {
        const androidInit = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const initSettings = InitializationSettings(android: androidInit);

        await _localNotifications.initialize(
          initSettings,
          // Обработчик нажатий на шторку и кнопки внутри неё
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            if (response.actionId == 'end_fast_action') {
              debugPrint("User tapped END FAST from Android notification!");
              // Приложение выйдет на передний план, где пользователь
              // сможет нажать кнопку завершения и выбрать настроение (Mood)
            }
          },
        );
      } catch (e) {
        debugPrint("LiveActivityService init Android error: $e");
      }
    }
  }

  Future<void> _initIos() async {
    if (_iosAppGroupId.isEmpty) {
      _disableIosLiveActivities(
        'LiveActivityService iOS disabled: FASTABLE_IOS_APP_GROUP is not configured.',
      );
      return;
    }

    try {
      await _liveActivitiesPlugin.init(appGroupId: _iosAppGroupId);
      final supported = await _liveActivitiesPlugin.areActivitiesSupported();
      final enabled = supported
          ? await _liveActivitiesPlugin.areActivitiesEnabled()
          : false;

      if (!supported || !enabled) {
        _disableIosLiveActivities(
          'LiveActivityService iOS unavailable: supported=$supported enabled=$enabled',
        );
        return;
      }

      _isIosReady = true;
      await _liveActivitiesPlugin.endAllActivities();
    } catch (e) {
      _disableIosLiveActivities("LiveActivityService init iOS error: $e");
    }
  }

  void _disableIosLiveActivities(String message) {
    _isIosReady = false;
    _currentIosActivityId = null;
    if (_hasLoggedIosUnavailable) return;
    _hasLoggedIosUnavailable = true;
    debugPrint(message);
  }

  Future<void> startFastingActivity({
    required DateTime startTime,
    required Duration goalDuration,
    required String phaseName,
  }) async {
    final endTime = startTime.add(goalDuration);

    if (Platform.isIOS) {
      if (!_isIosReady) return;

      // --- 🍏 ЛОГИКА ДЛЯ IOS (Dynamic Island) ---
      try {
        if (_currentIosActivityId != null) await stopActivity();

        final Map<String, dynamic> activityData = {
          'phaseName': phaseName,
          'startTime': startTime.millisecondsSinceEpoch ~/ 1000,
          'endTime': endTime.millisecondsSinceEpoch ~/ 1000,
          'progress': 0.0,
          'isFasting': phaseName.toLowerCase().contains("fast"),
        };
        final String customId =
            'fasting_timer_${DateTime.now().millisecondsSinceEpoch}';
        _currentIosActivityId = await _liveActivitiesPlugin.createActivity(
          customId,
          activityData,
          iOSEnableRemoteUpdates: false,
        );
      } catch (e) {
        _disableIosLiveActivities("LiveActivityService iOS start error: $e");
      }
    } else if (Platform.isAndroid) {
      // --- 🤖 ЛОГИКА ДЛЯ ANDROID (Закрепленное уведомление) ---
      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final request = await Permission.notification.request();
          if (!request.isGranted) return;
        }

        // --- ПРОКАЧАННЫЙ ДИЗАЙН УВЕДОМЛЕНИЯ ---
        final androidDetails = AndroidNotificationDetails(
          'fasting_timer_channel',
          'Fasting Timer',
          channelDescription: 'Ongoing fasting timer',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true, // Делаем несмахиваемым
          autoCancel: false,
          usesChronometer: true, // Включаем нативный таймер
          when: startTime.millisecondsSinceEpoch,
          showWhen: true,
          color: const Color(0xFF00FA9A),
          icon: '@mipmap/ic_launcher',

          // 🔥 НОВЫЕ ФИЧИ СТИЛИЗАЦИИ:
          largeIcon: const DrawableResourceAndroidBitmap(
            '@mipmap/ic_launcher',
          ), // Логотип справа
          subText: '🔥 Fastable', // Премиальный подзаголовок
          category: AndroidNotificationCategory.stopwatch, // Хинт для системы
          onlyAlertOnce: true,

          // 🔥 ИНТЕРАКТИВНАЯ КНОПКА
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'end_fast_action',
              '🏁 END FAST',
              cancelNotification: false,
              showsUserInterface:
                  true, // Мгновенно открывает приложение при нажатии
            ),
          ],
        );

        final details = NotificationDetails(android: androidDetails);

        final timeStr =
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

        await _localNotifications.show(
          _androidNotificationId,
          '$phaseName Phase', // Заголовок
          'Goal ends at $timeStr', // Описание
          details,
        );
        debugPrint("✅ Android Ongoing Notification Started!");
      } catch (e) {
        debugPrint("LiveActivityService Android start error: $e");
      }
    }
  }

  Future<void> updateProgress(double progress) async {
    if (Platform.isIOS && _isIosReady && _currentIosActivityId != null) {
      try {
        await _liveActivitiesPlugin.updateActivity(_currentIosActivityId!, {
          'progress': progress,
        });
      } catch (e) {
        _disableIosLiveActivities("LiveActivityService iOS update error: $e");
      }
    }
  }

  Future<void> stopActivity() async {
    if (Platform.isIOS && _currentIosActivityId != null) {
      try {
        await _liveActivitiesPlugin.endActivity(_currentIosActivityId!);
        _currentIosActivityId = null;
        debugPrint("⏹ iOS Live Activity Stopped");
      } catch (e) {
        _disableIosLiveActivities("LiveActivityService iOS stop error: $e");
      }
    } else if (Platform.isAndroid) {
      try {
        await _localNotifications.cancel(
          _androidNotificationId,
        ); // Убираем шторку
        debugPrint("⏹ Android Notification Stopped");
      } catch (e) {
        debugPrint("LiveActivityService Android stop error: $e");
      }
    }
  }
}
