/// Перечисление настроения (5 уровней)
enum FastingMood {
  terrible, // 😫
  bad,      // 😐
  neutral,  // 🙂
  good,     // 😁
  great     // 🔥
}

class FastingRecord {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String? note; // Заметка
  final FastingMood? mood; // Настроение (НОВОЕ ПОЛЕ)

  FastingRecord({
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.note,
    this.mood,
  });

  /// Метод для создания копии объекта с измененными полями
  /// (Очень полезно для редактирования истории)
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

  // Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'note': note,
    // Сохраняем имя enum'а как строку (например, "great")
    'mood': mood?.name,
  };

  // Создание из JSON
  factory FastingRecord.fromJson(Map<String, dynamic> json) {
    return FastingRecord(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(seconds: json['durationSeconds']),
      note: json['note'],
      // Восстанавливаем enum из строки. Если null или ошибка — будет null.
      mood: json['mood'] != null
          ? FastingMood.values.firstWhere(
            (e) => e.name == json['mood'],
        orElse: () => FastingMood.neutral, // На всякий случай
      )
          : null,
    );
  }
}