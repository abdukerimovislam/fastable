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

  final _recordsController = StreamController<List<FastingRecord>>.broadcast();
  List<FastingRecord> _currentRecords = [];

  HistoryRepository() {
    _loadInitialData();
  }

  Stream<List<FastingRecord>> getRecordsStream() async* {
    yield _currentRecords;
    yield* _recordsController.stream;
  }

  List<FastingRecord> get currentRecords => List.unmodifiable(_currentRecords);

  @disposeMethod
  void dispose() {
    _recordsController.close();
  }

  Future<void> _loadInitialData() async {
    final local = await _getLocalRecords();
    _updateStream(local);
    await getAllRecords();
  }

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

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
    _updateStream([]);
  }

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

  // --- 🎯 ИДЕАЛЬНЫЙ АЛГОРИТМ ПОДСЧЕТА СТРИКОВ ---

  String _dateToStr(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Set<String> _getActiveDaysString(List<FastingRecord> records) {
    final Set<String> activeDays = {};
    for (var r in records) {
      DateTime current = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      final endDay = DateTime(r.endTime.year, r.endTime.month, r.endTime.day);

      while (!current.isAfter(endDay)) {
        activeDays.add(_dateToStr(current));
        // 🔥 Безопасный инкремент дня без багов с переводом часов (DST)
        current = DateTime(current.year, current.month, current.day + 1);
      }
    }
    return activeDays;
  }

  int calculateStreak() {
    final records = _currentRecords;
    if (records.isEmpty) return 0;

    final activeDays = _getActiveDaysString(records);

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    String todayStr = _dateToStr(checkDate);
    String yesterdayStr = _dateToStr(DateTime(checkDate.year, checkDate.month, checkDate.day - 1));

    // Если нет записи ни за сегодня, ни за вчера — стрик разорван
    if (!activeDays.contains(todayStr) && !activeDays.contains(yesterdayStr)) {
      return 0;
    }

    // Начинаем отсчет: если сегодня нет, значит стрик тянется со вчера
    if (!activeDays.contains(todayStr)) {
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    while (activeDays.contains(_dateToStr(checkDate))) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    return streak;
  }

  int calculateLongestStreak() {
    final records = _currentRecords;
    if (records.isEmpty) return 0;

    final activeDays = _getActiveDaysString(records);
    if (activeDays.isEmpty) return 0;

    // Сортируем дни по убыванию (от новых к старым)
    final sortedDaysStr = activeDays.toList()..sort((a, b) => b.compareTo(a));

    int longestStreak = 1;
    int tempStreak = 1;

    for (int i = 0; i < sortedDaysStr.length - 1; i++) {
      final partsA = sortedDaysStr[i].split('-');
      final dateA = DateTime(int.parse(partsA[0]), int.parse(partsA[1]), int.parse(partsA[2]));

      final partsB = sortedDaysStr[i+1].split('-');
      final dateB = DateTime(int.parse(partsB[0]), int.parse(partsB[1]), int.parse(partsB[2]));

      final expectedPrevDay = DateTime(dateA.year, dateA.month, dateA.day - 1);

      // Проверяем, идут ли дни подряд
      if (expectedPrevDay.year == dateB.year && expectedPrevDay.month == dateB.month && expectedPrevDay.day == dateB.day) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 1;
      }
    }
    return longestStreak;
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