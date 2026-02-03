import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/models/content_models.dart'; // Используем твой файл

@lazySingleton
class RecipeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Метод принимает локаль, чтобы сразу отдать переведенные данные
  Future<List<RecipeModel>> getRecipes(String locale) async {
    try {
      final snapshot = await _db.collection('recipes').get();
      return snapshot.docs.map((doc) => RecipeModel.fromSnapshot(doc, locale)).toList();
    } catch (e) {
      print("Error fetching recipes: $e");
      throw e; // Пробрасываем ошибку для обработки в BLoC
    }
  }
}