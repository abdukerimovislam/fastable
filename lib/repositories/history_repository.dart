import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  // Кэш текущих записей
  List<FastingRecord> _currentRecords = [];

  // Конструктор: Загружаем данные один раз при создании репозитория
  HistoryRepository() {
    _loadInitialData();
  }

  // 🔥 ИСПРАВЛЕНИЕ 1: Решаем проблему пустого экрана (Race Condition).
  // Используем async* чтобы моментально отдать текущий кэш любому новому подписчику (Bloc'у),
  // а затем уже транслировать новые фоновые события из контроллера.
  Stream<List<FastingRecord>> getRecordsStream() async* {
    yield _currentRecords;
    yield* _recordsController.stream;
  }

  /// Актуальный список без подписки
  List<FastingRecord> get currentRecords => List.unmodifiable(_currentRecords);

  /// Очистка ресурсов
  @disposeMethod
  void dispose() {
    _recordsController.close();
  }

  /// Первичная загрузка (фоновая)
  Future<void> _loadInitialData() async {
    // Сначала быстро показываем локальные данные
    final local = await _getLocalRecords();
    _updateStream(local);

    // Потом обновляем из облака
    await getAllRecords();
  }

  // --- 2. ПОЛУЧЕНИЕ ДАННЫХ (HYBRID) ---
  Future<List<FastingRecord>> getAllRecords() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .collection('fasting_history')
            .orderBy('startTime', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs.map((doc) {
            final data = doc.data();

            if (data['startTime'] is Timestamp) {
              data['startTime'] = (data['startTime'] as Timestamp).toDate().toIso8601String();
            }
            if (data['endTime'] is Timestamp) {
              data['endTime'] = (data['endTime'] as Timestamp).toDate().toIso8601String();
            }

            return FastingRecord.fromMap(data);
          }).toList();

          await _saveToLocal(cloudList);
          _updateStream(cloudList);

          return cloudList;
        }
      } catch (e) {
        debugPrint("⚠️ History sync failed, using local: $e");
      }
    }

    final local = await _getLocalRecords();
    _updateStream(local);
    return local;
  }

  // --- 3. ДОБАВЛЕНИЕ (ADD) ---
  Future<void> addRecord(FastingRecord record) async {
    final records = await _getLocalRecords();
    records.insert(0, record);
    records.sort((a, b) => b.startTime.compareTo(a.startTime));

    await _saveToLocal(records);
    _updateStream(records);

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
        }, SetOptions(merge: true));
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
    _updateStream(records);

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
  // 🔥 ИСПРАВЛЕНИЕ 2: Делаем расчет стрика синхронным и молниеносным.
  // Нам не нужно читать диск каждый раз. Данные уже загружены в _currentRecords.
  int calculateStreak() {
    final records = _currentRecords;
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
    _updateStream([]);

    final user = _auth.currentUser;
    if (user != null) {
      final batch = _db.batch();
      final snap = await _db.collection('users').doc(user.uid).collection('fasting_history').get();
      for (var doc in snap.docs) batch.delete(doc.reference);
      await batch.commit();
    }
  }

  // --- HELPERS ---
  void _updateStream(List<FastingRecord> records) {
    _currentRecords = records;
    if (!_recordsController.isClosed) {
      _recordsController.add(records);
    }
  }

  Future<List<FastingRecord>> _getLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => FastingRecord.fromMap(e)).toList();
    } catch (e) {
      debugPrint("⚠️ JSON Decode Error: $e");
      return [];
    }
  }

  Future<void> _saveToLocal(List<FastingRecord> list) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_localKey, jsonString);
  }
}