import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/models/fasting_record.dart';

class HistoryRepository {
  static const String _key = 'fasting_history_records';

  // Получить все записи
  Future<List<FastingRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => FastingRecord.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Добавить запись
  Future<void> addRecord(FastingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FastingRecord> currentRecords = await loadRecords();

    currentRecords.add(record);

    // Сортируем: новые сверху
    currentRecords.sort((a, b) => b.startTime.compareTo(a.startTime));

    final String jsonString = jsonEncode(currentRecords.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // Удалить запись (на будущее)
  Future<void> deleteRecord(FastingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FastingRecord> currentRecords = await loadRecords();

    // Удаляем по совпадению времени начала
    currentRecords.removeWhere((e) => e.startTime == record.startTime);

    final String jsonString = jsonEncode(currentRecords.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}