import 'package:equatable/equatable.dart';
import '../../models/drink_record.dart'; // 🔥 ИМПОРТ МОДЕЛИ

abstract class WaterEvent extends Equatable {
  const WaterEvent();
  @override
  List<Object?> get props => [];
}

class LoadWaterData extends WaterEvent {}

// 🔥 ИЗМЕНЕННОЕ СОБЫТИЕ: Теперь передаем тип напитка и объем
class AddDrink extends WaterEvent {
  final DrinkType type;
  final int volumeMl;

  const AddDrink({required this.type, required this.volumeMl});

  @override
  List<Object?> get props => [type, volumeMl];
}

class RemoveLastDrink extends WaterEvent {}

class UpdateWaterGoal extends WaterEvent {
  final int newGoal;
  const UpdateWaterGoal(this.newGoal);
  @override
  List<Object?> get props => [newGoal];
}

class ToggleAutoGoal extends WaterEvent {
  final bool isEnabled;
  const ToggleAutoGoal(this.isEnabled);
  @override
  List<Object?> get props => [isEnabled];
}

class UpdateRecommendedGoal extends WaterEvent {
  final int cups;
  const UpdateRecommendedGoal(this.cups);
  @override
  List<Object?> get props => [cups];
}
