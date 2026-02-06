import 'package:equatable/equatable.dart';

/// Перечисление настроения (5 уровней)
enum FastingMood {
  terrible, // 😫
  bad,      // 😐
  neutral,  // 🙂
  good,     // 😁
  great     // 🔥
}

class FastingRecord extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String? note; // Заметка
  final FastingMood? mood; // Настроение

  const FastingRecord({
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.note,
    this.mood,
  });

  /// Метод для создания копии объекта с измененными полями
  FastingRecord copyWith({
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? note,
    FastingMood? mood,
  }) {
    return FastingRecord(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      note: note ?? this.note,
      mood: mood ?? this.mood,
    );
  }

  // Преобразование в JSON (для сохранения локально или в файл)
  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'note': note,
    'mood': mood?.name, // Сохраняем как строку 'good', 'bad' и т.д.
  };

  // Создание из JSON
  factory FastingRecord.fromJson(Map<String, dynamic> json) {
    return FastingRecord(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(seconds: json['durationSeconds']),
      note: json['note'],
      // Безопасное восстановление настроения
      mood: json['mood'] != null
          ? FastingMood.values.firstWhere(
            (e) => e.name == json['mood'],
        orElse: () => FastingMood.neutral, // Если база данных сломалась, ставим нейтрально
      )
          : null,
    );
  }

  @override
  List<Object?> get props => [startTime, endTime, duration, note, mood];
}