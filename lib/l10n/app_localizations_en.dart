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
  String get proTitle => 'GET PRO';

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
  String get termsOfService => 'Terms of Use';

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
  String get guestUser => 'Guest User';

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
  String get authSubtitle => 'Sign in to sync data';

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
  String get achFirstFastDesc => 'Complete your first fasting session.';

  @override
  String get achStreak3Title => 'Getting Started';

  @override
  String get achStreak3Desc => 'Maintain a 3-day fasting streak.';

  @override
  String get achStreak7Title => 'Consistent';

  @override
  String get achStreak7Desc => 'Reach a 7-day streak.';

  @override
  String get achTotal10Title => 'Novice';

  @override
  String get achTotal10Desc => 'Complete 10 total fasts.';

  @override
  String get achTotalHours100Title => '100 Hour Club';

  @override
  String get achTotalHours100Desc => 'Accumulate 100 hours of fasting.';

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
  String get onboardingTitle => 'Personalize Your Plan';

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

  @override
  String get notifBio4hTitle => 'Blood Sugar Stabilized 🩸';

  @override
  String get notifBio4hBody => 'Your insulin levels are dropping. False hunger pangs may disappear.';

  @override
  String get notifBio8hTitle => 'Stomach is Empty ✅';

  @override
  String get notifBio8hBody => 'Digestion is complete. Your body is shifting into repair mode.';

  @override
  String get notifBio12hTitle => 'Entering Ketosis 🔥';

  @override
  String get notifBio12hBody => 'Your body has started burning stored fat for energy!';

  @override
  String get notifBio16hTitle => 'Fat Burning Peak ⚡️';

  @override
  String get notifBio16hBody => 'Metabolism is accelerated. You are in the intense burning zone.';

  @override
  String get notifBio18hTitle => 'Autophagy Started ♻️';

  @override
  String get notifBio18hBody => 'Cellular cleaning active. Your body is recycling old cells.';

  @override
  String get notifBio24hTitle => 'HGH Spike 🛡';

  @override
  String get notifBio24hBody => 'Growth hormone levels are up to protect your muscles.';

  @override
  String get notifProg50Title => 'Halfway There! 🚀';

  @override
  String get notifProg50Body => 'You passed 50% of your goal. Keep going!';

  @override
  String get notifProg1hTitle => '1 Hour Left ⏳';

  @override
  String get notifProg1hBody => 'Almost done! You can start preparing your meal.';

  @override
  String get notifProgFinishTitle => 'Goal Reached! 🏆';

  @override
  String get notifProgFinishBody => 'You did it! Don\'t forget to stop the timer.';

  @override
  String get notifWaterTitle => 'Drink Water 💧';

  @override
  String get notifWaterBody => 'Hydration boosts your metabolism and reduces hunger.';

  @override
  String get notifWeightTitle => 'Morning Weigh-in ⚖️';

  @override
  String get notifWeightBody => 'Morning is the best time to track your weight.';

  @override
  String get permTitle => 'Enable Permissions';

  @override
  String get permDesc => 'To give you the best experience, Fastable needs access to notifications and health data.';

  @override
  String get permNotifTitle => 'Notifications';

  @override
  String get permNotifDesc => 'Stay on track with fasting alerts.';

  @override
  String get permHealthTitle => 'Apple Health';

  @override
  String get permHealthDesc => 'Sync weight & water data.';

  @override
  String get permAllow => 'Allow';

  @override
  String get permContinue => 'Continue';

  @override
  String get achFirstFast => 'First Step';

  @override
  String get achStreak3 => 'Consistency';

  @override
  String get achStreak7 => 'Unstoppable';

  @override
  String get achTotal10 => 'Dedicated';

  @override
  String get achTotalHours100 => 'Centurion';

  @override
  String get onboardingDesc => 'Let\'s calculate your metabolic rate.';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnStart => 'Start Journey';

  @override
  String get selectGender => 'Gender';

  @override
  String get selectAge => 'Age';

  @override
  String get selectWeight => 'Weight';

  @override
  String get selectHeight => 'Height';

  @override
  String get selectActivity => 'Activity Level';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityActive => 'Very Active';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get metabolicProfile => 'Metabolic Profile';

  @override
  String ageYears(int age) {
    return '$age y.o.';
  }

  @override
  String get metricBmrTitle => 'BMR';

  @override
  String get metricBmrSubtitle => 'Basal';

  @override
  String get metricBmrDesc => 'Basal Metabolic Rate. Calories burned at complete rest.';

  @override
  String get metricTdeeTitle => 'TDEE';

  @override
  String get metricTdeeSubtitle => 'Maintenance';

  @override
  String get metricTdeeDesc => 'Total Daily Energy Expenditure. Calories needed to maintain current weight.';

  @override
  String get dialogStartTitle => 'When did your fast start?';

  @override
  String get btnStartFasting => 'Start Fasting';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get stage2Title => 'Blood sugar is dropping 📉';

  @override
  String get stage2Body => 'Your body is calming down. If you feel hungry, drink some water. 💧';

  @override
  String get stage4Title => 'Insulin is dropping ⬇️';

  @override
  String get stage4Body => 'Great! Your body stops storing fat and starts preparing to burn it.';

  @override
  String get stage8Title => 'Cleanup started ✨';

  @override
  String get stage8Body => '8 hours in. Your stomach is resting. You are doing great for your health!';

  @override
  String get stage11Title => 'Fat Burning Mode 🔥';

  @override
  String get stage11Body => 'The fun part begins! Your body switches to internal reserves.';

  @override
  String get stage12Title => 'Ketosis Activated 🚀';

  @override
  String get stage12Body => 'Fat cells are turning into energy. Your mind is clearer now.';

  @override
  String get stage14Title => 'Deep Ketosis 🔥';

  @override
  String get stage14Body => 'You are in the fat-burning zone! Detox is happening fast now.';

  @override
  String get stage16Title => 'Autophagy (Cell Repair) 🧬';

  @override
  String get stage16Body => 'Your cells are renewing themselves. This is the fountain of youth!';

  @override
  String get stage18Title => 'Growth Hormone Peak 📈';

  @override
  String get stage18Body => 'Growth hormone helps muscle and burns fat. You are getting stronger!';

  @override
  String get stage24Title => '24 Hours! 🏆';

  @override
  String get stage24Body => 'Incredible! Full day complete. Deep cleaning is in full effect.';

  @override
  String get notifyHalfwayTitle => 'Halfway there! ⛰️';

  @override
  String get notifyHalfwayBody => 'The hardest part is over. Your body thanks you.';

  @override
  String get notify1hTitle => 'Home Stretch! 🏁';

  @override
  String get notify1hBody => 'Only 1 hour left. You are doing amazing!';

  @override
  String get notifyGoalTitle => 'Goal Reached! 🎉';

  @override
  String get notifyGoalBody => 'Congratulations! Break your fast gently.';

  @override
  String get notifyEatCloseTitle => 'Eating window closing 🛑';

  @override
  String get notifyEatCloseBody => 'Time to start your next fast. Check the app!';

  @override
  String get notifyEat30mTitle => '30 mins left 🥗';

  @override
  String get notifyEat30mBody => 'Don\'t forget to drink water or eat a last snack.';

  @override
  String get learnTitle => 'Learn & Eat';

  @override
  String get tabArticles => 'Articles';

  @override
  String get catBasics => 'Basics';

  @override
  String get catNutrition => 'Nutrition';

  @override
  String get catHealth => 'Health';

  @override
  String get catKeto => 'Keto';

  @override
  String get headerLatestArticles => 'Latest Articles';

  @override
  String get headerHealthyChoices => 'Healthy Choices';

  @override
  String get statusNoArticles => 'No articles found.';

  @override
  String get msgComingSoon => 'Coming soon...';

  @override
  String get learnBannerTitle => 'Unlock 500+ Recipes';

  @override
  String get learnBannerSubtitle => 'Get full access with PRO';

  @override
  String get labelPremium => 'PREMIUM';

  @override
  String get bannerRecipeTitle => 'Healthy Recipes';

  @override
  String get bannerRecipeSubtitle => 'Keto, Low-Carb & More';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitMin => 'min';

  @override
  String get lblAchievements => 'Achievements';

  @override
  String get lblPersonalData => 'Personal Data';

  @override
  String get lblSettings => 'Settings';

  @override
  String get lblAbout => 'About';

  @override
  String get lblHeight => 'Height';

  @override
  String get lblWeight => 'Weight';

  @override
  String get lblAge => 'Age';

  @override
  String get lblGender => 'Gender';

  @override
  String get lblActivity => 'Activity Level';

  @override
  String get lblLanguage => 'Language';

  @override
  String get msgHealthSyncEnabled => 'Health Sync Enabled!';

  @override
  String get msgHealthSyncFailed => 'Permission denied';

  @override
  String get aiGreeting => 'Hello! I\'m Fasty 🥑. How can I help you achieve your goals today?';

  @override
  String get aiConnectionError => 'Oops! I lost connection. Please check your internet or try again later. 🥑';

  @override
  String get aiSystemError => 'AI Service is not configured properly (Missing API Key).';

  @override
  String get aiCoachTitle => 'AI Fasting Coach';

  @override
  String get aiCoachDesc => 'Get instant answers about Keto, Intermittent Fasting, and healthy habits from our smart AI assistant.';

  @override
  String get aiChatHint => 'Ask about keto or fasting...';

  @override
  String get btnUnlockPro => 'Unlock with PRO';

  @override
  String get aiInsightFallback => 'Consistency is key! Drink water and keep moving. 💧';

  @override
  String get aiErrorConnection => 'Connection issue. Please try again later.';

  @override
  String get aiInsightTitle => 'DAILY INSIGHT';

  @override
  String get aiInsightTeaser => 'Based on your last 7 days of fasting, we found a significant pattern that affects your progress...';

  @override
  String get tapToUnlock => 'Tap to Unlock';

  @override
  String get notifyAiInsightTitle => 'Your Daily AI Insight is Ready! 🥑';

  @override
  String get notifyAiInsightBody => 'Check what Fasty has analyzed for you today. Tap to unlock.';

  @override
  String get notifyWeightTitle => 'Track your weight ⚖️';

  @override
  String get notifyWeightBody => 'Consistency is key! Log your weight today.';

  @override
  String get aiInsightNotEnoughData => 'Keep tracking! We need at least 3 fasts to analyze your unique patterns. 📊';

  @override
  String msgLoginFailed(Object error) {
    return 'Login failed: $error';
  }

  @override
  String msgAppleLoginFailed(Object error) {
    return 'Apple Login failed: $error';
  }

  @override
  String get msgSyncCompleted => 'Sync completed';

  @override
  String get msgErrorRelogin => 'Error: Please re-login and try again.';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get lblDangerZone => 'DANGER ZONE';

  @override
  String get btnDeleteAccount => 'Delete Account';

  @override
  String get dialogDeleteAccountTitle => 'Delete Account?';

  @override
  String get dialogDeleteAccountContent => 'This action is permanent. All your weight history, fasting records, and achievements will be deleted from the cloud.';

  @override
  String get btnDelete => 'DELETE';

  @override
  String get dialogSyncConflictTitle => 'Sync Conflict';

  @override
  String get dialogSyncConflictContent => 'Cloud data found. Merge with local data or overwrite?';

  @override
  String get btnUseCloud => 'Use Cloud\n(Discard Guest)';

  @override
  String get btnMergeData => 'Merge Data';

  @override
  String lblVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get lblCurrentWeight => 'Current Weight';

  @override
  String get lblBasalBmr => 'Basal (BMR)';

  @override
  String get lblActiveTdee => 'Active (TDEE)';

  @override
  String get lblTotalHours => 'Total Hours';

  @override
  String get unitHoursShort => 'h';

  @override
  String get lblConsistency => 'Consistency';

  @override
  String get lblLast7Days => 'Last 7 Days';

  @override
  String get lblFasts => 'Fasts';

  @override
  String get lblHours => 'Hours';

  @override
  String get lblDayStreak => 'Day Streak';

  @override
  String get msgStartJourney => 'Start your journey today';

  @override
  String get lblToday => 'Today';

  @override
  String get lblYesterday => 'Yesterday';

  @override
  String get lblFastingTypeCircadian => 'Circadian';

  @override
  String get lblFastingTypeWarrior => 'Warrior';

  @override
  String get lblFastingTypeOmad => 'OMAD';

  @override
  String lblHistoryFor(Object date) {
    return 'History for $date';
  }

  @override
  String get lblNoRecordsForDay => 'No records for this day';

  @override
  String get lblCustomPlan => 'Custom Plan';

  @override
  String get lblAdjustDuration => 'Adjust Duration';

  @override
  String get lblFasting => 'Fasting';

  @override
  String get lblEating => 'Eating';

  @override
  String get lblSlideToAdjust => 'Slide to adjust hours';

  @override
  String get btnStartCustomPlan => 'Start Custom Plan';

  @override
  String get btnUnlockFeature => 'Unlock Custom Plan';

  @override
  String get proFeatureTitle => 'Pro Feature';

  @override
  String get proFeatureDesc => 'Custom fasting schedules are available for Pro users.';

  @override
  String get setFastingGoal => 'Set Fasting Goal';

  @override
  String get fastingSaved => 'Fasting saved! 🏆';

  @override
  String get whenStopEating => 'When did you stop eating?';

  @override
  String get editTime => 'Edit Time';

  @override
  String get customPlan => 'Custom';

  @override
  String get tapToEdit => 'Tap to set goal';

  @override
  String get timeLeft => 'LEFT';

  @override
  String get maxBenefits => 'Maximum Benefits Reached';

  @override
  String get appNameUpper => 'FASTABLE';

  @override
  String get splashSlogan => 'Unlock your body\'s potential';

  @override
  String get weightSaved => 'Weight saved';

  @override
  String get proSubtitle => 'Unlock your full potential';

  @override
  String get featureCoach => 'Personal AI Coach';

  @override
  String get featureCoachDesc => 'Ask questions, get advice 24/7';

  @override
  String get featureRecipes => 'Healthy Recipes';

  @override
  String get featureRecipesDesc => 'Keto, Low-Carb & more';

  @override
  String get featureNoAds => 'No Ads, Pure Focus';

  @override
  String get featureNoAdsDesc => 'Distraction-free experience';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get loadingOffers => 'Loading offers...';

  @override
  String get welcomePro => 'Welcome to Pro! 🌟';

  @override
  String get errorPro => 'Something went wrong';

  @override
  String get confirmDeleteMsg => 'This action cannot be undone. All your data will be lost.';

  @override
  String get statusLocked => 'Locked';

  @override
  String get sectionLegal => 'Legal & Support';

  @override
  String get btnOverwriteLocal => 'Overwrite Local';

  @override
  String get msgDeleteError => 'Error deleting account';

  @override
  String get stepLanguage => 'Select Language';

  @override
  String get stepBodyMetrics => 'Body Metrics';

  @override
  String get stepBodyMetricsDesc => 'Help us calculate your BMI & goals';

  @override
  String get activityHint => 'Used to calculate your daily energy burn.';

  @override
  String get activitySedentaryDesc => 'Office job, little exercise';

  @override
  String get activityModerateDesc => 'Active job or exercise 3-4x';

  @override
  String get activityActiveDesc => 'Physical job or daily training';

  @override
  String get stepGoal => 'Choose Your Goal';

  @override
  String get recommendationMsg => 'We recommend the 16-8 plan for you.';

  @override
  String get planBeginner => 'Beginner';

  @override
  String get planPopular => 'Popular (16:8)';

  @override
  String get planAdvanced => 'Advanced (18:6)';

  @override
  String get planExpert => 'Expert (OMAD)';

  @override
  String get labelRecommended => 'RECOMMENDED';

  @override
  String get permHealthConnect => 'Health Connect';

  @override
  String get permHealthConnectDesc => 'Sync weight & steps with Google Fit';
}
