import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Хелпер для безопасного парсинга даты (Timestamp или String)
  DateTime _parseDateTime(dynamic val) {
    if (val is Timestamp) {
      return val.toDate();
    } else if (val is String) {
      return DateTime.tryParse(val) ?? DateTime.now();
    }
    return DateTime.now(); // Фолбэк
  }

  // Хелпер для парсинга настроения
  FastingMood? _parseMood(dynamic val) {
    if (val is String) {
      try {
        return FastingMood.values.firstWhere((e) => e.name == val);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Получаем коллекцию (хелпер)
  CollectionReference? _getCollection(User? user) {
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('fasting_history');
  }

  // --- ПОТОК ДАННЫХ (Для списков и графиков) ---
  Stream<List<FastingRecord>> getRecordsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      final col = _getCollection(user);

      if (col == null) {
        return Stream.value([]);
      }

      // Подписываемся на Firestore
      return col
          .orderBy('endTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;

            // Читаем данные, включая настроение
            return FastingRecord(
              startTime: _parseDateTime(data['startTime']),
              endTime: _parseDateTime(data['endTime']),
              duration: Duration(minutes: (data['durationMinutes'] as num? ?? 0).toInt()),
              mood: _parseMood(data['mood']),
            );
          } catch (e) {
            debugPrint("Error parsing record ${doc.id}: $e");
            return FastingRecord(
                startTime: DateTime.now(),
                endTime: DateTime.now(),
                duration: Duration.zero
            );
          }
        }).where((r) => r.duration.inMinutes > 0).toList();
      });
    });
  }

  // --- РАСЧЕТ СТРИКА ---
  Future<int> calculateStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final col = _getCollection(user);
    if (col == null) return 0;

    try {
      final snapshot = await col
          .orderBy('endTime', descending: true)
          .limit(50)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final records = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final val = data['endTime'];

        if (val is Timestamp) {
          return val.toDate();
        } else if (val is String) {
          return DateTime.tryParse(val) ?? DateTime.now();
        }
        return DateTime.now();
      }).toList();

      if (records.isEmpty) return 0;

      int streak = 0;
      final now = DateTime.now();

      DateTime checkDate = DateTime(now.year, now.month, now.day);
      final lastActivity = DateTime(records.first.year, records.first.month, records.first.day);

      if (lastActivity.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        return 0;
      }

      checkDate = lastActivity;

      for (var date in records) {
        final recordDate = DateTime(date.year, date.month, date.day);

        if (recordDate.isAtSameMomentAs(checkDate)) {
          continue;
        } else if (recordDate.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (recordDate.isBefore(checkDate.subtract(const Duration(days: 1)))) {
          break;
        }
      }

      return streak + 1;

    } catch (e) {
      print("Error calculating streak: $e");
      return 0;
    }
  }

  // --- ДОБАВЛЕНИЕ ЗАПИСИ ---
  Future<void> addRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final col = _getCollection(user);
    if (col == null) throw Exception("Database unavailable");

    try {
      await col.add({
        'startTime': Timestamp.fromDate(record.startTime),
        'endTime': Timestamp.fromDate(record.endTime),
        'durationMinutes': record.duration.inMinutes,
        'mood': record.mood?.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Record added successfully");
    } catch (e) {
      debugPrint("❌ FIREBASE WRITE ERROR: $e");
      throw Exception("Failed to save record: $e");
    }
  }

  // --- УДАЛЕНИЕ ЗАПИСИ ---
  Future<void> deleteRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final col = _getCollection(user);
    if (col == null) return;

    try {
      final snapshot = await col
          .where('startTime', isEqualTo: Timestamp.fromDate(record.startTime))
          .limit(1)
          .get();

      bool deleted = false;
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        deleted = true;
      }

      if (!deleted) {
        final snapshotString = await col
            .where('startTime', isEqualTo: record.startTime.toIso8601String())
            .limit(1)
            .get();
        for (var doc in snapshotString.docs) {
          await doc.reference.delete();
        }
      }

      debugPrint("✅ Record deleted");
    } catch (e) {
      debugPrint("❌ Delete Error: $e");
      throw Exception("Failed to delete record");
    }
  }

  // --- НОВЫЙ МЕТОД: ПОЛУЧЕНИЕ СПИСКА ЗАПИСЕЙ (ДЛЯ AI) ---
  // Мы берем последние 50, чтобы не грузить лишнее, так как AI нужно только 7
  Future<List<FastingRecord>> getAllRecords() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final col = _getCollection(user);
    if (col == null) return [];

    try {
      final snapshot = await col
          .orderBy('endTime', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FastingRecord(
          startTime: _parseDateTime(data['startTime']),
          endTime: _parseDateTime(data['endTime']),
          duration: Duration(minutes: (data['durationMinutes'] as num? ?? 0).toInt()),
          mood: _parseMood(data['mood']),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching all records: $e");
      return [];
    }
  }
}