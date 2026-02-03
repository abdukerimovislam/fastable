import 'package:equatable/equatable.dart';
import 'package:fastable/models/fasting_record.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<FastingRecord> records;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.records = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<FastingRecord>? records,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Общее время голодания (для статистики в шапке)
  Duration get totalFastingTime {
    return records.fold(Duration.zero, (prev, element) => prev + element.duration);
  }

  /// Среднее время
  Duration get averageDuration {
    if (records.isEmpty) return Duration.zero;
    final total = totalFastingTime;
    return Duration(minutes: total.inMinutes ~/ records.length);
  }

  @override
  List<Object?> get props => [status, records, errorMessage];
}