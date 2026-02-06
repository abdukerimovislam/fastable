import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WaterEntry extends Equatable {
  final DateTime date;
  final int cupCount;

  const WaterEntry({
    required this.date,
    required this.cupCount,
  });

  /// Универсальный конструктор (JSON + Firestore)
  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return WaterEntry(
      date: parseDate(map['date']),
      cupCount: (map['cupCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(), // Сохраняем как строку для JSON
      'cupCount': cupCount,
    };
  }

  // Алиасы для старого кода
  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  @override
  List<Object?> get props => [date, cupCount];
}