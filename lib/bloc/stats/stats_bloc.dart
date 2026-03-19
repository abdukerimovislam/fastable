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
    _historySubscription = _historyRepository.getRecordsStream().listen((records) {
      add(const StatsUpdated());
    });
  }

  Future<void> _onStatsUpdated(StatsUpdated event, Emitter<StatsState> emit) async {
    // 🔥 ИСПРАВЛЕНИЕ 1: Читаем синхронный кэш, избегая Race Conditions
    final records = _historyRepository.currentRecords;

    if (records.isEmpty) {
      emit(state.copyWith(status: StatsStatus.success));
      return;
    }

    // --- МАТЕМАТИКА ---
    final totalFasts = records.length;
    final totalDuration = records.fold(Duration.zero, (prev, e) => prev + e.duration);
    final totalHours = totalDuration.inMinutes / 60.0;
    final avgHours = totalFasts > 0 ? totalHours / totalFasts : 0.0;

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

    if (chartData.isNotEmpty) {
      maxVal = chartData.reduce((curr, next) => curr > next ? curr : next);
    }
    if (maxVal < 12) maxVal = 12;
    if (maxVal > 24) maxVal += 4;

    // 🔥 ИСПРАВЛЕНИЕ 2: Используем единый источник правды для текущего стрика
    final currentStreak = _historyRepository.calculateStreak();

    // 🔥 ИСПРАВЛЕНИЕ 3: Честный подсчет Максимального стрика (Longest Streak)
    int longestStreak = 0;
    int tempStreak = 0;
    final uniqueDays = records.map((r) => DateTime(r.endTime.year, r.endTime.month, r.endTime.day)).toSet().toList();
    uniqueDays.sort((a, b) => b.compareTo(a)); // От новых к старым

    if (uniqueDays.isNotEmpty) {
      tempStreak = 1;
      longestStreak = 1;
      for (int i = 0; i < uniqueDays.length - 1; i++) {
        if (uniqueDays[i].difference(uniqueDays[i+1]).inDays == 1) {
          tempStreak++;
          if (tempStreak > longestStreak) longestStreak = tempStreak;
        } else {
          tempStreak = 1;
        }
      }
    }

    emit(state.copyWith(
      status: StatsStatus.success,
      totalFasts: totalFasts,
      totalHours: totalHours,
      averageDuration: avgHours,
      successRate: successRate,
      currentStreak: currentStreak,
      longestStreak: longestStreak, // Честные данные
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