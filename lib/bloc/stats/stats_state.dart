import 'package:equatable/equatable.dart';

enum StatsStatus { initial, loading, success, failure }

class StatsState extends Equatable {
  final StatsStatus status;

  // Метрики
  final int totalFasts;
  final double totalHours;
  final int currentStreak;
  final int longestStreak;
  final double averageDuration;
  final double successRate; // <--- ДОБАВИЛИ (0..100)

  // Графики
  final List<double> weeklyChartData;
  final double maxChartValue;

  const StatsState({
    this.status = StatsStatus.initial,
    this.totalFasts = 0,
    this.totalHours = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageDuration = 0.0,
    this.successRate = 0.0, // Default
    this.weeklyChartData = const [0,0,0,0,0,0,0],
    this.maxChartValue = 24.0,
  });

  StatsState copyWith({
    StatsStatus? status,
    int? totalFasts,
    double? totalHours,
    int? currentStreak,
    int? longestStreak,
    double? averageDuration,
    double? successRate,
    List<double>? weeklyChartData,
    double? maxChartValue,
  }) {
    return StatsState(
      status: status ?? this.status,
      totalFasts: totalFasts ?? this.totalFasts,
      totalHours: totalHours ?? this.totalHours,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      averageDuration: averageDuration ?? this.averageDuration,
      successRate: successRate ?? this.successRate,
      weeklyChartData: weeklyChartData ?? this.weeklyChartData,
      maxChartValue: maxChartValue ?? this.maxChartValue,
    );
  }

  @override
  List<Object?> get props => [status, totalFasts, totalHours, currentStreak, longestStreak, averageDuration, successRate, weeklyChartData, maxChartValue];
}