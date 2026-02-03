import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/bloc/stats/stats_event.dart';
import 'package:fastable/bloc/stats/stats_state.dart';
import 'package:fastable/repositories/history_repository.dart';

@injectable
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final HistoryRepository _historyRepository;
  StreamSubscription? _historySubscription;

  StatsBloc(this._historyRepository) : super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
    on<StatsUpdated>(_onStatsUpdated);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    await _historySubscription?.cancel();
    // Подписываемся на поток истории
    _historySubscription = _historyRepository.getRecordsStream().listen((records) {
      add(const StatsUpdated());
    });
  }

  Future<void> _onStatsUpdated(StatsUpdated event, Emitter<StatsState> emit) async {
    // Берем свежие данные
    final records = await _historyRepository.getRecordsStream().first;

    if (records.isEmpty) {
      emit(state.copyWith(status: StatsStatus.success));
      return;
    }

    // --- МАТЕМАТИКА ---
    final totalFasts = records.length;
    final totalDuration = records.fold(Duration.zero, (prev, e) => prev + e.duration);
    final totalHours = totalDuration.inMinutes / 60.0; // Более точно через минуты
    final avgHours = totalFasts > 0 ? totalHours / totalFasts : 0.0;

    // Success Rate (считаем успешным, если > 16 часов)
    // Можно сделать настройку, но пока хардкод 16ч как "золотой стандарт"
    final successCount = records.where((r) => r.duration.inHours >= 16).length;
    final successRate = totalFasts > 0 ? (successCount / totalFasts) * 100 : 0.0;

    // График (7 дней)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(const Duration(days: 6));

    List<double> chartData = List.filled(7, 0.0);
    double maxVal = 0;

    for (var record in records) {
      if (record.endTime.isBefore(startOfWeek)) continue;
      final diff = record.endTime.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7) {
        chartData[diff] += record.duration.inMinutes / 60.0;
      }
    }

    // Масштаб графика
    if (chartData.isNotEmpty) {
      maxVal = chartData.reduce((curr, next) => curr > next ? curr : next);
    }
    if (maxVal < 12) maxVal = 12;
    if (maxVal > 24) maxVal += 4;

    // Стрики
    Set<String> activeDays = {};
    for (var r in records) {
      activeDays.add(r.endTime.toIso8601String().substring(0, 10));
    }

    int currentStreak = 0;
    DateTime checkDate = today;
    while (true) {
      String key = checkDate.toIso8601String().substring(0, 10);
      if (activeDays.contains(key)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate == today && currentStreak == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    // Обновляем состояние
    emit(state.copyWith(
      status: StatsStatus.success,
      totalFasts: totalFasts,
      totalHours: totalHours,
      averageDuration: avgHours,
      successRate: successRate, // <--- Передаем
      currentStreak: currentStreak,
      longestStreak: currentStreak, // Пока упрощенно
      weeklyChartData: chartData,
      maxChartValue: maxVal,
    ));
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}