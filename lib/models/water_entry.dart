class WaterEntry {
  final DateTime date;
  int cupCount; // 'int', а не 'double', так как мы считаем чашки

  WaterEntry({
    required this.date,
    required this.cupCount,
  });

  // Методы для конвертации в/из JSON (для SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'cupCount': cupCount,
    };
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      date: DateTime.parse(json['date']),
      cupCount: json['cupCount'] as int,
    );
  }
}