import 'package:equatable/equatable.dart';
import 'package:fastable/models/weight_entry.dart';

// Enums для персонализации
enum Gender { male, female }
enum ActivityLevel { sedentary, moderate, active }
enum WeightStatus { initial, loading, success, failure }

class WeightState extends Equatable {
  final WeightStatus status;

  // Основные метрики
  final double currentWeight;
  final double startWeight;
  final double targetWeight; // Целевой вес
  final double heightCm;

  // Персонализация (для точных расчетов)
  final int age;
  final Gender gender;
  final ActivityLevel activityLevel;

  // История
  final List<WeightEntry> history;

  const WeightState({
    this.status = WeightStatus.initial,
    this.currentWeight = 70.0,
    this.startWeight = 70.0,
    this.targetWeight = 65.0,
    this.heightCm = 170.0,
    // Дефолтные значения для новых пользователей
    this.age = 25,
    this.gender = Gender.male,
    this.activityLevel = ActivityLevel.moderate,
    this.history = const [],
  });

  // --- УМНЫЕ РАСЧЕТЫ (Smart Features) ---

  /// 1. BMI (Индекс массы тела)
  double get bmi {
    if (heightCm <= 0) return 0;
    double heightM = heightCm / 100;
    return currentWeight / (heightM * heightM);
  }

  /// Категория BMI (ключ для локализации)
  String get bmiCategoryKey {
    final val = bmi;
    if (val < 18.5) return "bmiUnderweight";
    if (val < 25) return "bmiNormal";
    if (val < 30) return "bmiOverweight";
    return "bmiObese";
  }

  /// 2. BMR (Базальный метаболизм) - Формула Миффлина-Сан Жеора
  /// Сколько калорий тело сжигает в покое.
  double get bmr {
    if (currentWeight <= 0 || heightCm <= 0) return 0;

    // Формула: (10 × weight) + (6.25 × height) - (5 × age) + s
    // s: +5 для мужчин, -161 для женщин
    double base = (10 * currentWeight) + (6.25 * heightCm) - (5 * age);
    return gender == Gender.male ? (base + 5) : (base - 161);
  }

  /// 3. TDEE (Суточный расход энергии)
  /// Сколько калорий нужно, чтобы вес стоял на месте.
  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case ActivityLevel.sedentary: multiplier = 1.2; break; // Сидячий
      case ActivityLevel.moderate: multiplier = 1.55; break; // Умеренный
      case ActivityLevel.active: multiplier = 1.725; break; // Активный
    }
    return bmr * multiplier;
  }

  // --- COPY WITH ---

  WeightState copyWith({
    WeightStatus? status,
    double? currentWeight,
    double? startWeight,
    double? targetWeight,
    double? heightCm,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    List<WeightEntry>? history,
  }) {
    return WeightState(
      status: status ?? this.status,
      currentWeight: currentWeight ?? this.currentWeight,
      startWeight: startWeight ?? this.startWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
    status, currentWeight, startWeight, targetWeight,
    heightCm, age, gender, activityLevel, history
  ];
}