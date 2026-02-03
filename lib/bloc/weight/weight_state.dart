import 'package:equatable/equatable.dart';
import 'package:fastable/models/weight_entry.dart'; // Убедись, что модель существует

enum WeightStatus { initial, loading, success, failure }

class WeightState extends Equatable {
  final WeightStatus status;
  final double currentWeight;
  final double startWeight; // Вес, с которого начали
  final double goalWeight;
  final double heightCm;
  final double bmi;

  // История веса (для построения графиков в будущем)
  final List<WeightEntry> history;

  const WeightState({
    this.status = WeightStatus.initial,
    this.currentWeight = 70.0,
    this.startWeight = 70.0,
    this.goalWeight = 65.0,
    this.heightCm = 175.0,
    this.bmi = 0.0,
    this.history = const [],
  });

  WeightState copyWith({
    WeightStatus? status,
    double? currentWeight,
    double? startWeight,
    double? goalWeight,
    double? heightCm,
    double? bmi,
    List<WeightEntry>? history,
  }) {
    return WeightState(
      status: status ?? this.status,
      currentWeight: currentWeight ?? this.currentWeight,
      startWeight: startWeight ?? this.startWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      heightCm: heightCm ?? this.heightCm,
      bmi: bmi ?? this.bmi,
      history: history ?? this.history,
    );
  }

  /// Категория BMI (текстовый ключ, можно использовать в UI)
  String get bmiCategoryKey {
    if (bmi < 18.5) return "bmiUnderweight";
    if (bmi < 25) return "bmiNormal";
    if (bmi < 30) return "bmiOverweight";
    return "bmiObese";
  }

  @override
  List<Object?> get props => [status, currentWeight, startWeight, goalWeight, heightCm, bmi, history];
}