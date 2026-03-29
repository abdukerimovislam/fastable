class FastingPlan {
  final Duration fastingDuration;
  final Duration eatingDuration;
  final String translationKey;

  const FastingPlan({
    required this.fastingDuration,
    required this.eatingDuration,
    required this.translationKey,
  });

  // Единственный список планов для всего приложения
  static const List<FastingPlan> defaultPlans = [
    FastingPlan(
      fastingDuration: Duration(hours: 16),
      eatingDuration: Duration(hours: 8),
      translationKey: "fastingPlan16_8",
    ),
    FastingPlan(
      fastingDuration: Duration(hours: 18),
      eatingDuration: Duration(hours: 6),
      translationKey: "fastingPlan18_6",
    ),
    FastingPlan(
      fastingDuration: Duration(hours: 20),
      eatingDuration: Duration(hours: 4),
      translationKey: "fastingPlan20_4",
    ),
    FastingPlan(
      fastingDuration: Duration(hours: 24),
      eatingDuration: Duration(hours: 24),
      translationKey: "fastingPlanEatStopEat",
    ),
  ];
}
