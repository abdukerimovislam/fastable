import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/models/weight_entry.dart';

@injectable
class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository _repository;

  WeightBloc(this._repository) : super(const WeightState()) {
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
      final currentWeight = prefs.getDouble('user_weight') ?? 70.0;
      final age = prefs.getInt('user_age') ?? 25;

      // 2. Безопасная загрузка Enums (защита от crash при неверном индексе)
      final genderIdx = prefs.getInt('user_gender') ?? 0;
      final gender = Gender.values.asMap()[genderIdx] ?? Gender.male;

      final activityIdx = prefs.getInt('user_activity') ?? 1; // 1 = Moderate
      final activity = ActivityLevel.values.asMap()[activityIdx] ?? ActivityLevel.moderate;

      // 3. Загружаем историю из репозитория (БД/Hive/Firestore)
      // Если репозиторий возвращает Stream, здесь можно подписаться, но для примера берем Future
      List<WeightEntry> history = [];
      try {
        history = await _repository.getWeightHistory();
      } catch (e) {
        // Если история не загрузилась, не ломаем весь стейт, просто оставляем пустой
        // debugPrint("History load failed: $e");
      }

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

      // 1. Обновляем "Текущий вес" (быстрый доступ)
      await prefs.setDouble('user_weight', event.weight);

      // 2. Добавляем запись в историю через репозиторий
      final newEntry = WeightEntry(date: DateTime.now(), weight: event.weight);
      await _repository.addWeightEntry(newEntry);

      // 3. Обновляем список истории в стейте
      // (Можно либо перезапросить весь список, либо добавить локально для скорости)
      final updatedHistory = List<WeightEntry>.from(state.history)..add(newEntry);
      // Сортируем от новых к старым, если нужно
      updatedHistory.sort((a, b) => b.date.compareTo(a.date));

      emit(state.copyWith(
        currentWeight: event.weight,
        history: updatedHistory,
      ));
    } catch (e) {
      // Можно добавить обработку ошибок (например, SnackBar через Listener в UI)
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