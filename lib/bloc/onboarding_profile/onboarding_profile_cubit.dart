import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/utils/onboarding_plan_recommender.dart';

class OnboardingProfileState extends Equatable {
  final bool hasCompletedOnboarding;
  final PrimaryGoal primaryGoal;
  final FastingExperience fastingExperience;
  final SleepPattern sleepPattern;

  const OnboardingProfileState({
    this.hasCompletedOnboarding = false,
    this.primaryGoal = PrimaryGoal.healthAndEnergy,
    this.fastingExperience = FastingExperience.beginner,
    this.sleepPattern = SleepPattern.regular,
  });

  factory OnboardingProfileState.fromPrefs(SharedPreferences prefs) {
    return OnboardingProfileState(
      hasCompletedOnboarding: prefs.getBool('onboarding_complete') ?? false,
      primaryGoal: _parsePrimaryGoal(
        prefs.getString('onboarding_primary_goal'),
      ),
      fastingExperience: _parseExperience(
        prefs.getString('onboarding_fasting_experience'),
      ),
      sleepPattern: _parseSleepPattern(
        prefs.getString('onboarding_sleep_pattern'),
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

  @override
  List<Object?> get props => [
    hasCompletedOnboarding,
    primaryGoal,
    fastingExperience,
    sleepPattern,
  ];
}

class OnboardingProfileCubit extends Cubit<OnboardingProfileState> {
  OnboardingProfileCubit() : super(const OnboardingProfileState());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (isClosed) return;
    emit(OnboardingProfileState.fromPrefs(prefs));
  }
}
