import 'package:equatable/equatable.dart';
import 'package:fastable/models/fasting_record.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<FastingRecord> records;
  final String? errorMessage;

  // Статистика (теперь это поля, которые заполняет Bloc)
  final Duration totalFastingTime;
  final Duration averageDuration;
  final int currentStreak;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.records = const [],
    this.errorMessage,
    this.totalFastingTime = Duration.zero,
    this.averageDuration = Duration.zero,
    this.currentStreak = 0,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<FastingRecord>? records,
    String? errorMessage,
    Duration? totalFastingTime,
    Duration? averageDuration,
    int? currentStreak,
  }) {
    return HistoryState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: errorMessage ?? this.errorMessage,
      totalFastingTime: totalFastingTime ?? this.totalFastingTime,
      averageDuration: averageDuration ?? this.averageDuration,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  @override
  List<Object?> get props => [
    status,
    records,
    errorMessage,
    totalFastingTime,
    averageDuration,
    currentStreak,
  ];
}