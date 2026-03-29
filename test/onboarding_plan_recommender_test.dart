import 'package:flutter_test/flutter_test.dart';

import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/utils/onboarding_plan_recommender.dart';

void main() {
  test('recommends 16:8 for active lean users', () {
    final recommendation = OnboardingPlanRecommender.recommend(
      age: 28,
      weightKg: 72,
      heightCm: 180,
      activityLevel: ActivityLevel.active,
      primaryGoal: PrimaryGoal.healthAndEnergy,
      experience: FastingExperience.intermediate,
      sleepPattern: SleepPattern.regular,
    );

    expect(recommendation.recommendedIndex, 0);
    expect(recommendation.alternativeIndex, 1);
    expect(
      recommendation.primaryReason,
      PlanRecommendationReason.activeLifestyle,
    );
  });

  test('recommends 18:6 for sedentary overweight users', () {
    final recommendation = OnboardingPlanRecommender.recommend(
      age: 35,
      weightKg: 92,
      heightCm: 178,
      activityLevel: ActivityLevel.sedentary,
      primaryGoal: PrimaryGoal.healthAndEnergy,
      experience: FastingExperience.intermediate,
      sleepPattern: SleepPattern.regular,
    );

    expect(recommendation.recommendedIndex, 1);
    expect(recommendation.alternativeIndex, anyOf(0, 2));
    expect(recommendation.primaryReason, PlanRecommendationReason.balanced);
  });

  test('can recommend 20:4 for high bmi sedentary profiles', () {
    final recommendation = OnboardingPlanRecommender.recommend(
      age: 33,
      weightKg: 122,
      heightCm: 175,
      activityLevel: ActivityLevel.sedentary,
      primaryGoal: PrimaryGoal.fatLoss,
      experience: FastingExperience.advanced,
      sleepPattern: SleepPattern.regular,
    );

    expect(recommendation.recommendedIndex, 2);
    expect(recommendation.alternativeIndex, 1);
    expect(recommendation.primaryReason, PlanRecommendationReason.aggressive);
  });

  test('keeps older users on a gentler recommendation', () {
    final recommendation = OnboardingPlanRecommender.recommend(
      age: 61,
      weightKg: 78,
      heightCm: 172,
      activityLevel: ActivityLevel.moderate,
      primaryGoal: PrimaryGoal.healthAndEnergy,
      experience: FastingExperience.intermediate,
      sleepPattern: SleepPattern.regular,
    );

    expect(recommendation.recommendedIndex, 0);
    expect(recommendation.alternativeIndex, 1);
    expect(recommendation.primaryReason, PlanRecommendationReason.recovery);
  });

  test('keeps irregular sleepers on a gentler plan', () {
    final recommendation = OnboardingPlanRecommender.recommend(
      age: 31,
      weightKg: 88,
      heightCm: 176,
      activityLevel: ActivityLevel.moderate,
      primaryGoal: PrimaryGoal.fatLoss,
      experience: FastingExperience.intermediate,
      sleepPattern: SleepPattern.irregular,
    );

    expect(recommendation.recommendedIndex, anyOf(0, 1));
    expect(recommendation.primaryReason, PlanRecommendationReason.sleepSupport);
  });
}
