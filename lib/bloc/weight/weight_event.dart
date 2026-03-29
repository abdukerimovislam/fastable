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

// --- СОБЫТИЯ ЗАМЕРОВ ТЕЛА ---

class UpdateChest extends WeightEvent {
  final double chestCm;
  const UpdateChest(this.chestCm);
  @override
  List<Object?> get props => [chestCm];
}

class UpdateWaist extends WeightEvent {
  final double waistCm;
  const UpdateWaist(this.waistCm);
  @override
  List<Object?> get props => [waistCm];
}

class UpdateHips extends WeightEvent {
  final double hipsCm;
  const UpdateHips(this.hipsCm);
  @override
  List<Object?> get props => [hipsCm];
}

/// Обновление уровня активности
class UpdateActivityLevel extends WeightEvent {
  final ActivityLevel level;
  const UpdateActivityLevel(this.level);

  @override
  List<Object?> get props => [level];
}
