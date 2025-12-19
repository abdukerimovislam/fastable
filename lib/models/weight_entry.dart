class WeightEntry {
  final String? id;
  final DateTime date;
  final double weight;

  WeightEntry({
    this.id,
    required this.date,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    // 1. Безопасное получение даты
    DateTime parsedDate;
    if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now(); // Если даты нет, берем текущую
    }

    // 2. Безопасное получение веса
    double parsedWeight = 0.0;
    if (json['weight'] != null) {
      parsedWeight = (json['weight'] as num).toDouble();
    }

    return WeightEntry(
      id: id,
      date: parsedDate,
      weight: parsedWeight,
    );
  }
}