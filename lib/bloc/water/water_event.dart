import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  const WaterEvent();
  @override
  List<Object?> get props => [];
}

class LoadWaterData extends WaterEvent {}
class AddWaterCup extends WaterEvent {}
class RemoveWaterCup extends WaterEvent {}

class UpdateWaterGoal extends WaterEvent {
  final int newGoal;
  const UpdateWaterGoal(this.newGoal);
  @override
  List<Object?> get props => [newGoal];
}

// --- НОВЫЕ СОБЫТИЯ ---

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