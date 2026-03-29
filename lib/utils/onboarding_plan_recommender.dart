import 'package:fastable/bloc/weight/weight_state.dart';

enum PrimaryGoal { fatLoss, healthAndEnergy, consistency }

enum FastingExperience { beginner, intermediate, advanced }

enum SleepPattern { regular, late, irregular }

enum PlanRecommendationReason {
  recovery,
  activeLifestyle,
  beginnerFriendly,
  balanced,
  aggressive,
  sleepSupport,
}

class OnboardingPlanRecommendation {
  final int recommendedIndex;
  final int alternativeIndex;
  final double bmi;
  final PlanRecommendationReason primaryReason;

  const OnboardingPlanRecommendation({
    required this.recommendedIndex,
    required this.alternativeIndex,
    required this.bmi,
    required this.primaryReason,
  });
}

class OnboardingPlanRecommender {
  const OnboardingPlanRecommender._();

  static OnboardingPlanRecommendation recommend({
    required int age,
    required double weightKg,
    required double heightCm,
    required ActivityLevel activityLevel,
    required PrimaryGoal primaryGoal,
    required FastingExperience experience,
    required SleepPattern sleepPattern,
  }) {
    final bmi = _calculateBmi(weightKg, heightCm);
    final scores = <int>[4, 2, -1, -10];

    if (bmi < 18.5) {
      scores[0] += 8;
      scores[1] -= 1;
      scores[2] -= 6;
      scores[3] -= 10;
    } else if (bmi < 23) {
      scores[0] += 4;
      scores[1] += 1;
      scores[2] -= 2;
      scores[3] -= 8;
    } else if (bmi < 27) {
      scores[0] += 2;
      scores[1] += 3;
      scores[3] -= 6;
    } else if (bmi < 32) {
      scores[0] += 1;
      scores[1] += 5;
      scores[2] += 2;
      scores[3] -= 6;
    } else {
      scores[0] -= 1;
      scores[1] += 4;
      scores[2] += 4;
      scores[3] -= 4;
    }

    if (age < 21) {
      scores[0] += 6;
      scores[1] -= 1;
      scores[2] -= 6;
      scores[3] -= 10;
    } else if (age >= 55) {
      scores[0] += 6;
      scores[1] += 1;
      scores[2] -= 4;
      scores[3] -= 8;
    } else if (age >= 45) {
      scores[0] += 2;
      scores[1] += 2;
      scores[2] -= 1;
    } else if (age >= 30) {
      scores[1] += 1;
    }

    switch (activityLevel) {
      case ActivityLevel.sedentary:
        scores[1] += 2;
        scores[2] += 1;
        break;
      case ActivityLevel.moderate:
        scores[1] += 1;
        break;
      case ActivityLevel.active:
        scores[0] += 5;
        scores[1] += 2;
        scores[2] -= 4;
        scores[3] -= 8;
        break;
    }

    switch (primaryGoal) {
      case PrimaryGoal.fatLoss:
        scores[1] += 2;
        scores[2] += 3;
        scores[3] -= 1;
        if (bmi < 24) {
          scores[2] -= 2;
        }
        break;
      case PrimaryGoal.healthAndEnergy:
        scores[0] += 2;
        scores[1] += 2;
        scores[3] -= 4;
        break;
      case PrimaryGoal.consistency:
        scores[0] += 5;
        scores[1] += 1;
        scores[2] -= 5;
        scores[3] -= 10;
        break;
    }

    switch (experience) {
      case FastingExperience.beginner:
        scores[0] += 6;
        scores[1] += 1;
        scores[2] -= 6;
        scores[3] -= 12;
        break;
      case FastingExperience.intermediate:
        scores[0] += 1;
        scores[1] += 2;
        scores[3] -= 4;
        break;
      case FastingExperience.advanced:
        scores[1] += 1;
        scores[2] += 3;
        scores[3] += 1;
        break;
    }

    switch (sleepPattern) {
      case SleepPattern.regular:
        break;
      case SleepPattern.late:
        scores[0] += 1;
        scores[2] -= 2;
        scores[3] -= 6;
        break;
      case SleepPattern.irregular:
        scores[0] += 4;
        scores[1] += 1;
        scores[2] -= 5;
        scores[3] -= 12;
        break;
    }

    if (bmi >= 35 &&
        age >= 25 &&
        age <= 40 &&
        activityLevel == ActivityLevel.sedentary &&
        primaryGoal == PrimaryGoal.fatLoss &&
        experience != FastingExperience.beginner &&
        sleepPattern != SleepPattern.irregular) {
      scores[2] += 6;
    } else if (bmi >= 33 &&
        age >= 25 &&
        age <= 45 &&
        activityLevel == ActivityLevel.moderate &&
        primaryGoal == PrimaryGoal.fatLoss &&
        sleepPattern == SleepPattern.regular) {
      scores[2] += 3;
    }

    final rankedIndices = List<int>.generate(scores.length, (index) => index)
      ..sort((a, b) {
        final scoreComparison = scores[b].compareTo(scores[a]);
        if (scoreComparison != 0) {
          return scoreComparison;
        }
        return a.compareTo(b);
      });

    final recommendedIndex = rankedIndices.first;
    final alternativeIndex = _pickAlternative(recommendedIndex, scores);

    return OnboardingPlanRecommendation(
      recommendedIndex: recommendedIndex,
      alternativeIndex: alternativeIndex,
      bmi: bmi,
      primaryReason: _pickReason(
        recommendedIndex: recommendedIndex,
        bmi: bmi,
        age: age,
        activityLevel: activityLevel,
        primaryGoal: primaryGoal,
        experience: experience,
        sleepPattern: sleepPattern,
      ),
    );
  }

  static double _calculateBmi(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) {
      return 0;
    }

    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  static int _pickAlternative(int recommendedIndex, List<int> scores) {
    switch (recommendedIndex) {
      case 0:
        return scores[1] >= scores[2] ? 1 : 2;
      case 1:
        return scores[0] >= scores[2] ? 0 : 2;
      case 2:
        return scores[1] >= scores[0] ? 1 : 0;
      default:
        return 1;
    }
  }

  static PlanRecommendationReason _pickReason({
    required int recommendedIndex,
    required double bmi,
    required int age,
    required ActivityLevel activityLevel,
    required PrimaryGoal primaryGoal,
    required FastingExperience experience,
    required SleepPattern sleepPattern,
  }) {
    if (age < 21 || age >= 55 || bmi < 18.5) {
      return PlanRecommendationReason.recovery;
    }
    if (sleepPattern == SleepPattern.irregular) {
      return PlanRecommendationReason.sleepSupport;
    }
    if (activityLevel == ActivityLevel.active) {
      return PlanRecommendationReason.activeLifestyle;
    }
    if (experience == FastingExperience.beginner ||
        primaryGoal == PrimaryGoal.consistency) {
      return PlanRecommendationReason.beginnerFriendly;
    }
    if (recommendedIndex >= 2) {
      return PlanRecommendationReason.aggressive;
    }
    return PlanRecommendationReason.balanced;
  }
}
