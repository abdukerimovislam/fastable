import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final String? id;
  final DateTime date;
  final double weight;
  final String? note;

  const WeightEntry({
    this.id,
    required this.date,
    required this.weight,
    this.note,
  });

  // --- SERIALIZATION ---

  /// Преобразование в Map (для сохранения в SharedPreferences/DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'note': note,
    };
  }

  /// Алиас для автоматической сериализации (jsonEncode)
  Map<String, dynamic> toJson() => toMap();

  /// Безопасное создание из Map
  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    // 1. Безопасная дата
    DateTime parsedDate;
    if (map['date'] != null) {
      parsedDate = DateTime.tryParse(map['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    // 2. Безопасный вес (с поддержкой int и double)
    double parsedWeight = 0.0;
    if (map['weight'] != null) {
      parsedWeight = (map['weight'] as num).toDouble();
    }

    return WeightEntry(
      id: map['id'] as String?,
      date: parsedDate,
      weight: parsedWeight,
      note: map['note'] as String?,
    );
  }

  /// Алиас для fromJson
  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry.fromMap(json);

  // --- EQUATABLE ---
  // Это критически важно для BLoC: если props одинаковые, стейт не перерисовывается лишний раз
  @override
  List<Object?> get props => [id, date, weight, note];
}