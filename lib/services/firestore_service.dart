import 'package:fastable/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fastable/models/article.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 ИСПРАВЛЕНИЕ: Храним время последнего обращения к серверу (в памяти текущей сессии)
  DateTime? _lastFetchTime;

  Future<List<Article>> getArticles(
    String languageCode, {
    int limit = 50,
  }) async {
    // 🔥 ЗАЩИТА 1: Ограничиваем максимальное количество документов (limit),
    // чтобы случайно не выкачать 1000+ статей и не разориться на квотах
    final articlesRef = _db
        .collection('articles')
        .orderBy('order', descending: false)
        .limit(limit);

    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      // 🔥 ЗАЩИТА 2: Умное кэширование. Экономим Firestore Reads.
      // Если мы уже скачивали статьи менее 12 часов назад, берем их из бесплатного кэша устройства.
      bool shouldFetchFromServer = true;
      if (_lastFetchTime != null) {
        final diff = DateTime.now().difference(_lastFetchTime!);
        if (diff.inHours < 12) {
          shouldFetchFromServer = false;
        }
      }

      if (shouldFetchFromServer) {
        // Читаем с сервера и обновляем кэш
        snapshot = await articlesRef.get(
          const GetOptions(source: Source.serverAndCache),
        );
        _lastFetchTime = DateTime.now();
      } else {
        // Читаем только из локального кэша (0 затрат квот Firestore)
        snapshot = await articlesRef.get(
          const GetOptions(source: Source.cache),
        );

        // Подстраховка: если кэш по какой-то причине пуст, делаем фоллбэк на сервер
        if (snapshot.docs.isEmpty) {
          snapshot = await articlesRef.get(
            const GetOptions(source: Source.serverAndCache),
          );
          _lastFetchTime = DateTime.now();
        }
      }
    } catch (e) {
      appLog("⚠️ Firestore getArticles error (falling back to cache): $e");
      // Если нет интернета или ошибка сети, принудительно отдаем то, что есть в кэше
      snapshot = await articlesRef.get(const GetOptions(source: Source.cache));
    }

    final List<Article> articles = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Функция для безопасного получения перевода
      String getTranslatedField(String field) {
        return data['${field}_$languageCode'] ??
            data['${field}_en'] ??
            'No Content';
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
