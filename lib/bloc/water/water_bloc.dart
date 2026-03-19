import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart';

@injectable
class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _repository;
  final HealthService _healthService;

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

      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      int currentCups = prefs.getInt('water_consumed') ?? 0;

      if (lastDate != today) {
        currentCups = 0;
        await prefs.setString('water_last_date', today);
        await prefs.setInt('water_consumed', 0);
        // 🔥 ИСПРАВЛЕНИЕ: Сбрасываем трекер системного здоровья с наступлением нового дня
        await prefs.setDouble('health_water_last_liters', 0.0);
      }

      final goal = prefs.getInt('water_goal') ?? 8;
      final recommended = prefs.getInt('water_recommended') ?? 8;
      final isAuto = prefs.getBool('water_is_auto') ?? true;

      // --- ИНТЕГРАЦИЯ HEALTH (УМНОЕ ЧТЕНИЕ) ---
      try {
        if (await _healthService.isHealthSupported()) {
          final healthLiters = await _healthService.getTodayWater();
          final lastHealthLiters = prefs.getDouble('health_water_last_liters') ?? 0.0;

          // 🔥 ИСПРАВЛЕНИЕ: Дифференциальная синхронизация.
          // Добавляем стаканы ТОЛЬКО если вода была добавлена извне (Apple Watch и т.д.)
          if (healthLiters > lastHealthLiters) {
            final addedLiters = healthLiters - lastHealthLiters;
            final addedCups = (addedLiters / 0.25).round();

            if (addedCups > 0) {
              debugPrint("💧 Smart Sync: Added $addedCups cups from Apple Health");
              currentCups += addedCups;
              await prefs.setInt('water_consumed', currentCups);
            }
            // Запоминаем новый уровень в Health
            await prefs.setDouble('health_water_last_liters', healthLiters);
          } else if (healthLiters < lastHealthLiters) {
            // Юзер удалил воду напрямую в приложении Health - просто обновляем наш якорь
            await prefs.setDouble('health_water_last_liters', healthLiters);
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
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      int currentCups = state.consumedCups;

      if (lastDate != today) {
        currentCups = 0;
        await prefs.setString('water_last_date', today);
        await prefs.setDouble('health_water_last_liters', 0.0);
      }

      final newCount = currentCups + 1;
      await prefs.setInt('water_consumed', newCount);

      // --- ИНТЕГРАЦИЯ HEALTH (ЗАПИСЬ) ---
      _healthService.writeWater(0.25).then((success) async {
        if (success) {
          debugPrint("✅ Added 250ml water to Health App");
          // 🔥 ИСПРАВЛЕНИЕ: Плюсуем в наш якорь, чтобы при следующем открытии
          // этот же стакан не добавился второй раз как "внешний"
          final lastHealthLiters = prefs.getDouble('health_water_last_liters') ?? 0.0;
          await prefs.setDouble('health_water_last_liters', lastHealthLiters + 0.25);
        }
      });

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

      // Мы просто уменьшаем локальный счетчик. Якорь Health не трогаем.
      // Это убивает баг "бессмертной воды".

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