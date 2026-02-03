import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object?> get props => [];
}

/// Команда начать отслеживать статистику
class LoadStats extends StatsEvent {}

/// Событие, когда история обновилась (нужен пересчет)
class StatsUpdated extends StatsEvent {
  // Мы можем передавать данные или просто сигнализировать
  const StatsUpdated();
}