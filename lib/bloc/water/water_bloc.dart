import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';

@injectable
class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _repository;

  WaterBloc(this._repository) : super(const WaterState()) {
    on<LoadWaterData>(_onLoadData);
    on<AddWaterCup>(_onAddCup);
    on<RemoveWaterCup>(_onRemoveCup);
    on<UpdateWaterGoal>(_onUpdateGoal);

    // Новые обработчики
    on<ToggleAutoGoal>(_onToggleAutoGoal);
    on<UpdateRecommendedGoal>(_onUpdateRecommendedGoal);
  }

  Future<void> _onLoadData(LoadWaterData event, Emitter<WaterState> emit) async {
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

    emit(state.copyWith(
      status: WaterStatus.success,
      consumedCups: currentCups,
      dailyGoal: goal,
      recommendedGoal: recommended,
      isAutoGoal: isAuto,
    ));
  }

  Future<void> _onAddCup(AddWaterCup event, Emitter<WaterState> emit) async {
    final newCount = state.consumedCups + 1;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('water_consumed', newCount);
    await prefs.setString('water_last_date', DateTime.now().toIso8601String().substring(0, 10));

    emit(state.copyWith(consumedCups: newCount));
  }

  Future<void> _onRemoveCup(RemoveWaterCup event, Emitter<WaterState> emit) async {
    if (state.consumedCups <= 0) return;
    final newCount = state.consumedCups - 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_consumed', newCount);

    emit(state.copyWith(consumedCups: newCount));
  }

  Future<void> _onUpdateGoal(UpdateWaterGoal event, Emitter<WaterState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_goal', event.newGoal);
    // Если пользователь меняет вручную — выключаем авто-режим
    await prefs.setBool('water_is_auto', false);

    emit(state.copyWith(dailyGoal: event.newGoal, isAutoGoal: false));
  }

  Future<void> _onToggleAutoGoal(ToggleAutoGoal event, Emitter<WaterState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_is_auto', event.isEnabled);

    // Если включили авто, сразу применяем рекомендованную цель
    int newGoal = state.dailyGoal;
    if (event.isEnabled) {
      newGoal = state.recommendedGoal;
      await prefs.setInt('water_goal', newGoal);
    }

    emit(state.copyWith(isAutoGoal: event.isEnabled, dailyGoal: newGoal));
  }

  Future<void> _onUpdateRecommendedGoal(UpdateRecommendedGoal event, Emitter<WaterState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_recommended', event.cups);

    // Если авто-режим включен, обновляем и текущую цель
    int currentGoal = state.dailyGoal;
    if (state.isAutoGoal) {
      currentGoal = event.cups;
      await prefs.setInt('water_goal', currentGoal);
    }

    emit(state.copyWith(recommendedGoal: event.cups, dailyGoal: currentGoal));
  }
}