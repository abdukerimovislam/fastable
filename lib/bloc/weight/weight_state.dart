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
  final double goalWeight;
  final double heightCm;

  // 🔥 НОВЫЕ ПОЛЯ: ЗАМЕРЫ ТЕЛА (в сантиметрах)
  final double? waistCm; // Талия
  final double? hipsCm;  // Бедра
  final double? chestCm; // Грудь (или обхват под грудью)

  // Персонализация
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
    this.waistCm, // null значит еще не замеряли
    this.hipsCm,
    this.chestCm,
    this.age = 25,
    this.gender = Gender.male,
    this.activityLevel = ActivityLevel.moderate,
    this.history = const [],
  });

  // --- УМНЫЕ РАСЧЕТЫ (Smart Features) ---

  double get bmi {
    if (heightCm <= 0) return 0;
    double heightM = heightCm / 100;
    return currentWeight / (heightM * heightM);
  }

  String get bmiCategoryKey {
    final val = bmi;
    if (val < 18.5) return "bmiUnderweight";
    if (val < 25) return "bmiNormal";
    if (val < 30) return "bmiOverweight";
    return "bmiObese";
  }

  double get bmr {
    if (currentWeight <= 0 || heightCm <= 0) return 0;
    double base = (10 * currentWeight) + (6.25 * heightCm) - (5 * age);
    return gender == Gender.male ? (base + 5) : (base - 161);
  }

  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case ActivityLevel.sedentary: multiplier = 1.2; break;
      case ActivityLevel.moderate: multiplier = 1.55; break;
      case ActivityLevel.active: multiplier = 1.725; break;
    }
    return bmr * multiplier;
  }

  // --- ИНДЕКС ТАЛИЯ/РОСТ (Waist-to-Height Ratio - WHtR) ---
  // Это более точный показатель здоровья, чем BMI!
  double? get waistToHeightRatio {
    if (waistCm == null || heightCm <= 0) return null;
    return waistCm! / heightCm;
  }

  WeightState copyWith({
    WeightStatus? status,
    double? currentWeight,
    double? startWeight,
    double? goalWeight,
    double? heightCm,
    // 🔥 Оборачиваем в функции, чтобы можно было явно передать null при сбросе
    double? Function()? waistCm,
    double? Function()? hipsCm,
    double? Function()? chestCm,
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
      waistCm: waistCm != null ? waistCm() : this.waistCm,
      hipsCm: hipsCm != null ? hipsCm() : this.hipsCm,
      chestCm: chestCm != null ? chestCm() : this.chestCm,
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
    waistCm, // 🔥 Добавили в props
    hipsCm,
    chestCm,
    age,
    gender,
    activityLevel,
    history
  ];
}