import 'package:equatable/equatable.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();
  @override
  List<Object?> get props => [];
}

/// Загрузить данные (вес, рост, история)
class LoadWeightData extends WeightEvent {}

/// Пользователь ввел новый вес
class AddWeightEntry extends WeightEvent {
  final double weight;
  const AddWeightEntry(this.weight);
}

/// Обновили рост (нужно для пересчета BMI)
class UpdateHeight extends WeightEvent {
  final double heightCm;
  const UpdateHeight(this.heightCm);
}

/// Удалить запись (опционально)
class DeleteWeightEntry extends WeightEvent {
  final DateTime date;
  const DeleteWeightEntry(this.date);
}