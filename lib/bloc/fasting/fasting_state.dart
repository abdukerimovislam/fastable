import 'package:equatable/equatable.dart';

enum FastingPhase { stopped, fasting, eating }

class FastingState extends Equatable {
  final FastingPhase phase;
  final DateTime? startTime;
  final Duration elapsed;
  final Duration goalDuration; // Длительность текущей фазы (16ч или 8ч)
  final int planIndex; // Индекс пресета. Если -1, значит выбран кастомный план.
  final bool isGoalReached; // Достигли ли цели (для галочки или уведомления)

  // 🔥 Константа для обозначения кастомного плана в коде
  static const int customPlanIndex = -1;

  const FastingState({
    this.phase = FastingPhase.stopped,
    this.startTime,
    this.elapsed = Duration.zero,
    this.goalDuration = const Duration(hours: 16),
    this.planIndex = 0,
    this.isGoalReached = false,
  });

  /// Прогресс от 0.0 до 1.0
  double get progress {
    if (goalDuration.inSeconds == 0) return 0;
    return (elapsed.inSeconds / goalDuration.inSeconds).clamp(0.0, 1.0);
  }

  /// Оставшееся время
  Duration get remaining {
    final left = goalDuration - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// Проверка: является ли текущий план кастомным
  bool get isCustomPlan => planIndex == customPlanIndex;

  FastingState copyWith({
    FastingPhase? phase,
    DateTime? startTime,
    Duration? elapsed,
    Duration? goalDuration,
    int? planIndex,
    bool? isGoalReached,
  }) {
    return FastingState(
      phase: phase ?? this.phase,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      goalDuration: goalDuration ?? this.goalDuration,
      planIndex: planIndex ?? this.planIndex,
      isGoalReached: isGoalReached ?? this.isGoalReached,
    );
  }

  @override
  List<Object?> get props => [phase, startTime, elapsed, goalDuration, planIndex, isGoalReached];
}