import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Вспомогательная функция для безопасного получения перевода
String resolveLocalizedContentField(
  Map<String, dynamic>? data,
  List<String> fields,
  String locale,
) {
  return _getTranslatedFromFields(data, fields, locale);
}

String _getTranslated(Map<String, dynamic>? data, String field, String locale) {
  return resolveLocalizedContentField(data, [field], locale);
}

String _getTranslatedFromFields(
  Map<String, dynamic>? data,
  List<String> fields,
  String locale,
) {
  if (data == null) return "";

  final normalizedLocale = locale.split('_').first;

  for (final field in fields) {
    final value = data[field];

    if (value is Map) {
      final localized =
          value[locale]?.toString() ??
          value[normalizedLocale]?.toString() ??
          value['en']?.toString();
      if (localized != null && localized.isNotEmpty) {
        return localized;
      }
    }

    if (value is String && value.isNotEmpty) {
      return value;
    }

    final localeKeys = <String>[
      '${field}_$locale',
      '${field}_$normalizedLocale',
      '${field}_en',
    ];

    for (final localeKey in localeKeys) {
      final legacyValue = data[localeKey];
      if (legacyValue is String && legacyValue.isNotEmpty) {
        return legacyValue;
      }
    }
  }

  return "";
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
    return RecipeModel.fromMap(doc.id, data, locale);
  }

  factory RecipeModel.fromMap(
    String id,
    Map<String, dynamic>? data,
    String locale,
  ) {
    Color parseColor(String? colorName) {
      switch (colorName) {
        case 'green':
          return Colors.greenAccent;
        case 'orange':
          return Colors.orangeAccent;
        case 'red':
          return Colors.redAccent;
        case 'purple':
          return Colors.purpleAccent;
        default:
          return Colors.blueAccent;
      }
    }

    if (data == null) {
      return RecipeModel(
        id: id,
        title: "",
        description: "",
        imageUrl: "",
        calories: 0,
        protein: 0,
        fat: 0,
        carbs: 0,
        timeMinutes: 0,
        tags: [],
        color: Colors.grey,
        isPro: false,
      );
    }

    return RecipeModel(
      id: id,
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
      isPro: data['isPro'] ?? data['is_premium'] ?? true,
    );
  }
}

class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl; // Добавлено, так как используется в UI
  final bool isPro;

  ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isPro = false,
  });

  factory ArticleModel.fromSnapshot(DocumentSnapshot doc, String locale) {
    final data = doc.data() as Map<String, dynamic>?;
    return ArticleModel.fromMap(doc.id, data, locale);
  }

  factory ArticleModel.fromMap(
    String id,
    Map<String, dynamic>? data,
    String locale,
  ) {
    if (data == null) {
      return ArticleModel(id: id, title: "", subtitle: "", imageUrl: "");
    }

    return ArticleModel(
      id: id,
      title: _getTranslated(data, 'title', locale),
      subtitle: resolveLocalizedContentField(data, [
        'subtitle',
        'summary',
      ], locale),
      imageUrl: data['imageUrl']?.toString() ?? '', // Читаем картинку
      isPro: data['isPro'] ?? data['is_premium'] ?? false,
    );
  }
}
