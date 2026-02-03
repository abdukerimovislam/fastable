import 'package:equatable/equatable.dart';
// Импортируем State, чтобы видеть Enums (Gender, ActivityLevel)
import 'package:fastable/bloc/weight/weight_state.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузка всех данных (профиль, вес, история)
class LoadWeightData extends WeightEvent {}

/// Обновление роста
class UpdateHeight extends WeightEvent {
  final double heightCm;
  const UpdateHeight(this.heightCm);

  @override
  List<Object?> get props => [heightCm];
}

/// Добавление нового веса (запись в историю + обновление текущего)
class AddWeightEntry extends WeightEvent {
  final double weight;
  const AddWeightEntry(this.weight);

  @override
  List<Object?> get props => [weight];
}

/// Обновление целевого веса (Goal) — ДОБАВЛЕНО ДЛЯ ПОЛНОТЫ
class UpdateGoalWeight extends WeightEvent {
  final double targetWeight;
  const UpdateGoalWeight(this.targetWeight);

  @override
  List<Object?> get props => [targetWeight];
}

// --- СОБЫТИЯ ПЕРСОНАЛИЗАЦИИ (BMR / TDEE) ---

/// Обновление возраста
class UpdateAge extends WeightEvent {
  final int age;
  const UpdateAge(this.age);

  @override
  List<Object?> get props => [age];
}

/// Обновление пола
class UpdateGender extends WeightEvent {
  final Gender gender;
  const UpdateGender(this.gender);

  @override
  List<Object?> get props => [gender];
}

/// Обновление уровня активности
class UpdateActivityLevel extends WeightEvent {
  final ActivityLevel level;
  const UpdateActivityLevel(this.level);

  @override
  List<Object?> get props => [level];
}