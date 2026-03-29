import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/utils/onboarding_personalization.dart';
import 'package:fastable/utils/onboarding_plan_recommender.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'OnboardingProfileCubit loads onboarding answers from preferences',
    () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_primary_goal': PrimaryGoal.fatLoss.name,
        'onboarding_fasting_experience': FastingExperience.advanced.name,
        'onboarding_sleep_pattern': SleepPattern.irregular.name,
      });

      final cubit = OnboardingProfileCubit();
      await cubit.load();

      expect(cubit.state.hasCompletedOnboarding, true);
      expect(cubit.state.primaryGoal, PrimaryGoal.fatLoss);
      expect(cubit.state.fastingExperience, FastingExperience.advanced);
      expect(cubit.state.sleepPattern, SleepPattern.irregular);
      await cubit.close();
    },
  );

  test(
    'OnboardingPersonalizationSnapshot derives custom fasting target from eating phase state',
    () {
      final snapshot = OnboardingPersonalizationSnapshot.fromState(
        onboardingProfile: const OnboardingProfileState(
          hasCompletedOnboarding: true,
          primaryGoal: PrimaryGoal.healthAndEnergy,
          fastingExperience: FastingExperience.beginner,
          sleepPattern: SleepPattern.regular,
        ),
        weightState: const WeightState(
          age: 32,
          currentWeight: 74,
          heightCm: 176,
          activityLevel: ActivityLevel.moderate,
        ),
        fastingState: const FastingState(
          phase: FastingPhase.eating,
          planIndex: FastingState.customPlanIndex,
          goalDuration: Duration(hours: 7),
        ),
      );

      expect(snapshot.currentPlanIndex, FastingState.customPlanIndex);
      expect(snapshot.customTargetHours, 17);
      expect(snapshot.buildAiContext(), contains('Current plan: custom_17h'));
    },
  );

  test(
    'OnboardingPersonalizationSnapshot derives circadian target from eating phase state',
    () {
      final snapshot = OnboardingPersonalizationSnapshot.fromState(
        onboardingProfile: const OnboardingProfileState(
          hasCompletedOnboarding: true,
          primaryGoal: PrimaryGoal.consistency,
          fastingExperience: FastingExperience.intermediate,
          sleepPattern: SleepPattern.late,
        ),
        weightState: const WeightState(
          age: 29,
          currentWeight: 68,
          heightCm: 170,
          activityLevel: ActivityLevel.active,
        ),
        fastingState: const FastingState(
          phase: FastingPhase.eating,
          planIndex: FastingState.circadianPlanIndex,
          goalDuration: Duration(hours: 9),
        ),
      );

      expect(snapshot.currentPlanIndex, FastingState.circadianPlanIndex);
      expect(
        snapshot.circadianTargetMinutes,
        const Duration(hours: 15).inMinutes,
      );
      expect(snapshot.buildAiContext(), contains('Current plan: circadian'));
    },
  );
}
