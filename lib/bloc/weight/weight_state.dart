import 'package:equatable/equatable.dart';
import 'package:fastable/models/weight_entry.dart';

// 1. Enums для персонализации
enum Gender { male, female }
enum ActivityLevel { sedentary, moderate, active }
enum WeightStatus { initial, loading, success, failure }

class WeightState extends Equatable {
  final WeightStatus status;

  // Основные метрики
  final double currentWeight;
  final double startWeight;
  final double goalWeight; // В прошлых версиях было targetWeight, оставляем как у тебя
  final double heightCm;

  // 2. Новые поля для персонализации
  final int age;
  final Gender gender;
  final ActivityLevel activityLevel;

  // История веса
  final List<WeightEntry> history;

  const WeightState({
    this.status = WeightStatus.initial,
    this.currentWeight = 70.0,
    this.startWeight = 70.0,
    this.goalWeight = 65.0,
    this.heightCm = 175.0,
    // Дефолтные значения персонализации
    this.age = 25,
    this.gender = Gender.male,
    this.activityLevel = ActivityLevel.moderate,
    this.history = const [],
  });

  // --- УМНЫЕ РАСЧЕТЫ (Smart Features) ---

  /// 1. BMI (Индекс массы тела)
  /// Рассчитывается автоматически, чтобы всегда быть актуальным
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
  /// Сколько калорий тело сжигает в полном покое
  double get bmr {
    if (currentWeight <= 0 || heightCm <= 0) return 0;

    // Формула: (10 × weight) + (6.25 × height) - (5 × age) + s
    // s: +5 для мужчин, -161 для женщин
    double base = (10 * currentWeight) + (6.25 * heightCm) - (5 * age);
    return gender == Gender.male ? (base + 5) : (base - 161);
  }

  /// 3. TDEE (Суточный расход энергии)
  /// Сколько калорий нужно для поддержания веса с учетом активности
  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case ActivityLevel.sedentary: multiplier = 1.2; break; // Сидячий
      case ActivityLevel.moderate: multiplier = 1.55; break; // Умеренный
      case ActivityLevel.active: multiplier = 1.725; break; // Активный
    }
    return bmr * multiplier;
  }

  WeightState copyWith({
    WeightStatus? status,
    double? currentWeight,
    double? startWeight,
    double? goalWeight,
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
      goalWeight: goalWeight ?? this.goalWeight,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentWeight,
    startWeight,
    goalWeight,
    heightCm,
    // bmi не нужен в props, так как он зависит от weight/height
    age,
    gender,
    activityLevel,
    history
  ];
}