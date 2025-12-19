import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fastable/models/article.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Article>> getArticles(String languageCode) async {
    final articlesRef = _db.collection('articles').orderBy('order', descending: false);

    final snapshot = await articlesRef.get();

    final List<Article> articles = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Функция для безопасного получения перевода
      String getTranslatedField(String field) {
        return data['${field}_$languageCode'] ?? data['${field}_en'] ?? 'No Content';
      }

      articles.add(
        Article(
          id: doc.id,
          title: getTranslatedField('title'),
          summary: getTranslatedField('summary'),
          contentFull: getTranslatedField('content'),
          // ЗАЩИТА: Если imageUrl нет, ставим пустую строку
          imageUrl: data['imageUrl'] ?? '',
          // ЗАЩИТА: Если иконки нет, ставим дефолтную
          icon: Article.getIconFromString(data['icon'] ?? 'article'),
          // ЗАЩИТА: Если порядка нет, ставим в конец (99)
          order: (data['order'] as num?)?.toInt() ?? 99,
          // ЗАЩИТА: Если категории нет, ставим 'fasting'
          category: data['category'] ?? 'fasting',
          isPremium: data['is_premium'] ?? false,
        ),
      );
    }

    return articles;
  }
}