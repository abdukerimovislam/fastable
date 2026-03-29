import 'package:equatable/equatable.dart';
import 'package:fastable/models/achievement.dart';

enum StatsStatus { initial, loading, success, failure }

class StatsState extends Equatable {
  final StatsStatus status;

  // Метрики
  final int totalFasts;
  final double totalHours;
  final int currentStreak;
  final int longestStreak;
  final double averageDuration;
  final double successRate;

  // Графики и Достижения
  final List<double> weeklyChartData;
  final double maxChartValue;
  final List<Achievement> unlockedAchievements; // <--- НОВОЕ ПОЛЕ

  const StatsState({
    this.status = StatsStatus.initial,
    this.totalFasts = 0,
    this.totalHours = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageDuration = 0.0,
    this.successRate = 0.0,
    this.weeklyChartData = const [0, 0, 0, 0, 0, 0, 0],
    this.maxChartValue = 24.0,
    this.unlockedAchievements = const [], // <--- Default
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
    List<Achievement>? unlockedAchievements,
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
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalFasts,
    totalHours,
    currentStreak,
    longestStreak,
    averageDuration,
    successRate,
    weeklyChartData,
    maxChartValue,
    unlockedAchievements,
  ];
}
