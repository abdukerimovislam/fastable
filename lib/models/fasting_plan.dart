class FastingPlan {
  final Duration fastingDuration;
  final Duration eatingDuration;
  final String translationKey;

  FastingPlan({
    required this.fastingDuration,
    required this.eatingDuration,
    required this.translationKey,
  });

  // Хелпер для получения общего названия, если перевод не найден
  String get defaultName => "${fastingDuration.inHours}:${eatingDuration.inHours}";
}