import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  const WaterEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузить данные (проверить дату, сбросить если новый день)
class LoadWaterData extends WaterEvent {}

/// Выпить стакан (+1)
class AddWaterCup extends WaterEvent {}

/// Убрать стакан (-1)
class RemoveWaterCup extends WaterEvent {}

/// Изменить цель (например, 8 -> 10 стаканов)
class UpdateWaterGoal extends WaterEvent {
  final int newGoal;
  const UpdateWaterGoal(this.newGoal);
}