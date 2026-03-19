import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // 🔥 Импорт для WidgetsBindingObserver
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart';

@injectable
// 🔥 ИСПРАВЛЕНИЕ 1: Добавляем WidgetsBindingObserver для отслеживания смены суток
class WaterBloc extends Bloc<WaterEvent, WaterState> with WidgetsBindingObserver {
  final WaterRepository _repository;
  final HealthService _healthService;

  WaterBloc(this._repository, this._healthService) : super(const WaterState()) {

    // Регистрируем наблюдателя за жизненным циклом
    WidgetsBinding.instance.addObserver(this);

    on<LoadWaterData>(_onLoadData);
    on<AddWaterCup>(_onAddCup);
    on<RemoveWaterCup>(_onRemoveCup);
    on<UpdateWaterGoal>(_onUpdateGoal);
    on<ToggleAutoGoal>(_onToggleAutoGoal);
    on<UpdateRecommendedGoal>(_onUpdateRecommendedGoal);
  }

  // 🔥 Ловим момент, когда юзер разворачивает приложение (например, проснувшись утром)
  @override
  void didChangeAppLifecycleState(AppLifecycleState stateLifecycle) {
    if (stateLifecycle == AppLifecycleState.resumed) {
      // Автоматически перепроверяем даты и синхронизируем с Health
      add(LoadWaterData());
    }
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

          if (healthLiters > lastHealthLiters) {
            final addedLiters = healthLiters - lastHealthLiters;
            final addedCups = (addedLiters / 0.25).round();

            if (addedCups > 0) {
              debugPrint("💧 Smart Sync: Added $addedCups cups from Apple Health");
              currentCups += addedCups;
              await prefs.setInt('water_consumed', currentCups);
            }
            await prefs.setDouble('health_water_last_liters', healthLiters);
          } else if (healthLiters < lastHealthLiters) {
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
      // 🔥 ИСПРАВЛЕНИЕ 2: Оптимистичное обновление UI (Optimistic Update)
      // Сразу обновляем стейт синхронно, чтобы не было лагов при спам-кликах
      final newCount = state.consumedCups + 1;
      emit(state.copyWith(consumedCups: newCount));

      // А уже потом спокойно сохраняем данные в фоне
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Страховка: если юзер тапнул прям в 00:00:01
      if (lastDate != today) {
        await prefs.setString('water_last_date', today);
        await prefs.setDouble('health_water_last_liters', 0.0);
        await prefs.setInt('water_consumed', 1);
        emit(state.copyWith(consumedCups: 1)); // Корректируем стейт
      } else {
        await prefs.setInt('water_consumed', newCount);
      }

      // --- ИНТЕГРАЦИЯ HEALTH (ЗАПИСЬ) ---
      _healthService.writeWater(0.25).then((success) async {
        if (success) {
          debugPrint("✅ Added 250ml water to Health App");
          final lastHealthLiters = prefs.getDouble('health_water_last_liters') ?? 0.0;
          await prefs.setDouble('health_water_last_liters', lastHealthLiters + 0.25);
        }
      });
    } catch (e) {
      debugPrint("WaterBloc Error in _onAddCup: $e");
    }
  }

  Future<void> _onRemoveCup(
      RemoveWaterCup event, Emitter<WaterState> emit) async {
    try {
      if (state.consumedCups <= 0) return;

      // 🔥 Оптимистичное обновление UI для удаления
      final newCount = state.consumedCups - 1;
      emit(state.copyWith(consumedCups: newCount));

      // Сохраняем в фоне
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_consumed', newCount);

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

  @override
  Future<void> close() {
    // Обязательно отписываемся от жизненного цикла во избежание утечек памяти
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}