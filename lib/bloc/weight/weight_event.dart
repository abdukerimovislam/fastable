import 'package:equatable/equatable.dart';
// Импортируем State, так как там лежат Enums (Gender, ActivityLevel)
import 'package:fastable/bloc/weight/weight_state.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузка сохраненных данных при старте
class LoadWeightData extends WeightEvent {}

/// Обновление роста
class UpdateHeight extends WeightEvent {
  final double heightCm;
  const UpdateHeight(this.heightCm);

  @override
  List<Object?> get props => [heightCm];
}

/// Добавление веса (и запись в историю)
class AddWeightEntry extends WeightEvent {
  final double weight;
  const AddWeightEntry(this.weight);

  @override
  List<Object?> get props => [weight];
}

// --- НОВЫЕ СОБЫТИЯ ПЕРСОНАЛИЗАЦИИ ---

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