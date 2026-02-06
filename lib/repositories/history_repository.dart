import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Для compute
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/fasting_record.dart';

@lazySingleton
class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _localKey = 'fasting_history_v2';

  // Контроллер потока
  final _recordsController = StreamController<List<FastingRecord>>.broadcast();

  // Конструктор: Загружаем данные один раз при создании репозитория
  HistoryRepository() {
    _loadInitialData();
  }

  /// 🔹 1. ПОТОК (Только отдает stream, никакой логики)
  Stream<List<FastingRecord>> get recordsStream => _recordsController.stream;

  // Для совместимости со старым кодом, если где-то вызывается как метод
  Stream<List<FastingRecord>> getRecordsStream() => _recordsController.stream;

  /// Первичная загрузка (фоновая)
  Future<void> _loadInitialData() async {
    // Сначала быстро показываем локальные данные
    final local = await _getLocalRecords();
    if (!_recordsController.isClosed) _recordsController.add(local);

    // Потом обновляем из облака
    await getAllRecords();
  }

  // --- 2. ПОЛУЧЕНИЕ ДАННЫХ (HYBRID) ---
  Future<List<FastingRecord>> getAllRecords() async {
    final user = _auth.currentUser;

    // A. Онлайн -> Облако
    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('fasting_history')
            .orderBy('startTime', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Парсим в изоляте (чтобы не фризило UI при большом списке)
          final cloudList = await compute(_parseFirestoreData, snapshot.docs);

          // Обновляем локальный кэш
          await _saveToLocal(cloudList);

          if (!_recordsController.isClosed) {
            _recordsController.add(cloudList);
          }
          return cloudList;
        }
      } catch (e) {
        debugPrint("⚠️ History sync failed, using local: $e");
      }
    }

    // B. Офлайн -> Локально
    final local = await _getLocalRecords();
    if (!_recordsController.isClosed) _recordsController.add(local);
    return local;
  }

  // --- 3. ДОБАВЛЕНИЕ (ADD) ---
  Future<void> addRecord(FastingRecord record) async {
    // Локально (мгновенно)
    final records = await _getLocalRecords();
    records.insert(0, record);
    records.sort((a, b) => b.startTime.compareTo(a.startTime));

    await _saveToLocal(records);
    if (!_recordsController.isClosed) _recordsController.add(records);

    // Облако (фоном)
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docId = record.startTime.millisecondsSinceEpoch.toString();
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('fasting_history')
            .doc(docId)
            .set({
          ...record.toMap(),
          'startTime': Timestamp.fromDate(record.startTime),
          'endTime': Timestamp.fromDate(record.endTime),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("❌ Sync error: $e");
      }
    }
  }

  // --- 4. УДАЛЕНИЕ (DELETE) ---
  Future<void> deleteRecord(FastingRecord record) async {
    final records = await _getLocalRecords();
    records.removeWhere((r) => r.startTime.isAtSameMomentAs(record.startTime));

    await _saveToLocal(records);
    if (!_recordsController.isClosed) _recordsController.add(records);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docId = record.startTime.millisecondsSinceEpoch.toString();
        await _db.collection('users').doc(user.uid).collection('fasting_history').doc(docId).delete();
      } catch (e) {
        debugPrint("❌ Delete error: $e");
      }
    }
  }

  // --- 5. СТРИК ---
  Future<int> calculateStreak() async {
    final records = await _getLocalRecords();
    if (records.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    final lastEnd = records.first.endTime;
    final lastEndDate = DateTime(lastEnd.year, lastEnd.month, lastEnd.day);

    if (lastEndDate.isBefore(checkDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    checkDate = lastEndDate;
    final uniqueDays = records.map((r) {
      final d = r.endTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    while (uniqueDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // --- 6. MIGRATION & CLEAR ---
  Future<void> migrateLocalToCloud(String uid) async {
    final localData = await _getLocalRecords();
    if (localData.isEmpty) return;

    final batch = _db.batch();
    for (var record in localData) {
      final docId = record.startTime.millisecondsSinceEpoch.toString();
      final ref = _db.collection('users').doc(uid).collection('fasting_history').doc(docId);
      batch.set(ref, {
        ...record.toMap(),
        'startTime': Timestamp.fromDate(record.startTime),
        'endTime': Timestamp.fromDate(record.endTime),
        'migratedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    if (!_recordsController.isClosed) _recordsController.add([]);

    final user = _auth.currentUser;
    if (user != null) {
      final batch = _db.batch();
      final snap = await _db.collection('users').doc(user.uid).collection('fasting_history').get();
      for (var doc in snap.docs) batch.delete(doc.reference);
      await batch.commit();
    }
  }

  // --- HELPERS (Оптимизация: работаем в compute если нужно) ---

  Future<List<FastingRecord>> _getLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localKey);
    if (jsonString == null) return [];

    // Если записей очень много, JSON декодинг может фризить.
    // Для >1000 записей лучше использовать compute, но пока оставим так для скорости.
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => FastingRecord.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveToLocal(List<FastingRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    // JSON encode тоже может быть тяжелым
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }
}

// ⚡️ ВЫНОСИМ ТЯЖЕЛУЮ ФУНКЦИЮ ИЗ КЛАССА (для compute)
// Это предотвратит фризы при парсинге большого ответа от Firebase
List<FastingRecord> _parseFirestoreData(List<QueryDocumentSnapshot> docs) {
  return docs.map((doc) {
    return FastingRecord.fromMap(doc.data() as Map<String, dynamic>);
  }).toList();
}