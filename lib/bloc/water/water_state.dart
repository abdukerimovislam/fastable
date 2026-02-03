import 'package:equatable/equatable.dart';

enum WaterStatus { initial, loading, success, failure }

class WaterState extends Equatable {
  final WaterStatus status;
  final int consumedCups;
  final int dailyGoal;

  // Объем одного стакана (можно сделать настройкой, пока 250мл)
  final double cupVolumeLiters;

  const WaterState({
    this.status = WaterStatus.initial,
    this.consumedCups = 0,
    this.dailyGoal = 8,
    this.cupVolumeLiters = 0.25,
  });

  double get progress {
    if (dailyGoal == 0) return 0;
    return (consumedCups / dailyGoal).clamp(0.0, 1.0);
  }

  /// Общее количество выпитого в литрах
  double get totalLiters => consumedCups * cupVolumeLiters;

  WaterState copyWith({
    WaterStatus? status,
    int? consumedCups,
    int? dailyGoal,
  }) {
    return WaterState(
      status: status ?? this.status,
      consumedCups: consumedCups ?? this.consumedCups,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  @override
  List<Object?> get props => [status, consumedCups, dailyGoal];
}