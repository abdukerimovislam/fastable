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

    // Отменяем старую подписку, если была
    await _historySubscription?.cancel();

    // Подписываемся на поток из репозитория
    _historySubscription = _historyRepository.getRecordsStream().listen(
          (records) {
        add(HistoryUpdated(records));
      },
      onError: (error) {
        // Можно обработать ошибку
        print("Stream error: $error");
      },
    );
  }

  Future<void> _onHistoryUpdated(HistoryUpdated event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(
      status: HistoryStatus.success,
      records: event.records,
    ));
  }

  Future<void> _onDeleteRecord(DeleteRecordEvent event, Emitter<HistoryState> emit) async {
    // Удаляем оптимистично или ждем потока
    // Поскольку у нас Stream, удаление в репозитории само триггернет обновление списка
    try {
      await _historyRepository.deleteRecord(event.record);
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _onAddManualRecord(AddManualRecord event, Emitter<HistoryState> emit) async {
    try {
      await _historyRepository.addRecord(event.record);
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: "Failed to add record"));
    }
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}