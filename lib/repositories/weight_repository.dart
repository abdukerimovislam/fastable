import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/weight_entry.dart';

@lazySingleton
class WeightRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _localKey = 'weight_history';
  static const String _currentWeightKey = 'user_current_weight';

  // --- 1. ПОЛУЧЕНИЕ ИСТОРИИ (HYBRID + SMART MERGE) ---
  Future<List<WeightEntry>> getWeightHistory() async {
    // Сначала читаем локальные данные
    final localList = await _getLocalHistory();
    final user = _auth.currentUser;

    // A. Если онлайн -> берем из облака и сливаем
    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .orderBy('date', descending: false) // Старые -> Новые
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs.map((doc) {
            // Модель сама разберется с Timestamp
            return WeightEntry.fromMap(doc.data());
          }).toList();

          // 🔥 ИСПРАВЛЕНИЕ: Безопасное слияние (Merge) вместо перезаписи
          final Map<String, WeightEntry> mergedMap = {};

          // 1. Заливаем облачные данные
          for (var entry in cloudList) {
            mergedMap[entry.date.toIso8601String().substring(0, 10)] = entry;
          }

          // 2. Накладываем локальные данные (Они приоритетнее, т.к. могли быть добавлены оффлайн)
          for (var entry in localList) {
            mergedMap[entry.date.toIso8601String().substring(0, 10)] = entry;
          }

          final mergedList = mergedMap.values.toList();
          mergedList.sort((a, b) => a.date.compareTo(b.date));

          // Обновляем локальный кэш
          await _saveToLocal(mergedList);

          // Обновляем текущий вес (последняя запись)
          if (mergedList.isNotEmpty) {
            await _saveCurrentWeightLocal(mergedList.last.weight);
          }
          return mergedList;
        }
      } catch (e) {
        debugPrint("⚠️ Cloud fetch failed (using local): $e");
      }
    }

    // B. Если офлайн или облако пустое -> берем локально
    return localList;
  }

  // --- 2. ДОБАВЛЕНИЕ (SYNC) ---
  Future<void> addWeightEntry(WeightEntry entry) async {
    final user = _auth.currentUser;
    try {
      // 1. Локально (Мгновенно)
      List<WeightEntry> history = await _getLocalHistory();
      _updateList(history, entry); // Хелпер обновления списка
      await _saveToLocal(history);
      await _saveCurrentWeightLocal(entry.weight);

      // 2. Облако (Фон)
      if (user != null) {
        final docId = entry.date.toIso8601String().substring(0, 10); // YYYY-MM-DD
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .doc(docId)
            .set({
          ...entry.toMap(),
          'date': Timestamp.fromDate(entry.date), // Firestore Timestamp
        });
        debugPrint("☁️ Weight synced to cloud");
      }
    } catch (e) {
      debugPrint("❌ Error saving weight: $e");
      throw Exception("Failed to save weight");
    }
  }

  // --- 3. GET CURRENT WEIGHT ---
  Future<double?> getCurrentWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_currentWeightKey);
    } catch (e) {
      return null;
    }
  }

  // --- 4. CLEAR ALL (GDPR) ---
  Future<void> clearAllData() async {
    // Локально
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    await prefs.remove(_currentWeightKey);

    // Облако
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final batch = _db.batch();
        final col = _db.collection('users').doc(user.uid).collection('weight_history');
        var snaps = await col.get();
        for (var doc in snaps.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint("🔥 Cloud weight data cleared");
      } catch (e) {
        debugPrint("Error deleting cloud data: $e");
        rethrow;
      }
    }
  }

  // --- 5. КОНФЛИКТЫ И МИГРАЦИЯ ---

  Future<bool> hasLocalData() async {
    final list = await _getLocalHistory();
    return list.isNotEmpty;
  }

  Future<bool> hasCloudData(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 🚀 MIGRATE (Local -> Cloud)
  /// Вызывается при входе (AuthService), если нет конфликтов
  Future<void> migrateLocalToCloud(String uid) async {
    final localData = await _getLocalHistory();
    if (localData.isEmpty) return;

    debugPrint("🚀 Migrating ${localData.length} weight entries...");
    final batch = _db.batch();

    for (var entry in localData) {
      final docId = entry.date.toIso8601String().substring(0, 10);
      final ref = _db.collection('users').doc(uid).collection('weight_history').doc(docId);

      batch.set(ref, {
        ...entry.toMap(),
        'date': Timestamp.fromDate(entry.date),
      });
    }
    await batch.commit();
    debugPrint("✅ Weight migration complete");
  }

  /// 🔄 MERGE (Local + Cloud)
  /// Сливаем данные. При совпадении дат приоритет у локальных (свежих).
  Future<void> mergeLocalToCloud(String uid) async {
    debugPrint("🔄 Start Merging Weight Data...");

    // 1. Локальные
    final localData = await _getLocalHistory();

    // 2. Облачные
    List<WeightEntry> cloudData = [];
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('weight_history').get();
      cloudData = snapshot.docs.map((doc) => WeightEntry.fromMap(doc.data())).toList();
    } catch (_) {}

    // 3. Объединяем (Map для дедупликации по дате YYYY-MM-DD)
    final Map<String, WeightEntry> mergedMap = {};

    // Сначала кладем облачные
    for (var entry in cloudData) {
      final key = entry.date.toIso8601String().substring(0, 10);
      mergedMap[key] = entry;
    }

    // Накладываем локальные (перезаписываем, если день совпадает)
    for (var entry in localData) {
      final key = entry.date.toIso8601String().substring(0, 10);
      mergedMap[key] = entry;
    }

    final mergedList = mergedMap.values.toList();
    mergedList.sort((a, b) => a.date.compareTo(b.date));

    // 4. Заливаем итог в облако
    final batch = _db.batch();
    for (var entry in mergedList) {
      final docId = entry.date.toIso8601String().substring(0, 10);
      final ref = _db.collection('users').doc(uid).collection('weight_history').doc(docId);
      batch.set(ref, {
        ...entry.toMap(),
        'date': Timestamp.fromDate(entry.date),
      });
    }
    await batch.commit();

    // 5. Обновляем локально
    await _saveToLocal(mergedList);
    if (mergedList.isNotEmpty) {
      await _saveCurrentWeightLocal(mergedList.last.weight);
    }

    debugPrint("✅ Data Merged Successfully");
  }

  /// 🗑 DISCARD LOCAL
  Future<void> discardLocalAndUseCloud(String uid) async {
    debugPrint("🗑 Discarding local weight data...");
    // Просто вызываем getWeightHistory - он сам подтянет облако и перезапишет локальный кэш
    await getWeightHistory();
  }

  // --- HELPERS ---

  Future<List<WeightEntry>> _getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => WeightEntry.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveToLocal(List<WeightEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }

  Future<void> _saveCurrentWeightLocal(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentWeightKey, weight);
  }

  void _updateList(List<WeightEntry> history, WeightEntry entry) {
    final entryDateString = entry.date.toIso8601String().substring(0, 10);
    int existingIndex = history.indexWhere((e) =>
    e.date.toIso8601String().substring(0, 10) == entryDateString);

    if (existingIndex != -1) {
      history[existingIndex] = entry;
    } else {
      history.add(entry);
    }
    history.sort((a, b) => a.date.compareTo(b.date));
  }
}