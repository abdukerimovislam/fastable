import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord({required this.date, required this.weight});

  // Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weight': weight,
  };

  // Создание из JSON
  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

class WeightRepository {
  static const String _key = 'weight_history';

  // Сохранить новый вес
  Future<void> addWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getWeightHistory();

    // Добавляем новую запись
    history.add(WeightRecord(date: DateTime.now(), weight: weight));

    // Сортируем по дате (на всякий случай)
    history.sort((a, b) => a.date.compareTo(b.date));

    // Сохраняем список обратно
    final String jsonString = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);

    // Также обновляем "текущий вес" для быстрого доступа
    await prefs.setDouble('user_current_weight', weight);
  }

  // Получить всю историю
  Future<List<WeightRecord>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => WeightRecord.fromJson(e)).toList();
  }

  // Получить последний вес
  Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_current_weight');
  }
}