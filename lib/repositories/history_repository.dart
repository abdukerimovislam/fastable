import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastable/models/fasting_record.dart';

class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем коллекцию (хелпер)
  CollectionReference? _getCollection(User? user) {
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('fasting_history');
  }

  // --- ИСПРАВЛЕННЫЙ ПОТОК ДАННЫХ ---
  // Этот поток реагирует на вход/выход пользователя автоматически
  Stream<List<FastingRecord>> getRecordsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      final col = _getCollection(user);

      if (col == null) {
        // Если юзера нет, возвращаем пустой список
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

            // БЕЗОПАСНЫЙ ПАРСИНГ (защита от ошибок типов)
            return FastingRecord(
              startTime: (data['startTime'] as Timestamp).toDate(),
              endTime: (data['endTime'] as Timestamp).toDate(),
              // Берем как num, приводим к int (защита от double)
              duration: Duration(minutes: (data['durationMinutes'] as num? ?? 0).toInt()),
            );
          } catch (e) {
            print("Error parsing record ${doc.id}: $e");
            // В случае ошибки возвращаем "пустую" запись, чтобы не крашить стрим
            // Или можно пропустить через .where (но здесь в map сложнее)
            return FastingRecord(startTime: DateTime.now(), endTime: DateTime.now(), duration: Duration.zero);
          }
        }).where((r) => r.duration.inMinutes > 0).toList(); // Фильтруем битые записи
      });
    });
  }

  // --- ДОБАВЛЕНИЕ ЗАПИСИ ---
  Future<void> addRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("❌ ERROR: Cannot add record. User is null.");
      return;
    }

    final col = _getCollection(user);
    if (col == null) return;

    try {
      await col.add({
        'startTime': Timestamp.fromDate(record.startTime),
        'endTime': Timestamp.fromDate(record.endTime),
        'durationMinutes': record.duration.inMinutes,
        'createdAt': FieldValue.serverTimestamp(), // Полезно для отладки
      });
      print("✅ Record added successfully for user: ${user.uid}");
    } catch (e) {
      print("❌ FIREBASE WRITE ERROR: $e");
      // Скорее всего проблема в Rules, если вы видите эту ошибку
    }
  }

  // --- УДАЛЕНИЕ ЗАПИСИ ---
  Future<void> deleteRecord(FastingRecord record) async {
    final user = _auth.currentUser;
    final col = _getCollection(user);
    if (col == null) return;

    try {
      // Ищем запись по точному совпадению времени начала
      final snapshot = await col
          .where('startTime', isEqualTo: Timestamp.fromDate(record.startTime))
          .limit(1)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print("✅ Record deleted");
    } catch (e) {
      print("❌ Delete Error: $e");
    }
  }
}