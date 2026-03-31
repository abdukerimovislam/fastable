import 'package:fastable/utils/logger.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:live_activities/live_activities.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// 🔥 ДОБАВЛЕНЫ ИМПОРТЫ ДЛЯ ЛОКАЛИЗАЦИИ
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/storage_service.dart';
import 'package:fastable/injection.dart';

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
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidInit);

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            if (response.actionId == 'end_fast_action') {
              appLog("User tapped Action Button from Android notification!");
            }
          },
        );
      } catch (e) {
        appLog("LiveActivityService init Android error: $e");
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
    appLog(message);
  }

  Future<void> startFastingActivity({
    required DateTime startTime,
    required Duration goalDuration,
    required String phaseName,
  }) async {
    final endTime = startTime.add(goalDuration);
    final isFasting = phaseName.toLowerCase().contains("fast");

    // 🔥 ПОДГРУЖАЕМ ПРАВИЛЬНЫЙ ЯЗЫК В ФОНЕ
    final storage = getIt<StorageService>();
    final localeCode = await storage.getLocaleCode() ?? 'en';
    final l10n = await AppLocalizations.delegate.load(Locale(localeCode));

    if (Platform.isIOS) {
      if (!_isIosReady) return;

      try {
        if (_currentIosActivityId != null) await stopActivity();

        final Map<String, dynamic> activityData = {
          'phaseName': phaseName,
          'startTime': startTime.millisecondsSinceEpoch ~/ 1000,
          'endTime': endTime.millisecondsSinceEpoch ~/ 1000,
          'progress': 0.0,
          'isFasting': isFasting,
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
      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final request = await Permission.notification.request();
          if (!request.isGranted) return;
        }

        final androidDetails = AndroidNotificationDetails(
          'fasting_timer_channel',
          l10n.liveTrackerChannelName, // 🔥 Локализовано
          channelDescription: l10n.liveTrackerChannelDesc, // 🔥 Локализовано
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          usesChronometer: true,
          chronometerCountDown: true,
          when: endTime.millisecondsSinceEpoch,
          showWhen: true,
          color: isFasting ? const Color(0xFFFFC107) : const Color(0xFF00D289),
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          subText: isFasting ? l10n.liveTrackerSubtextFasting : l10n.liveTrackerSubtextEating, // 🔥 Локализовано
          category: AndroidNotificationCategory.stopwatch,
          onlyAlertOnce: true,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'end_fast_action',
              isFasting ? l10n.liveTrackerActionEndFast : l10n.liveTrackerActionStopWindow, // 🔥 Локализовано
              cancelNotification: false,
              showsUserInterface: true,
            ),
          ],
        );

        final details = NotificationDetails(android: androidDetails);
        final timeStr = DateFormat.jm().format(endTime);

        await _localNotifications.show(
          _androidNotificationId,
          isFasting ? l10n.liveTrackerGoal(timeStr) : l10n.liveTrackerWindowEnds(timeStr), // 🔥 Локализовано
          l10n.liveTrackerTimeRemaining, // 🔥 Локализовано
          details,
        );
        appLog("✅ Android Ongoing Notification Started!");
      } catch (e) {
        appLog("LiveActivityService Android start error: $e");
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
        appLog("⏹ iOS Live Activity Stopped");
      } catch (e) {
        _disableIosLiveActivities("LiveActivityService iOS stop error: $e");
      }
    } else if (Platform.isAndroid) {
      try {
        await _localNotifications.cancel(_androidNotificationId);
        appLog("⏹ Android Notification Stopped");
      } catch (e) {
        appLog("LiveActivityService Android stop error: $e");
      }
    }
  }
}