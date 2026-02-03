import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';


class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
    );
  }
}
@lazySingleton
class WeightRepository {
  static const String _key = 'weight_history';
  static const String _currentWeightKey = 'user_current_weight';

  // Сохранить новый вес (простой метод, добавляет всегда новую запись)
  Future<void> addWeight(double weight) async {
    await addWeightOrUpdateToday(weight);
  }

  // ИСПРАВЛЕНО: Умное добавление - обновляет запись, если она уже есть за сегодня
  Future<void> addWeightOrUpdateToday(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    List<WeightRecord> history = await getWeightHistory();

    final now = DateTime.now();
    final todayString = now.toIso8601String().substring(0, 10); // "2023-10-25"

    // Ищем, есть ли запись за сегодня
    int todayIndex = -1;
    for (int i = 0; i < history.length; i++) {
      final recordDateString = history[i].date.toIso8601String().substring(0, 10);
      if (recordDateString == todayString) {
        todayIndex = i;
        break;
      }
    }

    if (todayIndex != -1) {
      // Обновляем существующую
      history[todayIndex] = WeightRecord(date: now, weight: weight);
    } else {
      // Добавляем новую
      history.add(WeightRecord(date: now, weight: weight));
    }

    // Сортируем
    history.sort((a, b) => a.date.compareTo(b.date));

    // Сохраняем
    final String jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);

    // Обновляем текущий вес
    await prefs.setDouble(_currentWeightKey, weight);
  }

  // Получить всю историю
  Future<List<WeightRecord>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => WeightRecord.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Получить последний вес
  Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }
}