import 'package:flutter/material.dart';

enum AchievementType { firstFast, streak3, streak7, total10, totalHours100 }

class Achievement {
  final String id;
  final String titleKey; // Ключ для l10n
  final String descKey; // Ключ для l10n
  final IconData icon;
  final Color color;
  final bool Function(int totalFasts, int totalHours, int currentStreak)
  condition;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.color,
    required this.condition,
  });

  // Список всех возможных достижений и правил их получения
  static final List<Achievement> all = [
    Achievement(
      id: 'first_fast',
      titleKey: 'achFirstFast',
      descKey: 'achFirstFastDesc',
      icon: Icons.star,
      color: Colors.yellow,
      condition: (fasts, hours, streak) => fasts >= 1,
    ),
    Achievement(
      id: 'streak_3',
      titleKey: 'achStreak3',
      descKey: 'achStreak3Desc',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      condition: (fasts, hours, streak) => streak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      titleKey: 'achStreak7',
      descKey: 'achStreak7Desc',
      icon: Icons.whatshot,
      color: Colors.redAccent,
      condition: (fasts, hours, streak) => streak >= 7,
    ),
    Achievement(
      id: 'total_10',
      titleKey: 'achTotal10',
      descKey: 'achTotal10Desc',
      icon: Icons.emoji_events,
      color: Colors.blueAccent,
      condition: (fasts, hours, streak) => fasts >= 10,
    ),
    Achievement(
      id: 'total_100_hours',
      titleKey: 'achTotalHours100',
      descKey: 'achTotalHours100Desc',
      icon: Icons.timer,
      color: Colors.purpleAccent,
      condition: (fasts, hours, streak) => hours >= 100,
    ),
  ];
}
