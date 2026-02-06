import 'package:equatable/equatable.dart';
import 'package:fastable/models/fasting_record.dart'; // Импорт enum

abstract class FastingEvent extends Equatable {
  const FastingEvent();

  @override
  List<Object?> get props => [];
}

/// Приложение запустилось или вышло из фона
class CheckFastingState extends FastingEvent {}

/// Пользователь нажал "Start Fasting"
class StartFasting extends FastingEvent {
  // Если null, значит старт "сейчас". Если передано значение — это ручной выбор времени.
  final DateTime? startTime;

  const StartFasting({this.startTime});

  @override
  List<Object?> get props => [startTime];
}

/// Пользователь нажал "End Fasting" (завершил голодание)
class EndFasting extends FastingEvent {
  final bool isManual; // true если прервал руками
  final FastingMood? mood;
  // Если null, значит конец "сейчас". Если передано значение — ручной выбор.
  final DateTime? endTime;

  const EndFasting({
    this.isManual = true,
    this.endTime,
    this.mood,
  });

  @override
  List<Object?> get props => [isManual, endTime, mood];
}

/// Пользователь нажал "End Eating" (завершил окно еды -> начать новый цикл голодания)
class EndEatingWindow extends FastingEvent {
  // Добавили возможность передать время, если пользователь забыл нажать кнопку вовремя
  final DateTime? endTime;

  const EndEatingWindow({this.endTime});

  @override
  List<Object?> get props => [endTime];
}

/// Сработал тик таймера (каждую секунду)
class TickTimer extends FastingEvent {
  final Duration elapsed;
  const TickTimer(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

/// Пользователь сменил план из пресетов (16:8 -> 18:6)
class ChangePlan extends FastingEvent {
  final int planIndex;
  const ChangePlan(this.planIndex);

  @override
  List<Object?> get props => [planIndex];
}

/// 🔥 НОВОЕ: Пользователь задал кастомную цель вручную (например, 23 часа)
class SetCustomPlan extends FastingEvent {
  final int targetHours;
  const SetCustomPlan(this.targetHours);

  @override
  List<Object?> get props => [targetHours];
}

/// Сброс всего (Reset)
class ResetFasting extends FastingEvent {}