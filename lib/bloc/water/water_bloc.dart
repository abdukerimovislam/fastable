import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart'; // <--- Импорт сервиса

@injectable
class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _repository;
  final HealthService _healthService; // <--- Добавляем зависимость

  WaterBloc(this._repository, this._healthService) : super(const WaterState()) {
    on<LoadWaterData>(_onLoadData);
    on<AddWaterCup>(_onAddCup);
    on<RemoveWaterCup>(_onRemoveCup);
    on<UpdateWaterGoal>(_onUpdateGoal);
    on<ToggleAutoGoal>(_onToggleAutoGoal);
    on<UpdateRecommendedGoal>(_onUpdateRecommendedGoal);
  }

  Future<void> _onLoadData(
      LoadWaterData event, Emitter<WaterState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Проверяем смену дня
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      int currentCups = prefs.getInt('water_consumed') ?? 0;

      if (lastDate != today) {
        currentCups = 0; // Новый день — сбрасываем счетчик
        await prefs.setString('water_last_date', today);
        await prefs.setInt('water_consumed', 0);
      }

      // 2. Загружаем настройки
      final goal = prefs.getInt('water_goal') ?? 8;
      final recommended = prefs.getInt('water_recommended') ?? 8;
      final isAuto = prefs.getBool('water_is_auto') ?? true;

      // --- ИНТЕГРАЦИЯ HEALTH (ЧТЕНИЕ) ---
      // Если пользователь добавил воду через Apple Watch или другое приложение,
      // мы хотим подтянуть эти данные.
      try {
        if (await _healthService.isHealthSupported()) {
          // Получаем сумму литров за сегодня
          final healthLiters = await _healthService.getTodayWater();

          if (healthLiters > 0) {
            // Конвертируем литры в стаканы (1 стакан ~ 0.25 л)
            final healthCups = (healthLiters / 0.25).round();

            // Если в Health больше данных, чем локально - обновляем локальные
            if (healthCups > currentCups) {
              debugPrint("💧 Syncing from Health: Found $healthCups cups (Local: $currentCups)");
              currentCups = healthCups;
              // Сохраняем обновленные данные локально
              await prefs.setInt('water_consumed', currentCups);
            }
          }
        }
      } catch (e) {
        debugPrint("Health Sync Water Read Error: $e");
      }
      // ----------------------------------

      emit(state.copyWith(
        status: WaterStatus.success,
        consumedCups: currentCups,
        dailyGoal: goal,
        recommendedGoal: recommended,
        isAutoGoal: isAuto,
      ));
    } catch (e) {
      debugPrint("WaterBloc Error in _onLoadData: $e");
      emit(state.copyWith(status: WaterStatus.failure));
    }
  }

  Future<void> _onAddCup(AddWaterCup event, Emitter<WaterState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Проверяем, не наступил ли новый день, пока приложение было открыто
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      int currentCups = state.consumedCups;

      if (lastDate != today) {
        currentCups = 0;
        await prefs.setString('water_last_date', today);
      }

      final newCount = currentCups + 1;
      await prefs.setInt('water_consumed', newCount);

      // --- ИНТЕГРАЦИЯ HEALTH (ЗАПИСЬ) ---
      // Пишем 250 мл (0.25 л) в Здоровье
      _healthService.writeWater(0.25).then((success) {
        if (success) {
          debugPrint("✅ Added 250ml water to Health App");
        } else {
          debugPrint("⚠️ Failed to sync water (permissions?)");
        }
      });
      // ----------------------------------

      emit(state.copyWith(consumedCups: newCount));
    } catch (e) {
      debugPrint("WaterBloc Error in _onAddCup: $e");
    }
  }

  Future<void> _onRemoveCup(
      RemoveWaterCup event, Emitter<WaterState> emit) async {
    try {
      if (state.consumedCups <= 0) return;

      final newCount = state.consumedCups - 1;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_consumed', newCount);

      // Примечание: Удаление конкретной записи из HealthKit сложно без ID,
      // поэтому пока просто уменьшаем локальный счетчик.
      // В будущем можно реализовать логику "удаления последнего сэмпла".

      emit(state.copyWith(consumedCups: newCount));
    } catch (e) {
      debugPrint("WaterBloc Error in _onRemoveCup: $e");
    }
  }

  Future<void> _onUpdateGoal(
      UpdateWaterGoal event, Emitter<WaterState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_goal', event.newGoal);
      // Если пользователь меняет вручную — выключаем авто-режим
      await prefs.setBool('water_is_auto', false);

      emit(state.copyWith(dailyGoal: event.newGoal, isAutoGoal: false));
    } catch (e) {
      debugPrint("WaterBloc Error in _onUpdateGoal: $e");
    }
  }

  Future<void> _onToggleAutoGoal(
      ToggleAutoGoal event, Emitter<WaterState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('water_is_auto', event.isEnabled);

      // Если включили авто, сразу применяем рекомендованную цель
      int newGoal = state.dailyGoal;
      if (event.isEnabled) {
        newGoal = state.recommendedGoal;
        await prefs.setInt('water_goal', newGoal);
      }

      emit(state.copyWith(isAutoGoal: event.isEnabled, dailyGoal: newGoal));
    } catch (e) {
      debugPrint("WaterBloc Error in _onToggleAutoGoal: $e");
    }
  }

  Future<void> _onUpdateRecommendedGoal(
      UpdateRecommendedGoal event, Emitter<WaterState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_recommended', event.cups);

      // Если авто-режим включен, обновляем и текущую цель
      int currentGoal = state.dailyGoal;
      if (state.isAutoGoal) {
        currentGoal = event.cups;
        await prefs.setInt('water_goal', currentGoal);
      }

      emit(state.copyWith(recommendedGoal: event.cups, dailyGoal: currentGoal));
    } catch (e) {
      debugPrint("WaterBloc Error in _onUpdateRecommendedGoal: $e");
    }
  }
}