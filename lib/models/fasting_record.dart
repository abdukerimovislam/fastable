import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Перечисление настроения (5 уровней)
enum FastingMood {
  terrible, // 😫
  bad, // 😐
  neutral, // 🙂
  good, // 😁
  great, // 🔥
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

  // --- 🔥 ГЛАВНОЕ ИСПРАВЛЕНИЕ: fromMap ---
  // Умеет читать и локальный JSON (String), и Firestore (Timestamp)
  factory FastingRecord.fromMap(Map<String, dynamic> map) {
    // Хелпер: Превращает String или Timestamp в DateTime
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now(); // Fallback
    }

    // Хелпер: Парсит настроение из строки
    FastingMood? parseMood(dynamic val) {
      if (val is String) {
        try {
          return FastingMood.values.firstWhere((e) => e.name == val);
        } catch (_) {}
      }
      return null;
    }

    // Логика длительности:
    // 1. Пробуем 'durationMinutes' (новый формат Firestore)
    // 2. Пробуем 'durationSeconds' (старый формат JSON)
    // 3. Вычисляем разницу между endTime и startTime
    Duration calcDuration() {
      if (map['durationMinutes'] != null) {
        return Duration(minutes: (map['durationMinutes'] as num).toInt());
      }
      if (map['durationSeconds'] != null) {
        return Duration(seconds: (map['durationSeconds'] as num).toInt());
      }
      // Если полей нет, считаем разницу дат
      final s = parseDate(map['startTime']);
      final e = parseDate(map['endTime']);
      return e.difference(s);
    }

    return FastingRecord(
      startTime: parseDate(map['startTime']),
      endTime: parseDate(map['endTime']),
      duration: calcDuration(),
      note: map['note'],
      mood: parseMood(map['mood']),
    );
  }

  // --- toMap (для сохранения) ---
  // Возвращаем примитивы для JSON и Firestore
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes':
          duration.inMinutes, // Унифицируем (минуты надежнее для истории)
      'durationSeconds':
          duration.inSeconds, // Оставляем для совместимости со старым кодом
      'note': note,
      'mood': mood?.name,
    };
  }

  // Алиасы для старого кода (если где-то используется fromJson/toJson)
  factory FastingRecord.fromJson(Map<String, dynamic> json) =>
      FastingRecord.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  @override
  List<Object?> get props => [startTime, endTime, duration, note, mood];
}
