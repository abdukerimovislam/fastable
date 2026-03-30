import 'package:fastable/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
// Импортируем правильную модель (RecipeModel)
import 'package:fastable/models/content_models.dart';

@lazySingleton
class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Возвращаем List<RecipeModel>, чтобы совпадало со State
  Future<List<RecipeModel>> getRecipes(String languageCode) async {
    final collection = _firestore.collection('recipes');

    try {
      final snapshot = await collection.get(
        const GetOptions(source: Source.serverAndCache),
      );
      final docs = snapshot.docs.toList()..sort(_compareDocsByOrderThenId);

      return docs.map((doc) {
        // Используем фабрику из RecipeModel (обычно fromSnapshot или fromFirestore)
        return RecipeModel.fromSnapshot(doc, languageCode);
      }).toList();
    } catch (e) {
      appLog("Error fetching recipes: $e");
      try {
        final snapshot = await collection.get(
          const GetOptions(source: Source.cache),
        );
        final docs = snapshot.docs.toList()..sort(_compareDocsByOrderThenId);
        return docs
            .map((doc) => RecipeModel.fromSnapshot(doc, languageCode))
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
