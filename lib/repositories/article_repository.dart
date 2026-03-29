import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/content_models.dart';

@lazySingleton
class ArticleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ArticleModel>> getArticles(String locale) async {
    final collection = _db.collection('articles');

    try {
      final snapshot = await collection.get(
        const GetOptions(source: Source.serverAndCache),
      );
      final docs = snapshot.docs.toList()..sort(_compareDocsByOrderThenId);
      return docs.map((doc) => ArticleModel.fromSnapshot(doc, locale)).toList();
    } catch (e) {
      debugPrint("Error fetching articles: $e");
      try {
        final snapshot = await collection.get(
          const GetOptions(source: Source.cache),
        );
        final docs = snapshot.docs.toList()..sort(_compareDocsByOrderThenId);
        return docs
            .map((doc) => ArticleModel.fromSnapshot(doc, locale))
            .toList();
      } catch (_) {
        rethrow;
      }
    }
  }

  int _compareDocsByOrderThenId(
    QueryDocumentSnapshot<Map<String, dynamic>> a,
    QueryDocumentSnapshot<Map<String, dynamic>> b,
  ) {
    final orderA = (a.data()['order'] as num?)?.toInt() ?? 9999;
    final orderB = (b.data()['order'] as num?)?.toInt() ?? 9999;
    if (orderA != orderB) {
      return orderA.compareTo(orderB);
    }
    return a.id.compareTo(b.id);
  }
}
