class FastingRecord {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String? note; // Заметка (опционально)

  FastingRecord({
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.note,
  });

  // Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationSeconds': duration.inSeconds,
    'note': note,
  };

  // Создание из JSON
  factory FastingRecord.fromJson(Map<String, dynamic> json) {
    return FastingRecord(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(seconds: json['durationSeconds']),
      note: json['note'],
    );
  }
}