import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastable/models/content_models.dart';

class ContentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Получаем поток рецептов с учетом языка
  Stream<List<RecipeModel>> getRecipes(String locale) {
    return _db.collection('recipes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromSnapshot(doc, locale))
          .toList();
    });
  }

  // Получаем поток статей
  Stream<List<ArticleModel>> getArticles(String locale) {
    return _db.collection('articles').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromSnapshot(doc, locale))
          .toList();
    });
  }
}
