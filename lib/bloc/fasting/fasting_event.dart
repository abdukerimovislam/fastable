import 'package:equatable/equatable.dart';

abstract class FastingEvent extends Equatable {
  const FastingEvent();

  @override
  List<Object?> get props => [];
}

/// Приложение запустилось или вышло из фона
class CheckFastingState extends FastingEvent {}

/// Пользователь нажал "Start Fasting"
class StartFasting extends FastingEvent {}

/// Пользователь нажал "End Fasting" (раньше времени или вовремя)
class EndFasting extends FastingEvent {
  final bool isManual; // true если прервал руками
  const EndFasting({this.isManual = true});
}

/// Пользователь нажал "End Eating" (начать новый цикл)
class EndEatingWindow extends FastingEvent {}

/// Сработал тик таймера (каждую секунду)
class TickTimer extends FastingEvent {
  final Duration elapsed;
  const TickTimer(this.elapsed);
}

/// Пользователь сменил план (16:8 -> 18:6)
class ChangePlan extends FastingEvent {
  final int planIndex;
  const ChangePlan(this.planIndex);
}

/// Сброс всего (Reset)
class ResetFasting extends FastingEvent {}