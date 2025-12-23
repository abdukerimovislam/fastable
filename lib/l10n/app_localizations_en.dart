// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fastable';

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String get navTimer => 'Timer';

  @override
  String get navHistory => 'History';

  @override
  String get navStats => 'Stats';

  @override
  String get navLearn => 'Learn';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAchievements => 'Achievements';

  @override
  String get navPro => 'Fastable PRO';

  @override
  String get fastingPhase => 'Fasting Phase';

  @override
  String get eatingWindow => 'Eating Window';

  @override
  String get readyToFast => 'Ready to Fast';

  @override
  String get autophagyZone => 'Autophagy Zone';

  @override
  String get startFast => 'Start Fasting';

  @override
  String get endFast => 'End Fasting';

  @override
  String get endCycle => 'End Cycle';

  @override
  String get remaining => 'Remaining';

  @override
  String get targetGoal => 'Target Goal';

  @override
  String get waterTracker => 'Water Tracker';

  @override
  String get waterCups => 'cups';

  @override
  String get addWater => 'Add Water';

  @override
  String get waterToday => 'Today\'s Water';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get cups => 'cups';

  @override
  String get cupsUnit => 'cups';

  @override
  String get weightTracker => 'Weight Tracker';

  @override
  String get logWeight => 'Log Weight';

  @override
  String get saveWeight => 'Save Weight';

  @override
  String get weightJourney => 'Weight Journey';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get fastingHours => 'Fasting Hours';

  @override
  String get currentWeight => 'Current';

  @override
  String get goalWeight => 'Goal';

  @override
  String get startWeight => 'Start';

  @override
  String get addWeight => 'Add Weight';

  @override
  String get enterWeight => 'Enter weight';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightProgress => 'Weight Progress';

  @override
  String get chartEmpty => 'Add at least two weight entries to see a graph.';

  @override
  String get proBannerTitle => 'Fastable PRO';

  @override
  String get proBannerDesc => 'Unlock analytics';

  @override
  String get premiumContentTitle => 'Premium Content';

  @override
  String get premiumContentDesc => 'Unlock full access to all articles and features.';

  @override
  String get getPro => 'Get PRO Access';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get proTitle => 'Get PRO Access';

  @override
  String get proMonthly => 'Monthly Subscription';

  @override
  String get proAnnual => 'Annual Subscription (40% Off)';

  @override
  String get unlockAll => 'Unlock PRO';

  @override
  String get accessStatus => 'Current Access';

  @override
  String statusActive(Object date) {
    return 'Active until $date';
  }

  @override
  String get statusFree => 'Free';

  @override
  String get proRequired => 'A PRO subscription is required to view this content';

  @override
  String get proComingSoon => 'PRO version is coming soon! Stay tuned.';

  @override
  String get year => 'year';

  @override
  String get month => 'mo.';

  @override
  String get discount => 'Discount';

  @override
  String get historyTitle => 'History';

  @override
  String get historyCalendar => 'Calendar';

  @override
  String get historyLog => 'Log';

  @override
  String get historyEmpty => 'No completed fasts yet. Your history will show up here!';

  @override
  String get fastComplete => 'Fast Complete! 🎉';

  @override
  String fastCompleteDesc(String time) {
    return 'You have fasted for $time. Save this record?';
  }

  @override
  String get noFastsOnDay => 'No fasts completed on this day.';

  @override
  String get detailsFor => 'Details for';

  @override
  String get endCyclePrompt => 'End Eating Window?';

  @override
  String get endCyclePromptDesc => 'This will stop the eating timer and reset the cycle.';

  @override
  String get endFastPrompt => 'End your current cycle to change the plan.';

  @override
  String get discard => 'Discard';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get attention => 'Attention';

  @override
  String get continueAction => 'Continue';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingWaterGoal => 'Daily Water Goal';

  @override
  String get settingHeight => 'Height';

  @override
  String get settingGoalWeight => 'Goal Weight';

  @override
  String get settingTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsHealthConnect => 'Health Connect';

  @override
  String get settingsSyncWeight => 'Sync weight & steps';

  @override
  String get healthConnectSyncTitle => 'Sync with Health Connect';

  @override
  String get healthConnectDisclosureIntro => 'Fastable requests READ and WRITE access to WEIGHT data via Health Connect.';

  @override
  String get healthConnectDisclosureRead => 'We use READ access to display your weight progress chart and stats based on historical data.';

  @override
  String get healthConnectDisclosureWrite => 'We use WRITE access so you can save weight entries from Fastable to your phone\'s central database.';

  @override
  String get healthConnectDisclosureSecure => 'Data is stored locally and used only for weight tracking. You can revoke permissions at any time.';

  @override
  String get healthConnectConnected => 'Health Connect connected!';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifyWater => 'Water Reminders';

  @override
  String get notifyWaterDesc => 'Get reminded to drink water';

  @override
  String get notifyWeight => 'Weight Reminder';

  @override
  String get notifyWeightDesc => 'Daily reminder to weigh in';

  @override
  String get notifyFastingStart => 'Fasting Start';

  @override
  String get notifyFastingStartDesc => 'Notify when fasting window starts';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get errorOpenLink => 'Could not open link';

  @override
  String get errorLoading => 'Error loading data';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get tabFasting => 'Fasting';

  @override
  String get tabKeto => 'Keto';

  @override
  String get tabPartner => 'Partner';

  @override
  String get guestUser => 'Guest';

  @override
  String get defaultUser => 'User';

  @override
  String get anonymousLogin => 'Anonymous Login';

  @override
  String get dataOnDevice => 'Data saved on device';

  @override
  String get connectGoogle => 'Connect Google Account';

  @override
  String get saveProgressCloud => 'Save progress to cloud';

  @override
  String get accountLinked => 'Account successfully linked!';

  @override
  String get linkError => 'Error linking account';

  @override
  String get resetAndExit => 'Reset Data & Exit';

  @override
  String get deleteAndExit => 'Delete & Exit';

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmLogout => 'Are you sure you want to sign out?';

  @override
  String get guestLogoutWarning => 'You are using a Guest account. If you sign out, all local data will be deleted permanently.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning => 'Are you sure? This will permanently delete all your data.';

  @override
  String get authWelcome => 'Welcome to Modern Fasting';

  @override
  String get authSubtitle => 'Sync your progress and reach your goals.';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get continueGuest => 'Continue as Guest';

  @override
  String get signInFailed => 'Sign in failed. Please try again.';

  @override
  String get welcomeMessage => 'Welcome to your fasting app!';

  @override
  String get choosePlan => 'Choose Plan';

  @override
  String get fastingPlan16_8 => '16:8 Intermittent Fast';

  @override
  String get fastingPlan18_6 => '18:6 Intermittent Fast';

  @override
  String get fastingPlan20_4 => '20:4 The Warrior Diet';

  @override
  String get fastingPlanEatStopEat => 'Eat-Stop-Eat (24h)';

  @override
  String get bmiCalculator => 'BMI Calculator';

  @override
  String get bmiCategory => 'Category';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal Weight';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obesity';

  @override
  String get enterHeightCm => 'Enter height (cm)';

  @override
  String get enterGoalWeightKg => 'Enter goal weight (kg)';

  @override
  String get fastingStats => 'Fasting Stats';

  @override
  String get fastingStatsCurrentStreak => 'Current Streak';

  @override
  String get fastingStatsDay => 'Day';

  @override
  String get fastingStatsDays => 'Days';

  @override
  String get fastingStatsTotalFasts => 'Total Fasts';

  @override
  String get fastingStatsTotalHours => 'Total Hours';

  @override
  String get fastingStatsAvgFast => 'Average Fast';

  @override
  String get fastingStatsHours => 'Hours';

  @override
  String get onboardingWelcomeTitle => 'Welcome!';

  @override
  String get onboardingWelcomeDesc => 'Start your journey to health. Let\'s set up your profile.';

  @override
  String get onboardingGoalTitle => 'What are your goals?';

  @override
  String get onboardingGoalDesc => 'Set your height and goal weight so we can calculate your BMI.';

  @override
  String get onboardingPlanTitle => 'Choose your plan';

  @override
  String get onboardingPlanDesc => 'Which fasting plan would you like to start with? You can always change it later.';

  @override
  String get onboardingCurrentWeight => 'Your current weight';

  @override
  String get getStarted => 'Get Started';

  @override
  String get currentStage => 'Current Stage';

  @override
  String get nextStage => 'Next';

  @override
  String get stageAnabolicTitle => 'Anabolic (Fed)';

  @override
  String get stageAnabolicDesc => 'Your body is digesting and using glucose for energy. Cell growth is active.';

  @override
  String get stageCatabolicTitle => 'Catabolic';

  @override
  String get stageCatabolicDesc => 'Blood sugar levels fall. Your body begins to use stored glycogen from the liver.';

  @override
  String get stageKetosisTitle => 'Ketosis';

  @override
  String get stageKetosisDesc => 'Glycogen stores are depleted. Your body switches to burning fat as its primary fuel.';

  @override
  String get stageAutophagyTitle => 'Autophagy';

  @override
  String get stageAutophagyDesc => 'The cellular cleanup process begins. Your body recycles old and damaged cell components.';

  @override
  String get stagePeakAutophagyTitle => 'Peak Autophagy';

  @override
  String get stagePeakAutophagyDesc => 'The autophagy process reaches its peak, maximizing cellular renewal.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsUnlocked => 'Unlocked';

  @override
  String get achievementsLocked => 'Locked';

  @override
  String achEarnedOn(Object date) {
    return 'Earned on $date';
  }

  @override
  String get achFirstFastTitle => 'First Fast!';

  @override
  String get achFirstFastDesc => 'Complete your first fast.';

  @override
  String get achStreak3Title => 'Getting Started';

  @override
  String get achStreak3Desc => 'Maintain a 3-day streak.';

  @override
  String get achStreak7Title => 'Consistent';

  @override
  String get achStreak7Desc => 'Maintain a 7-day streak.';

  @override
  String get achTotal10Title => 'Novice';

  @override
  String get achTotal10Desc => 'Complete 10 fasts.';

  @override
  String get achTotalHours100Title => '100 Hour Club';

  @override
  String get achTotalHours100Desc => 'Fast for a total of 100 hours.';

  @override
  String get journalTitle => 'Journal Note';

  @override
  String get journalHint => 'How did you feel during this fast?';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get syncHealthTitle => 'Sync with Health App';

  @override
  String get syncHealthDesc => 'Automatically write fasting data and read weight.';

  @override
  String get shareProgress => 'Share Progress';

  @override
  String get metricPhase => 'Phase';

  @override
  String get metricStreak => 'Streak';

  @override
  String get metricStatus => 'Status';

  @override
  String get statusDigesting => 'Digesting';

  @override
  String get statusStable => 'Stable';

  @override
  String get statusFatBurn => 'Fat Burn';

  @override
  String get statusKetosis => 'Ketosis';

  @override
  String get statusNormal => 'Normal';

  @override
  String get titleCurrentPhase => 'Current Phase';

  @override
  String get valFastingZone => 'Fasting Zone';

  @override
  String get valEatingWindow => 'Eating Window';

  @override
  String get descFastingZone => 'You are currently in the fasting window. No calories should be consumed.';

  @override
  String get descEatingWindow => 'You are in your eating window. Focus on nutrient-dense foods.';

  @override
  String get titleConsistencyStreak => 'Consistency Streak';

  @override
  String valStreakDays(int days) {
    return '$days Days 🔥';
  }

  @override
  String descStreak(int days) {
    return 'You\'ve hit your fasting goal for $days consecutive days. Keep it up to build a habit!';
  }

  @override
  String get titleBodyStatus => 'Body Status';

  @override
  String get descDigesting => 'Your body is currently digesting food and replenishing glycogen stores. Insulin levels are rising.';

  @override
  String get descStable => 'Your blood sugar levels are normalizing. The body is preparing to switch from glucose to fat for fuel.';

  @override
  String get descFatBurn => 'Great job! Your body is starting to burn stored fat for energy. Growth hormone levels may start to increase.';

  @override
  String get descKetosis => 'Deep Ketosis! Your body is efficiently burning fat. Autophagy (cell cleaning) may be starting soon.';

  @override
  String get btnGotIt => 'Got it!';

  @override
  String get stage0_4 => 'Blood Sugar Rise';

  @override
  String get stage0_4_desc => 'Your body is digesting your last meal. Blood sugar and insulin levels go up.';

  @override
  String get stage4_8 => 'Blood Sugar Drop';

  @override
  String get stage4_8_desc => 'Insulin levels start to drop. Your body begins to use up stored glucose.';

  @override
  String get stage8_12 => 'Normalization';

  @override
  String get stage8_12_desc => 'Digestive system rests. Your body starts healing and cleaning itself.';

  @override
  String get stage12_16 => 'Fat Burning';

  @override
  String get stage12_16_desc => 'Insulin is low. Your body starts burning stored fat for energy.';

  @override
  String get stage16_18 => 'Ketosis';

  @override
  String get stage16_18_desc => 'Fat burning accelerates. You are in full fat-burning mode.';

  @override
  String get stage18_24 => 'Autophagy';

  @override
  String get stage18_24_desc => 'Cellular cleanup begins. Your body recycles old and damaged cells.';

  @override
  String get stage24_plus => 'Deep Repair';

  @override
  String get stage24_plus_desc => 'Growth hormone levels increase. Significant cellular regeneration occurs.';

  @override
  String get viewTimeline => 'View Body Timeline';

  @override
  String get navFood => 'Food';

  @override
  String get circadianEnabled => 'Circadian mode enabled';

  @override
  String get circadianDisabled => 'Circadian mode disabled';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabKnowledge => 'Knowledge';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryKeto => 'Keto';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryVegan => 'Vegan';

  @override
  String recipeTime(int minutes) {
    return '$minutes min';
  }

  @override
  String get waterSettings => 'Water Settings';

  @override
  String get removeCup => 'Remove Cup (-1)';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get bmiScore => 'BMI Score';

  @override
  String bmiDescription(int height, String weight) {
    return 'Based on your height ($height cm) and weight ($weight kg).';
  }

  @override
  String get onboardingTitle => 'Let\'s personalize\nyour journey';

  @override
  String get onboardingHeightTitle => 'What is your height?';

  @override
  String get onboardingHeightDesc => 'We need this to calibrate the Body Visualizer and calculate your health metrics accurately.';

  @override
  String get onboardingWeightTitle => 'What is your weight?';

  @override
  String get onboardingWeightDesc => 'This helps us track your progress and adjust your fasting plan dynamically.';

  @override
  String get btnNext => 'Next';

  @override
  String get btnFinish => 'Start Journey';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get statsSuccessRate => 'Success Rate';

  @override
  String statsSuccessDesc(int success, int total) {
    return '$success of $total fasts were 16h+';
  }

  @override
  String get statsTotalFasts => 'Total Fasts';

  @override
  String get statsTotalHours => 'Total Hours';

  @override
  String get statsAverage => 'Average';

  @override
  String get statsLongest => 'Longest';

  @override
  String get circadianTitle => 'Circadian Rhythm';

  @override
  String get circadianIntroTitle => 'Eat with the Sun ☀️';

  @override
  String get circadianIntroDesc => 'Your metabolism is linked to the sun.\n\n• Sunrise: Best time to wake up and hydrate.\n• Daytime: High metabolism. Ideal for eating.\n• Sunset: Metabolism slows down. Stop eating.\n• Night: Deep repair mode. Fasting is effortless.\n\nThis mode automatically adjusts your fasting goals to sunrise and sunset times in your location.';

  @override
  String get circadianBtnEnable => 'Enable Circadian Mode';

  @override
  String get circadianBtnDisable => 'Disable';

  @override
  String get circadianTargetSunrise => 'Until Sunrise';

  @override
  String get circadianTargetSunset => 'Until Sunset';

  @override
  String get circadianPhaseDay => 'Daytime (Eat)';

  @override
  String get circadianPhaseNight => 'Nighttime (Fast)';

  @override
  String get circadianWarnDayTitle => 'It\'s Daytime ☀️';

  @override
  String get circadianWarnDayDesc => 'The sun is up! Your body is ready for food. Ideally, wait until sunset to start fasting.';

  @override
  String get circadianWarnBtnStart => 'Start Anyway';

  @override
  String get circadianWarnBtnWait => 'Wait for Sunset';

  @override
  String get circadianBonusTime => 'Bonus Time 🔥';

  @override
  String get circadianSyncing => 'Syncing with the Sun...';

  @override
  String get circadianError => 'Could not get location. Using standard timer.';

  @override
  String get circadianManaged => 'Solar Controlled';
}
