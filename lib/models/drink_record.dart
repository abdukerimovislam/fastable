import 'package:flutter/material.dart';

enum DrinkCategory {
  water,
  coffee,
  tea,
  soda,
  juice,
  alcohol,
  other,
}

class DrinkType {
  final DrinkCategory category;
  final String name;
  final IconData icon;
  final Color color;
  final double hydrationFactor; // 1.0 = чистая вода, 0.8 = кофе (мочегонное), -1.0 = алкоголь (обезвоживает)
  final bool breaksFast; // 🔥 Самое важное: прерывает ли это голодание?

  const DrinkType({
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    required this.hydrationFactor,
    required this.breaksFast,
  });

  // Дефолтный список всех напитков
  static const List<DrinkType> allTypes = [
    DrinkType(category: DrinkCategory.water, name: "Water", icon: Icons.water_drop_rounded, color: Colors.blueAccent, hydrationFactor: 1.0, breaksFast: false),
    DrinkType(category: DrinkCategory.coffee, name: "Black Coffee", icon: Icons.coffee_rounded, color: Colors.brown, hydrationFactor: 0.8, breaksFast: false), // Черный кофе можно
    DrinkType(category: DrinkCategory.coffee, name: "Latte / Sweet Coffee", icon: Icons.local_cafe_rounded, color: Colors.orangeAccent, hydrationFactor: 0.6, breaksFast: true), // С молоком/сахаром - прерывает
    DrinkType(category: DrinkCategory.tea, name: "Green/Black Tea", icon: Icons.emoji_food_beverage_rounded, color: Colors.green, hydrationFactor: 0.9, breaksFast: false),
    DrinkType(category: DrinkCategory.soda, name: "Diet Soda", icon: Icons.sports_bar_rounded, color: Colors.grey, hydrationFactor: 0.5, breaksFast: false), // Спорно, но формально 0 калорий
    DrinkType(category: DrinkCategory.soda, name: "Sweet Soda", icon: Icons.local_drink_rounded, color: Colors.redAccent, hydrationFactor: 0.3, breaksFast: true),
    DrinkType(category: DrinkCategory.juice, name: "Juice", icon: Icons.blender_rounded, color: Colors.orange, hydrationFactor: 0.5, breaksFast: true),
    DrinkType(category: DrinkCategory.alcohol, name: "Alcohol", icon: Icons.wine_bar_rounded, color: Colors.purpleAccent, hydrationFactor: -1.0, breaksFast: true), // Обезвоживает сильно
  ];
}

class DrinkRecord {
  final DateTime time;
  final int volumeMl;
  final DrinkType type;

  DrinkRecord({
    required this.time,
    required this.volumeMl,
    required this.type,
  });

  // Перевод в реальную гидратацию (например, 100мл кофе = 80мл воды)
  double get effectiveHydration => volumeMl * type.hydrationFactor;

  // Для сохранения в SharedPreferences/SQLite
  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'volumeMl': volumeMl,
      'category': type.category.name,
      'name': type.name, // Для кастомных напитков, если добавим
    };
  }

  factory DrinkRecord.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String;
    final drinkName = json['name'] as String?;

    // Ищем тип по категории и имени, либо отдаем просто воду
    DrinkType type = DrinkType.allTypes.firstWhere(
          (d) => d.category.name == categoryName && (drinkName == null || d.name == drinkName),
      orElse: () => DrinkType.allTypes.first,
    );

    return DrinkRecord(
      time: DateTime.parse(json['time']),
      volumeMl: json['volumeMl'] as int,
      type: type,
    );
  }
}