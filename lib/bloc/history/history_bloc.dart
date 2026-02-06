import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/repositories/history_repository.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;
  StreamSubscription? _historySubscription;

  HistoryBloc(this._historyRepository) : super(const HistoryState()) {
    on<SubscribeHistory>(_onSubscribeHistory);
    on<HistoryUpdated>(_onHistoryUpdated);
    on<DeleteRecordEvent>(_onDeleteRecord);
    on<AddManualRecord>(_onAddManualRecord);
  }

  Future<void> _onSubscribeHistory(SubscribeHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    await _historySubscription?.cancel();

    _historySubscription = _historyRepository.getRecordsStream().listen(
          (records) {
        add(HistoryUpdated(records));
      },
      onError: (error) {
        print("Stream error: $error");
        // Можно добавить emit(state.copyWith(status: HistoryStatus.failure));
      },
    );
  }

  Future<void> _onHistoryUpdated(HistoryUpdated event, Emitter<HistoryState> emit) async {
    final records = event.records;

    // 1. Считаем Общее время
    Duration totalTime = Duration.zero;
    for (var rec in records) {
      totalTime += rec.duration;
    }

    // 2. Считаем Среднее время
    final avgTime = records.isNotEmpty
        ? Duration(minutes: totalTime.inMinutes ~/ records.length)
        : Duration.zero;

    // 3. Считаем Стрик (асинхронно из репозитория)
    // Это гарантирует, что цифра будет совпадать с Dashboard
    int streak = 0;
    try {
      streak = await _historyRepository.calculateStreak();
    } catch (e) {
      print("Error calc streak in bloc: $e");
    }

    emit(state.copyWith(
      status: HistoryStatus.success,
      records: records,
      totalFastingTime: totalTime,
      averageDuration: avgTime,
      currentStreak: streak, // <--- Обновляем стрик
    ));
  }

  Future<void> _onDeleteRecord(DeleteRecordEvent event, Emitter<HistoryState> emit) async {
    try {
      await _historyRepository.deleteRecord(event.record);
      // Stream сам обновит состояние, ничего emit'ить не нужно
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to delete record"));
    }
  }

  Future<void> _onAddManualRecord(AddManualRecord event, Emitter<HistoryState> emit) async {
    try {
      await _historyRepository.addRecord(event.record);
      // Stream сам обновит состояние
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to add record"));
    }
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}