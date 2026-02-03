import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/content_models.dart';

@lazySingleton
class ArticleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ArticleModel>> getArticles(String locale) async {
    try {
      // Сортируем, например, по дате добавления или приоритету, если такие поля есть
      final snapshot = await _db.collection('articles').get();
      return snapshot.docs.map((doc) => ArticleModel.fromSnapshot(doc, locale)).toList();
    } catch (e) {
      print("Error fetching articles: $e");
      throw e;
    }
  }
}