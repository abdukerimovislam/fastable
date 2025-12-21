import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastable/models/fasting_record.dart';

class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем ссылку на коллекцию истории конкретного пользователя
  CollectionReference? _getCollection() {
    final user = _auth.currentUser;
    // Если пользователь не авторизован (даже анонимно), возвращаем null
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('fasting_history');
  }

  // --- ГЛАВНЫЙ МЕТОД ДЛЯ СТАТИСТИКИ (STREAM) ---
  // Слушает изменения в базе данных в реальном времени
  Stream<List<FastingRecord>> getRecordsStream() {
    final col = _getCollection();

    if (col == null) {
      // Если нет доступа к базе, возвращаем пустой список
      return Stream.value([]);
    }

    return col
        .orderBy('endTime', descending: true) // Сортируем: новые сверху
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FastingRecord(
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
          duration: Duration(minutes: (data['durationMinutes'] as num).toInt()),
        );
      }).toList();
    });
  }

  // Добавить запись
  Future<void> addRecord(FastingRecord record) async {
    final col = _getCollection();
    if (col == null) return;

    await col.add({
      'startTime': Timestamp.fromDate(record.startTime),
      'endTime': Timestamp.fromDate(record.endTime),
      'durationMinutes': record.duration.inMinutes,
    });
  }

  // Удалить запись
  Future<void> deleteRecord(FastingRecord record) async {
    final col = _getCollection();
    if (col == null) return;

    // Ищем запись по времени начала, чтобы удалить
    final snapshot = await col
        .where('startTime', isEqualTo: Timestamp.fromDate(record.startTime))
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}