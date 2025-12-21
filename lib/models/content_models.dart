import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Вспомогательная функция для получения перевода
String _getTranslated(Map<String, dynamic> data, String field, String locale) {
  final map = data[field] as Map<String, dynamic>?;
  if (map == null) return "";
  // Пытаемся взять нужный язык, если нет - берем английский, если нет - пустую строку
  return map[locale] ?? map['en'] ?? "";
}

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final int timeMinutes;
  final List<String> tags;
  final Color color;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.timeMinutes,
    required this.tags,
    required this.color,
  });

  // Фабрика для создания из Firebase документа
  factory RecipeModel.fromSnapshot(DocumentSnapshot doc, String locale) {
    final data = doc.data() as Map<String, dynamic>;

    // Парсинг цвета из строки (простой вариант)
    Color parseColor(String? colorName) {
      switch (colorName) {
        case 'green': return Colors.greenAccent;
        case 'orange': return Colors.orangeAccent;
        case 'red': return Colors.redAccent;
        case 'purple': return Colors.purpleAccent;
        default: return Colors.blueAccent;
      }
    }

    return RecipeModel(
      id: doc.id,
      title: _getTranslated(data, 'title', locale),
      description: _getTranslated(data, 'description', locale),
      imageUrl: data['imageUrl'] ?? '',
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      fat: data['fat'] ?? 0,
      carbs: data['carbs'] ?? 0,
      timeMinutes: data['timeMinutes'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      color: parseColor(data['color']),
    );
  }
}

class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String contentUrl; // Ссылка на полный текст или Markdown (на будущее)

  ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.contentUrl,
  });

  factory ArticleModel.fromSnapshot(DocumentSnapshot doc, String locale) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: _getTranslated(data, 'title', locale),
      subtitle: _getTranslated(data, 'subtitle', locale),
      contentUrl: data['contentUrl'] ?? '',
    );
  }
}