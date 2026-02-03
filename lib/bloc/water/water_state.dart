import 'package:equatable/equatable.dart';

enum WaterStatus { initial, loading, success, failure }

class WaterState extends Equatable {
  final WaterStatus status;
  final int consumedCups;
  final int dailyGoal;        // Текущая цель (видна юзеру)
  final int recommendedGoal;  // Рассчитанная цель (скрытая)
  final bool isAutoGoal;      // Включен ли авто-режим
  final double cupVolumeLiters;

  const WaterState({
    this.status = WaterStatus.initial,
    this.consumedCups = 0,
    this.dailyGoal = 8,
    this.recommendedGoal = 8,
    this.isAutoGoal = true, // По умолчанию включено
    this.cupVolumeLiters = 0.25,
  });

  double get progress {
    if (dailyGoal == 0) return 0;
    return (consumedCups / dailyGoal).clamp(0.0, 1.0);
  }

  double get totalLiters => consumedCups * cupVolumeLiters;

  WaterState copyWith({
    WaterStatus? status,
    int? consumedCups,
    int? dailyGoal,
    int? recommendedGoal,
    bool? isAutoGoal,
    double? cupVolumeLiters,
  }) {
    return WaterState(
      status: status ?? this.status,
      consumedCups: consumedCups ?? this.consumedCups,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      recommendedGoal: recommendedGoal ?? this.recommendedGoal,
      isAutoGoal: isAutoGoal ?? this.isAutoGoal,
      cupVolumeLiters: cupVolumeLiters ?? this.cupVolumeLiters,
    );
  }

  @override
  List<Object?> get props => [status, consumedCups, dailyGoal, recommendedGoal, isAutoGoal, cupVolumeLiters];
}