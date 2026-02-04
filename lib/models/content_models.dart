import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Вспомогательная функция для безопасного получения перевода
String _getTranslated(Map<String, dynamic>? data, String field, String locale) {
  if (data == null) return "";
  final map = data[field];

  // Если поле пришло не как Map (например, старый формат), вернем пустую строку
  if (map is! Map) return "";

  // Пытаемся взять нужный язык, если нет - берем английский, если нет - пустую строку
  return map[locale]?.toString() ?? map['en']?.toString() ?? "";
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
  final Color color; // Теперь храним сразу Color
  final bool isPro;

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
    this.isPro = true,
  });

  factory RecipeModel.fromSnapshot(DocumentSnapshot doc, String locale) {
    final data = doc.data() as Map<String, dynamic>?;

    Color parseColor(String? colorName) {
      switch (colorName) {
        case 'green': return Colors.greenAccent;
        case 'orange': return Colors.orangeAccent;
        case 'red': return Colors.redAccent;
        case 'purple': return Colors.purpleAccent;
        default: return Colors.blueAccent;
      }
    }

    if (data == null) {
      return RecipeModel(
          id: doc.id, title: "Error", description: "", imageUrl: "",
          calories: 0, protein: 0, fat: 0, carbs: 0, timeMinutes: 0,
          tags: [], color: Colors.grey, isPro: false);
    }

    return RecipeModel(
      id: doc.id,
      title: _getTranslated(data, 'title', locale), // Используем логику Map
      description: _getTranslated(data, 'description', locale),
      imageUrl: data['imageUrl']?.toString() ?? '',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toInt() ?? 0,
      fat: (data['fat'] as num?)?.toInt() ?? 0,
      carbs: (data['carbs'] as num?)?.toInt() ?? 0,
      timeMinutes: (data['time'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      color: parseColor(data['color']?.toString()),
      isPro: data['isPro'] ?? true,
    );
  }
}

class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String contentUrl;
  final String imageUrl; // Добавлено, так как используется в UI
  final bool isPro;

  ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.contentUrl,
    required this.imageUrl,
    this.isPro = false,
  });

  factory ArticleModel.fromSnapshot(DocumentSnapshot doc, String locale) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return ArticleModel(id: doc.id, title: "Error", subtitle: "", contentUrl: "", imageUrl: "");
    }

    return ArticleModel(
      id: doc.id,
      title: _getTranslated(data, 'title', locale),
      subtitle: _getTranslated(data, 'subtitle', locale),
      contentUrl: data['contentUrl']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '', // Читаем картинку
      isPro: data['isPro'] ?? false,
    );
  }
}