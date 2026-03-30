import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/core/app_prefs_keys.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/utils/onboarding_plan_recommender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPersonalizationSnapshot {
  final bool hasCompletedOnboarding;
  final PrimaryGoal primaryGoal;
  final FastingExperience fastingExperience;
  final SleepPattern sleepPattern;
  final int currentPlanIndex;
  final int customTargetHours;
  final int circadianTargetMinutes;
  final OnboardingPlanRecommendation recommendation;

  const OnboardingPersonalizationSnapshot({
    required this.hasCompletedOnboarding,
    required this.primaryGoal,
    required this.fastingExperience,
    required this.sleepPattern,
    required this.currentPlanIndex,
    required this.customTargetHours,
    required this.circadianTargetMinutes,
    required this.recommendation,
  });

  static Future<OnboardingPersonalizationSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingPersonalizationSnapshot.fromPrefs(prefs);
  }

  factory OnboardingPersonalizationSnapshot.fromPrefs(SharedPreferences prefs) {
    final age = prefs.getInt(AppPrefsKeys.userAge) ?? 25;
    final weight = prefs.getDouble(AppPrefsKeys.userWeight) ?? 70.0;
    final height = prefs.getDouble(AppPrefsKeys.userHeight) ?? 170.0;
    final activityIndex = prefs.getInt(AppPrefsKeys.userActivity) ?? 1;
    final activity =
        ActivityLevel.values.asMap()[activityIndex] ?? ActivityLevel.moderate;

    final primaryGoal = _parsePrimaryGoal(
      prefs.getString(AppPrefsKeys.onboardingPrimaryGoal),
    );
    final fastingExperience = _parseExperience(
      prefs.getString(AppPrefsKeys.onboardingFastingExperience),
    );
    final sleepPattern = _parseSleepPattern(
      prefs.getString(AppPrefsKeys.onboardingSleepPattern),
    );

    return OnboardingPersonalizationSnapshot(
      hasCompletedOnboarding: prefs.getBool(AppPrefsKeys.onboardingComplete) ?? false,
      primaryGoal: primaryGoal,
      fastingExperience: fastingExperience,
      sleepPattern: sleepPattern,
      currentPlanIndex: prefs.getInt(AppPrefsKeys.fastPlanIndex) ?? 0,
      customTargetHours: prefs.getInt(AppPrefsKeys.customTargetHours) ?? 14,
      circadianTargetMinutes:
          prefs.getInt(AppPrefsKeys.circadianTargetMinutes) ?? 14 * 60,
      recommendation: OnboardingPlanRecommender.recommend(
        age: age,
        weightKg: weight,
        heightCm: height,
        activityLevel: activity,
        primaryGoal: primaryGoal,
        experience: fastingExperience,
        sleepPattern: sleepPattern,
      ),
    );
  }

  factory OnboardingPersonalizationSnapshot.fromState({
    required OnboardingProfileState onboardingProfile,
    required WeightState weightState,
    required FastingState fastingState,
  }) {
    final currentPlanIndex = fastingState.planIndex;
    final customTargetHours = _resolveCustomTargetHours(fastingState);
    final circadianTargetMinutes = _resolveCircadianTargetMinutes(fastingState);

    return OnboardingPersonalizationSnapshot(
      hasCompletedOnboarding: onboardingProfile.hasCompletedOnboarding,
      primaryGoal: onboardingProfile.primaryGoal,
      fastingExperience: onboardingProfile.fastingExperience,
      sleepPattern: onboardingProfile.sleepPattern,
      currentPlanIndex: currentPlanIndex,
      customTargetHours: customTargetHours,
      circadianTargetMinutes: circadianTargetMinutes,
      recommendation: OnboardingPlanRecommender.recommend(
        age: weightState.age,
        weightKg: weightState.currentWeight,
        heightCm: weightState.heightCm,
        activityLevel: weightState.activityLevel,
        primaryGoal: onboardingProfile.primaryGoal,
        experience: onboardingProfile.fastingExperience,
        sleepPattern: onboardingProfile.sleepPattern,
      ),
    );
  }

  static PrimaryGoal _parsePrimaryGoal(String? raw) {
    for (final value in PrimaryGoal.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return PrimaryGoal.healthAndEnergy;
  }

  static FastingExperience _parseExperience(String? raw) {
    for (final value in FastingExperience.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return FastingExperience.beginner;
  }

  static SleepPattern _parseSleepPattern(String? raw) {
    for (final value in SleepPattern.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return SleepPattern.regular;
  }

  String localizedGoal(AppLocalizations l10n) {
    switch (primaryGoal) {
      case PrimaryGoal.fatLoss:
        return l10n.goalFatLossTitle;
      case PrimaryGoal.healthAndEnergy:
        return l10n.goalHealthTitle;
      case PrimaryGoal.consistency:
        return l10n.goalHabitTitle;
    }
  }

  String localizedExperience(AppLocalizations l10n) {
    switch (fastingExperience) {
      case FastingExperience.beginner:
        return l10n.experienceBeginnerTitle;
      case FastingExperience.intermediate:
        return l10n.experienceIntermediateTitle;
      case FastingExperience.advanced:
        return l10n.experienceAdvancedTitle;
    }
  }

  String localizedSleepPattern(AppLocalizations l10n) {
    switch (sleepPattern) {
      case SleepPattern.regular:
        return l10n.sleepRegularTitle;
      case SleepPattern.late:
        return l10n.sleepLateTitle;
      case SleepPattern.irregular:
        return l10n.sleepIrregularTitle;
    }
  }

  String localizedCurrentPlan(AppLocalizations l10n) {
    if (currentPlanIndex == FastingState.circadianPlanIndex) {
      return l10n.planCircadianTitle;
    }
    if (currentPlanIndex == FastingState.customPlanIndex) {
      return "${l10n.customPlan} (${customTargetHours}h)";
    }
    if (currentPlanIndex >= 0 &&
        currentPlanIndex < FastingPlan.defaultPlans.length) {
      return _planLabel(FastingPlan.defaultPlans[currentPlanIndex]);
    }
    return _planLabel(FastingPlan.defaultPlans.first);
  }

  String localizedRecommendedPlan() {
    return _planLabel(
      FastingPlan.defaultPlans[recommendation.recommendedIndex],
    );
  }

  String localizedReason(AppLocalizations l10n) {
    switch (recommendation.primaryReason) {
      case PlanRecommendationReason.recovery:
        return l10n.smartPlanWhyRecovery;
      case PlanRecommendationReason.activeLifestyle:
        return l10n.smartPlanWhyActive;
      case PlanRecommendationReason.beginnerFriendly:
        return l10n.smartPlanWhyBeginner;
      case PlanRecommendationReason.balanced:
        return l10n.smartPlanWhyBalanced;
      case PlanRecommendationReason.aggressive:
        return l10n.smartPlanWhyAggressive;
      case PlanRecommendationReason.sleepSupport:
        return l10n.smartPlanWhySleep;
    }
  }

  String buildCoachGreeting(AppLocalizations l10n) {
    return l10n.smartPlanCoachGreeting(
      localizedCurrentPlan(l10n),
      localizedGoal(l10n),
      localizedExperience(l10n),
      localizedSleepPattern(l10n),
    );
  }

  String buildAiContext() {
    return '''
Primary goal: ${primaryGoal.name}
Fasting experience: ${fastingExperience.name}
Sleep pattern: ${sleepPattern.name}
Current plan: ${_currentPlanContext()}
Smart recommendation: ${localizedRecommendedPlan()}
Recommendation reason: ${recommendation.primaryReason.name}
'''
        .trim();
  }

  String _currentPlanContext() {
    if (currentPlanIndex == FastingState.circadianPlanIndex) {
      return 'circadian';
    }
    if (currentPlanIndex == FastingState.customPlanIndex) {
      return 'custom_${customTargetHours}h';
    }
    if (currentPlanIndex >= 0 &&
        currentPlanIndex < FastingPlan.defaultPlans.length) {
      return _planLabel(FastingPlan.defaultPlans[currentPlanIndex]);
    }
    return _planLabel(FastingPlan.defaultPlans.first);
  }

  static String _planLabel(FastingPlan plan) {
    return "${plan.fastingDuration.inHours}:${plan.eatingDuration.inHours}";
  }

  static int _resolveCustomTargetHours(FastingState fastingState) {
    if (fastingState.planIndex != FastingState.customPlanIndex) {
      return 14;
    }

    if (fastingState.phase == FastingPhase.eating) {
      return (24 - fastingState.goalDuration.inHours).clamp(1, 23);
    }

    return fastingState.goalDuration.inHours.clamp(1, 23);
  }

  static int _resolveCircadianTargetMinutes(FastingState fastingState) {
    if (fastingState.planIndex != FastingState.circadianPlanIndex) {
      return 14 * 60;
    }

    if (fastingState.phase == FastingPhase.eating) {
      return ((24 * 60) - fastingState.goalDuration.inMinutes).clamp(
        60,
        23 * 60,
      );
    }

    return fastingState.goalDuration.inMinutes.clamp(60, 23 * 60);
  }
}
