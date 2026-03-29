import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String summary;
  final String? contentFull;
  final String imageUrl;
  final IconData icon;
  final int order;
  final String category;
  final bool isPremium;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    this.contentFull,
    required this.imageUrl,
    required this.icon,
    required this.order,
    required this.category,
    this.isPremium = false,
  });

  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'recycling':
        return Icons.recycling;
      case 'restaurant':
        return Icons.restaurant;
      case 'bolt':
        return Icons.bolt;
      case 'handshake':
        return Icons.handshake;
      default:
        return Icons.article;
    }
  }

  // Мы не используем здесь fromJson, так как парсинг идет в firestore_service,
  // но если бы использовали, защита была бы такой:
  // order: (json['order'] as num?)?.toInt() ?? 99,
}
