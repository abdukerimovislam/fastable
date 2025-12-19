class FastingPlan {
  final Duration fastingDuration; // Renamed from 'duration'
  final Duration eatingDuration;  // NEW: How long the eating window is
  final String translationKey; // The key for its name

  FastingPlan({
    required this.fastingDuration,
    required this.eatingDuration,
    required this.translationKey,
  });
}