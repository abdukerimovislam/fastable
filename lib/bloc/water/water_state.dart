import 'package:equatable/equatable.dart';
import '../../models/drink_record.dart';

enum WaterStatus { initial, loading, success, failure }

class WaterState extends Equatable {
  final WaterStatus status;
  final List<DrinkRecord> todayDrinks; // 🔥 СПИСОК ВСЕХ НАПИТКОВ ЗА ДЕНЬ
  final int dailyGoal; // В миллилитрах (раньше было в чашках)
  final int recommendedGoal;
  final bool isAutoGoal;

  const WaterState({
    this.status = WaterStatus.initial,
    this.todayDrinks = const [],
    this.dailyGoal = 2000, // По умолчанию 2 литра
    this.recommendedGoal = 2000,
    this.isAutoGoal = true,
  });

  // Умный подсчет чистой гидратации (с учетом кофе/алкоголя)
  double get totalHydrationMl {
    return todayDrinks.fold(0.0, (sum, drink) => sum + drink.effectiveHydration);
  }

  // Общий выпитый объем жидкостей (без учета фактора)
  int get totalVolumeMl {
    return todayDrinks.fold(0, (sum, drink) => sum + drink.volumeMl);
  }

  double get progress {
    if (dailyGoal == 0) return 0;
    return (totalHydrationMl / dailyGoal).clamp(0.0, 1.0);
  }

  WaterState copyWith({
    WaterStatus? status,
    List<DrinkRecord>? todayDrinks,
    int? dailyGoal,
    int? recommendedGoal,
    bool? isAutoGoal,
  }) {
    return WaterState(
      status: status ?? this.status,
      todayDrinks: todayDrinks ?? this.todayDrinks,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      recommendedGoal: recommendedGoal ?? this.recommendedGoal,
      isAutoGoal: isAutoGoal ?? this.isAutoGoal,
    );
  }

  @override
  List<Object?> get props => [status, todayDrinks, dailyGoal, recommendedGoal, isAutoGoal];
}