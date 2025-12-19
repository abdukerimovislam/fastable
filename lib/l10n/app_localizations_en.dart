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
  String get fastComplete => 'Fasting Complete!';

  @override
  String fastCompleteDesc(String duration) {
    return 'You have successfully fasted for $duration. Save this record?';
  }

  @override
  String get noFastsOnDay => 'No fasts completed on this day.';

  @override
  String get detailsFor => 'Details for';

  @override
  String get endCyclePrompt => 'End Eating Window?';

  @override
  String get endCyclePromptDesc => 'This will finish your current cycle and reset the timer.';

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
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

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
}
