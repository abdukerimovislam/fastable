import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart';

@injectable
class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _waterRepository;
  final HealthService _healthService; // Для записи в Apple Health

  WaterBloc(this._waterRepository, this._healthService) : super(const WaterState()) {
    on<LoadWaterData>(_onLoadData);
    on<AddWaterCup>(_onAddCup);
    on<RemoveWaterCup>(_onRemoveCup);
    on<UpdateWaterGoal>(_onUpdateGoal);
  }

  Future<void> _onLoadData(LoadWaterData event, Emitter<WaterState> emit) async {
    emit(state.copyWith(status: WaterStatus.loading));

    final prefs = await SharedPreferences.getInstance();

    // 1. Проверяем смену дня
    String? lastDate = prefs.getString('last_water_date');
    String todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int currentCount = 0;

    if (lastDate != todayStr) {
      // Новый день -> сброс
      currentCount = 0;
      prefs.setString('last_water_date', todayStr);
      // Сразу пишем 0 в базу, чтобы зафиксировать день
      await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), 0);
    } else {
      // Тот же день -> читаем из базы
      currentCount = await _waterRepository.getWaterForDay(DateTime.now());
    }

    // 2. Цель
    int goal = prefs.getInt('water_goal') ?? 8;

    emit(state.copyWith(
      status: WaterStatus.success,
      consumedCups: currentCount,
      dailyGoal: goal,
    ));
  }

  Future<void> _onAddCup(AddWaterCup event, Emitter<WaterState> emit) async {
    final newCount = (state.consumedCups + 1).clamp(0, 99);

    emit(state.copyWith(consumedCups: newCount));

    try {
      // 1. Сохраняем в нашу БД
      await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), newCount);

      // 2. Сохраняем в Apple Health (добавляем 1 порцию 250мл)
      await _healthService.saveWater(state.cupVolumeLiters);

      // 3. Обновляем дату использования
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_water_date', DateTime.now().toIso8601String().substring(0, 10));
    } catch (e) {
      print("Water save error: $e");
    }
  }

  Future<void> _onRemoveCup(RemoveWaterCup event, Emitter<WaterState> emit) async {
    if (state.consumedCups > 0) {
      final newCount = state.consumedCups - 1;
      emit(state.copyWith(consumedCups: newCount));

      // Удаление из Apple Health сложно (надо искать UUID записи),
      // поэтому просто обновляем локальную базу
      await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), newCount);
    }
  }

  Future<void> _onUpdateGoal(UpdateWaterGoal event, Emitter<WaterState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_goal', event.newGoal);

    emit(state.copyWith(dailyGoal: event.newGoal));
  }
}