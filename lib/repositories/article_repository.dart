import 'package:fastable/models/article.dart';
import 'package:fastable/services/firestore_service.dart';

class ArticleRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<Article>> fetchArticles(String languageCode) {
    // Просто делегируем запрос сервису Firestore
    return _firestoreService.getArticles(languageCode);
  }
}