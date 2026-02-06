import 'dart:convert';
import 'package:flutter/foundation.dart'; // Для debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/weight_entry.dart';

@lazySingleton
class WeightRepository {
  static const String _key = 'weight_history';
  static const String _currentWeightKey = 'user_current_weight';

  /// Получить всю историю взвешиваний
  Future<List<WeightEntry>> getWeightHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => WeightEntry.fromMap(e)).toList();
    } catch (e) {
      debugPrint("❌ Error loading weight history: $e");
      // Пробрасываем ошибку, чтобы Блок знал, что данные не загрузились
      throw Exception("Failed to load weight history");
    }
  }

  /// Добавить вес
  Future<void> addWeightEntry(WeightEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Пытаемся получить текущую историю.
      // Если не вышло (ошибка парсинга), начинаем с пустого листа,
      // НО в реальном продакшене тут стоило бы спросить пользователя,
      // чтобы не перезатереть поврежденные данные.
      List<WeightEntry> history;
      try {
        history = await getWeightHistory();
      } catch (e) {
        history = [];
      }

      // Получаем строку даты "YYYY-MM-DD" для сравнения
      final entryDateString = entry.date.toIso8601String().substring(0, 10);

      // Ищем индекс записи с такой же датой
      int existingIndex = history.indexWhere((e) =>
      e.date.toIso8601String().substring(0, 10) == entryDateString);

      if (existingIndex != -1) {
        // Обновляем существующую запись
        history[existingIndex] = entry;
      } else {
        // Добавляем новую
        history.add(entry);
      }

      // Сортируем: от старых к новым
      history.sort((a, b) => a.date.compareTo(b.date));

      // Сохраняем обновленный список
      final String jsonString = jsonEncode(history.map((e) => e.toMap()).toList());
      await prefs.setString(_key, jsonString);

      // Обновляем "текущий вес"
      await prefs.setDouble(_currentWeightKey, entry.weight);

      debugPrint("✅ Weight saved: ${entry.weight} kg");
    } catch (e) {
      debugPrint("❌ Error saving weight: $e");
      throw Exception("Failed to save weight");
    }
  }

  /// Получить последний сохраненный вес
  Future<double?> getCurrentWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_currentWeightKey);
    } catch (e) {
      return null;
    }
  }

  /// Очистка истории
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      await prefs.remove(_currentWeightKey);
      debugPrint("✅ Weight history cleared");
    } catch (e) {
      debugPrint("❌ Error clearing history: $e");
    }
  }
}