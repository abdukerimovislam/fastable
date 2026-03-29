import 'package:equatable/equatable.dart';
import 'package:fastable/models/fasting_record.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

/// Старт подписки на поток данных
class SubscribeHistory extends HistoryEvent {}

/// Внутреннее событие: пришли новые данные из Stream
class HistoryUpdated extends HistoryEvent {
  final List<FastingRecord> records;
  const HistoryUpdated(this.records);
  @override
  List<Object?> get props => [records];
}

/// Удалить запись
class DeleteRecordEvent extends HistoryEvent {
  final FastingRecord record;
  const DeleteRecordEvent(this.record);
}

/// Ручное добавление (если понадобится)
class AddManualRecord extends HistoryEvent {
  final FastingRecord record;
  const AddManualRecord(this.record);
}
