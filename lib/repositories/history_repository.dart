import 'dart:async';
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
    return DateTime.now(); // Фолбэк на случай null или другого типа
  }

  // Получаем коллекцию (хелпер)
  CollectionReference? _getCollection(User? user) {
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('fasting_history');
  }

  // --- ИСПРАВЛЕННЫЙ ПОТОК ДАННЫХ ---
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

            // ИСПОЛЬЗУЕМ БЕЗОПАСНЫЙ ХЕЛПЕР _parseDateTime
            return FastingRecord(
              startTime: _parseDateTime(data['startTime']),
              endTime: _parseDateTime(data['endTime']),
              // Поддержка и 'durationMinutes' (старый/новый), и вычисление на лету если нужно
              duration: Duration(minutes: (data['durationMinutes'] as num? ?? 0).toInt()),
            );
          } catch (e) {
            print("Error parsing record ${doc.id}: $e");
            // Возвращаем запись с нулевой длительностью, чтобы фильтр ниже её убрал
            return FastingRecord(startTime: DateTime.now(), endTime: DateTime.now(), duration: Duration.zero);
          }
        }).where((r) => r.duration.inMinutes > 0).toList();
      });
    });
  }

  // --- ДОБАВЛЕНИЕ ЗАПИСИ ---
  Future<void> addRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final col = _getCollection(user);
    if (col == null) return;

    try {
      await col.add({
        'startTime': Timestamp.fromDate(record.startTime),
        'endTime': Timestamp.fromDate(record.endTime),
        'durationMinutes': record.duration.inMinutes,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("✅ Record added successfully");
    } catch (e) {
      print("❌ FIREBASE WRITE ERROR: $e");
    }
  }

  // --- УДАЛЕНИЕ ЗАПИСИ ---
  Future<void> deleteRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    final col = _getCollection(user);
    if (col == null) return;

    try {
      // Ищем запись.
      // ВНИМАНИЕ: Если запись в базе сохранена как String, этот запрос может не найти её по Timestamp.
      // Но для новых записей это сработает. Для старых (строковых) удаление может не сработать через этот запрос,
      // но хотя бы список будет грузиться без ошибок.
      final snapshot = await col
          .where('startTime', isEqualTo: Timestamp.fromDate(record.startTime))
          .limit(1)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Если не нашли по Timestamp, пробуем найти как строку (для совместимости со старыми)
      if (snapshot.docs.isEmpty) {
        final snapshotString = await col
            .where('startTime', isEqualTo: record.startTime.toIso8601String())
            .limit(1)
            .get();
        for (var doc in snapshotString.docs) {
          await doc.reference.delete();
        }
      }

      print("✅ Record deleted");
    } catch (e) {
      print("❌ Delete Error: $e");
    }
  }
}