import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
// Импортируем правильную модель (RecipeModel)
import 'package:fastable/models/content_models.dart';

@lazySingleton
class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Возвращаем List<RecipeModel>, чтобы совпадало со State
  Future<List<RecipeModel>> getRecipes(String languageCode) async {
    try {
      final snapshot = await _firestore.collection('recipes').get();

      return snapshot.docs.map((doc) {
        // Используем фабрику из RecipeModel (обычно fromSnapshot или fromFirestore)
        return RecipeModel.fromSnapshot(doc, languageCode);
      }).toList();

    } catch (e) {
      print("Error fetching recipes: $e");
      return [];
    }
  }
}