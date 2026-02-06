import 'dart:async';
import 'package:flutter/foundation.dart'; // Для debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/models/weight_entry.dart';
import 'package:fastable/services/health_service.dart'; // <-- Импорт нового сервиса

@injectable
class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository _repository;
  final HealthService _healthService; // <-- Добавляем зависимость

  WeightBloc(this._repository, this._healthService) : super(const WeightState()) {
    on<LoadWeightData>(_onLoadData);

    // Основные метрики
    on<UpdateHeight>(_onUpdateHeight);
    on<AddWeightEntry>(_onAddEntry);

    // Персонализация (BMR/TDEE)
    on<UpdateAge>(_onUpdateAge);
    on<UpdateGender>(_onUpdateGender);
    on<UpdateActivityLevel>(_onUpdateActivity);
  }

  Future<void> _onLoadData(LoadWeightData event, Emitter<WeightState> emit) async {
    emit(state.copyWith(status: WeightStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Загружаем простые типы
      final height = prefs.getDouble('user_height') ?? 170.0;
      double currentWeight = prefs.getDouble('user_weight') ?? 70.0;
      final age = prefs.getInt('user_age') ?? 25;

      // 2. Безопасная загрузка Enums
      final genderIdx = prefs.getInt('user_gender') ?? 0;
      final gender = Gender.values.asMap()[genderIdx] ?? Gender.male;

      final activityIdx = prefs.getInt('user_activity') ?? 1;
      final activity = ActivityLevel.values.asMap()[activityIdx] ?? ActivityLevel.moderate;

      // 3. Загружаем историю из репозитория
      List<WeightEntry> history = [];
      try {
        history = await _repository.getWeightHistory();
      } catch (e) {
        debugPrint("History load failed: $e");
      }

      // --- ИНТЕГРАЦИЯ HEALTH (ЧТЕНИЕ) ---
      // Проверяем, есть ли более свежий вес в Apple Health / Health Connect
      // Это полезно, если пользователь взвесился через умные весы
      try {
        if (await _healthService.isHealthSupported()) {
          final healthWeight = await _healthService.getLatestWeight();

          if (healthWeight != null) {
            // Если вес в Health отличается от нашего текущего, можно обновить
            // (Логику можно усложнить: проверять дату записи)
            if (healthWeight != currentWeight) {
              debugPrint("📱 Found new weight in Health App: $healthWeight");
              // Опционально: можно здесь же сохранить его в локальную историю
              // Но пока просто обновим UI "текущий вес"
              currentWeight = healthWeight;
            }
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

      // 1. Обновляем "Текущий вес" локально
      await prefs.setDouble('user_weight', event.weight);

      // 2. Добавляем запись в локальную историю
      final newEntry = WeightEntry(date: DateTime.now(), weight: event.weight);
      await _repository.addWeightEntry(newEntry);

      // --- ИНТЕГРАЦИЯ HEALTH (ЗАПИСЬ) ---
      // Отправляем вес в Apple Health / Health Connect
      // Запускаем "в фоне" (без await), чтобы не блокировать интерфейс,
      // либо обрабатываем результат, если хотим показать галочку "Synced"
      _healthService.writeWeight(event.weight).then((success) {
        if (success) {
          debugPrint("✅ Weight synced to Health App");
        } else {
          debugPrint("⚠️ Weight sync skipped (no permission or error)");
        }
      });
      // ----------------------------------

      // 3. Обновляем UI
      // Для консистентности лучше перезагрузить историю из репозитория,
      // так как там логика сортировки и перезаписи по дате.
      final updatedHistory = await _repository.getWeightHistory();

      emit(state.copyWith(
        currentWeight: event.weight,
        history: updatedHistory,
      ));
    } catch (e) {
      debugPrint("Error adding weight: $e");
      // Здесь можно эмитить состояние ошибки, если нужно показать SnackBar
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