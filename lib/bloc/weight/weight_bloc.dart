import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/models/weight_entry.dart';
import 'package:fastable/services/health_service.dart';

@injectable
class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository _repository;
  final HealthService _healthService;

  WeightBloc(this._repository, this._healthService) : super(const WeightState()) {
    on<LoadWeightData>(_onLoadData);

    on<UpdateHeight>(_onUpdateHeight);
    on<AddWeightEntry>(_onAddEntry);

    on<UpdateAge>(_onUpdateAge);
    on<UpdateGender>(_onUpdateGender);
    on<UpdateActivityLevel>(_onUpdateActivity);
  }

  Future<void> _onLoadData(LoadWeightData event, Emitter<WeightState> emit) async {
    emit(state.copyWith(status: WeightStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();

      final height = prefs.getDouble('user_height') ?? 170.0;
      double currentWeight = prefs.getDouble('user_weight') ?? 70.0;
      final age = prefs.getInt('user_age') ?? 25;

      final genderIdx = prefs.getInt('user_gender') ?? 0;
      final gender = Gender.values.asMap()[genderIdx] ?? Gender.male;

      final activityIdx = prefs.getInt('user_activity') ?? 1;
      final activity = ActivityLevel.values.asMap()[activityIdx] ?? ActivityLevel.moderate;

      List<WeightEntry> history = [];
      try {
        history = await _repository.getWeightHistory();
      } catch (e) {
        debugPrint("History load failed: $e");
      }

      // --- ИНТЕГРАЦИЯ HEALTH (ЧТЕНИЕ И УМНОЕ СОХРАНЕНИЕ) ---
      try {
        if (await _healthService.isHealthSupported()) {
          final healthWeight = await _healthService.getLatestWeight();

          if (healthWeight != null && healthWeight != currentWeight) {
            debugPrint("📱 Found new weight in Health App: $healthWeight");

            // 1. Обновляем текущий вес
            currentWeight = healthWeight;
            await prefs.setDouble('user_weight', currentWeight);

            // 🔥 ИСПРАВЛЕНИЕ: Обязательно сохраняем вес в наш Репозиторий,
            // иначе графики сломаются и не покажут новую точку!
            await _repository.addWeightEntry(WeightEntry(date: DateTime.now(), weight: currentWeight));

            // 2. Перезапрашиваем историю, чтобы UI перерисовался корректно
            history = await _repository.getWeightHistory();
          }
        }
      } catch (e) {
        debugPrint("Health Sync Read Error: $e");
      }
      // ----------------------------------

      emit(state.copyWith(
        status: WeightStatus.success,
        heightCm: height,
        currentWeight: currentWeight,
        age: age,
        gender: gender,
        activityLevel: activity,
        history: history,
      ));
    } catch (e) {
      emit(state.copyWith(status: WeightStatus.failure));
    }
  }

  Future<void> _onUpdateHeight(UpdateHeight event, Emitter<WeightState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_height', event.heightCm);
    emit(state.copyWith(heightCm: event.heightCm));
  }

  Future<void> _onAddEntry(AddWeightEntry event, Emitter<WeightState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble('user_weight', event.weight);

      final newEntry = WeightEntry(date: DateTime.now(), weight: event.weight);
      await _repository.addWeightEntry(newEntry);

      _healthService.writeWeight(event.weight).then((success) {
        if (success) {
          debugPrint("✅ Weight synced to Health App");
        } else {
          debugPrint("⚠️ Weight sync skipped (no permission or error)");
        }
      });

      final updatedHistory = await _repository.getWeightHistory();

      emit(state.copyWith(
        currentWeight: event.weight,
        history: updatedHistory,
      ));
    } catch (e) {
      debugPrint("Error adding weight: $e");
    }
  }

  Future<void> _onUpdateAge(UpdateAge event, Emitter<WeightState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', event.age);
    emit(state.copyWith(age: event.age));
  }

  Future<void> _onUpdateGender(UpdateGender event, Emitter<WeightState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_gender', event.gender.index);
    emit(state.copyWith(gender: event.gender));
  }

  Future<void> _onUpdateActivity(UpdateActivityLevel event, Emitter<WeightState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_activity', event.level.index);
    emit(state.copyWith(activityLevel: event.level));
  }
}