class Recipe {
  final String id;
  final String title;
  final int calories;
  final int timeMinutes;
  final bool isPro;
  final String imageUrl; // На будущее
  final int colorHex; // Храним цвет как int (0xFF...)

  Recipe({
    required this.id,
    required this.title,
    required this.calories,
    required this.timeMinutes,
    required this.isPro,
    this.imageUrl = '',
    required this.colorHex,
  });

// Заглушка для получения цвета (пока нет картинок)
// В будущем будем брать картинку из imageUrl
}