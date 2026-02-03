import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/models/weight_entry.dart';

@injectable
class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository _weightRepository;
  final HealthService _healthService; // Для синхронизации с Apple Health

  WeightBloc(this._weightRepository, this._healthService) : super(const WeightState()) {
    on<LoadWeightData>(_onLoadData);
    on<AddWeightEntry>(_onAddWeight);
    on<UpdateHeight>(_onUpdateHeight);
  }

  Future<void> _onLoadData(LoadWeightData event, Emitter<WeightState> emit) async {
    emit(state.copyWith(status: WeightStatus.loading));

    final prefs = await SharedPreferences.getInstance();
    final height = (prefs.getInt('user_height') ?? 175).toDouble();
    final goal = (prefs.getDouble('user_goal_weight') ?? 65.0); // Используем double, не int

    // 1. Получаем текущий вес из репозитория (БД)
    double? current = await _weightRepository.getCurrentWeight();

    // 2. Если в БД пусто, пробуем Apple Health (Fallback)
    if (current == null) {
      // Требует прав, но метод безопасен (вернет null если нет прав)
      final healthWeight = await _healthService.fetchWeight();
      if (healthWeight != null) current = healthWeight;
    }

    current = current ?? 70.0;

    // 3. Получаем историю (если в репозитории есть метод getHistory, иначе пустой список)
    // Допустим, пока просто список, чтобы не усложнять.
    // final history = await _weightRepository.getHistory();
    final List<WeightEntry> history = [];

    final bmi = _calculateBMI(current, height);

    emit(state.copyWith(
      status: WeightStatus.success,
      currentWeight: current,
      heightCm: height,
      goalWeight: goal,
      bmi: bmi,
      history: history,
    ));
  }

  Future<void> _onAddWeight(AddWeightEntry event, Emitter<WeightState> emit) async {
    // Оптимистичное обновление UI
    final newBmi = _calculateBMI(event.weight, state.heightCm);
    emit(state.copyWith(
      currentWeight: event.weight,
      bmi: newBmi,
    ));

    // Асинхронное сохранение
    try {
      // 1. Локальная БД / Firestore
      await _weightRepository.addWeightOrUpdateToday(event.weight);

      // 2. Apple Health / Google Fit
      await _healthService.saveWeight(event.weight);

      // 3. Можно перезагрузить историю, если нужно
    } catch (e) {
      // Обработка ошибок (можно добавить поле error в state)
      print("Weight save error: $e");
    }
  }

  Future<void> _onUpdateHeight(UpdateHeight event, Emitter<WeightState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_height', event.heightCm.toInt());

    final newBmi = _calculateBMI(state.currentWeight, event.heightCm);

    emit(state.copyWith(
      heightCm: event.heightCm,
      bmi: newBmi,
    ));
  }

  double _calculateBMI(double weight, double heightCm) {
    if (heightCm <= 0) return 0;
    double heightM = heightCm / 100.0;
    return weight / (heightM * heightM);
  }
}