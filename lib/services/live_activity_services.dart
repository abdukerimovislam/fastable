import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:live_activities/live_activities.dart';

@lazySingleton
class LiveActivityService {
  final _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;

  // Инициализация
  Future<void> init() async {
    if (!Platform.isIOS) return;
    try {
      await _liveActivitiesPlugin.init(
        appGroupId: 'group.your.app.fastable', // ЗАМЕНИ НА СВОЙ APP GROUP ID
      );
    } catch (e) {
      debugPrint("LiveActivityService init error: $e");
    }
  }

  // Запуск таймера на Локскрине и Dynamic Island
  Future<void> startFastingActivity({
    required DateTime startTime,
    required Duration goalDuration,
    required String phaseName, // "Fasting" или "Eating"
  }) async {
    if (!Platform.isIOS) return;

    try {
      final endTime = startTime.add(goalDuration);

      // Собираем данные в один словарь (плагин сам передаст их в нативный код)
      final Map<String, dynamic> activityData = {
        'phaseName': phaseName,
        'startTime': startTime.millisecondsSinceEpoch ~/ 1000, // Unix timestamp (sec)
        'endTime': endTime.millisecondsSinceEpoch ~/ 1000,
        'progress': 0.0,
        'isFasting': phaseName.toLowerCase().contains("fast"),
      };

      // 🔥 ВОТ ОНО ИСПРАВЛЕНИЕ:
      // В новых версиях 2.4+ первым аргументом нужно передавать кастомный ID (String).
      final String customId = 'fasting_timer_${DateTime.now().millisecondsSinceEpoch}';

      _currentActivityId = await _liveActivitiesPlugin.createActivity(
        customId,       // Аргумент 1: Уникальный String ID
        activityData,   // Аргумент 2: Map с данными
      );

      debugPrint("✅ Live Activity Started: $_currentActivityId (Custom ID: $customId)");
    } catch (e) {
      debugPrint("LiveActivityService start error: $e");
    }
  }

  // Обновление прогресса
  Future<void> updateProgress(double progress) async {
    if (!Platform.isIOS || _currentActivityId == null) return;
    try {
      // Здесь передаем системный ID, который вернул createActivity, и словарь
      await _liveActivitiesPlugin.updateActivity(_currentActivityId!, {
        'progress': progress,
      });
    } catch (e) {
      debugPrint("LiveActivityService update error: $e");
    }
  }

  // Остановка
  Future<void> stopActivity() async {
    if (!Platform.isIOS || _currentActivityId == null) return;
    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      _currentActivityId = null;
      debugPrint("⏹ Live Activity Stopped");
    } catch (e) {
      debugPrint("LiveActivityService stop error: $e");
    }
  }
}