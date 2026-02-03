import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/weight_entry.dart'; // <--- Импортируем единую модель

@lazySingleton
class WeightRepository {
  static const String _key = 'weight_history';
  static const String _currentWeightKey = 'user_current_weight';

  /// Получить всю историю взвешиваний
  Future<List<WeightEntry>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      // Используем fromMap из нашей модели WeightEntry
      return jsonList.map((e) => WeightEntry.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Добавить вес (Метод, который вызывает BLoC)
  /// Логика: Если запись за эту дату уже есть, обновляем её. Иначе добавляем новую.
  Future<void> addWeightEntry(WeightEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<WeightEntry> history = await getWeightHistory();

    // Получаем строку даты "YYYY-MM-DD" для сравнения
    final entryDateString = entry.date.toIso8601String().substring(0, 10);

    // Ищем индекс записи с такой же датой
    int existingIndex = history.indexWhere((e) =>
    e.date.toIso8601String().substring(0, 10) == entryDateString);

    if (existingIndex != -1) {
      // Обновляем существующую запись (сохраняя ID если он был, или заменяя данные)
      history[existingIndex] = entry;
    } else {
      // Добавляем новую
      history.add(entry);
    }

    // Сортируем: от старых к новым (для корректного отображения на графиках)
    history.sort((a, b) => a.date.compareTo(b.date));

    // Сохраняем обновленный список
    final String jsonString = jsonEncode(history.map((e) => e.toMap()).toList());
    await prefs.setString(_key, jsonString);

    // Обновляем "текущий вес" (для быстрого доступа в UI без парсинга всей истории)
    await prefs.setDouble(_currentWeightKey, entry.weight);
  }

  /// Получить последний сохраненный вес (быстрый доступ)
  Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }

  /// Очистка истории (для дебага или сброса аккаунта)
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_currentWeightKey);
  }
}