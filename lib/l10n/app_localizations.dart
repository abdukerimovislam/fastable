import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fastable'**
  String get appTitle;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverview;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get navAchievements;

  /// No description provided for @navPro.
  ///
  /// In en, this message translates to:
  /// **'Fastable PRO'**
  String get navPro;

  /// No description provided for @fastingPhase.
  ///
  /// In en, this message translates to:
  /// **'Fasting Phase'**
  String get fastingPhase;

  /// No description provided for @eatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Eating Window'**
  String get eatingWindow;

  /// No description provided for @readyToFast.
  ///
  /// In en, this message translates to:
  /// **'Ready to Fast'**
  String get readyToFast;

  /// No description provided for @autophagyZone.
  ///
  /// In en, this message translates to:
  /// **'Autophagy Zone'**
  String get autophagyZone;

  /// No description provided for @startFast.
  ///
  /// In en, this message translates to:
  /// **'Start Fasting'**
  String get startFast;

  /// No description provided for @endFast.
  ///
  /// In en, this message translates to:
  /// **'End Fasting'**
  String get endFast;

  /// No description provided for @endCycle.
  ///
  /// In en, this message translates to:
  /// **'End Cycle'**
  String get endCycle;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @targetGoal.
  ///
  /// In en, this message translates to:
  /// **'Target Goal'**
  String get targetGoal;

  /// No description provided for @waterTracker.
  ///
  /// In en, this message translates to:
  /// **'Water Tracker'**
  String get waterTracker;

  /// No description provided for @waterCups.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get waterCups;

  /// No description provided for @addWater.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get addWater;

  /// No description provided for @waterToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Water'**
  String get waterToday;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @cups.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get cups;

  /// No description provided for @cupsUnit.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get cupsUnit;

  /// No description provided for @weightTracker.
  ///
  /// In en, this message translates to:
  /// **'Weight Tracker'**
  String get weightTracker;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// No description provided for @saveWeight.
  ///
  /// In en, this message translates to:
  /// **'Save Weight'**
  String get saveWeight;

  /// No description provided for @weightJourney.
  ///
  /// In en, this message translates to:
  /// **'Weight Journey'**
  String get weightJourney;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @fastingHours.
  ///
  /// In en, this message translates to:
  /// **'Fasting Hours'**
  String get fastingHours;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentWeight;

  /// No description provided for @goalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalWeight;

  /// No description provided for @startWeight.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startWeight;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add Weight'**
  String get addWeight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @chartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least two weight entries to see a graph.'**
  String get chartEmpty;

  /// No description provided for @proBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Fastable PRO'**
  String get proBannerTitle;

  /// No description provided for @proBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock analytics'**
  String get proBannerDesc;

  /// No description provided for @premiumContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Content'**
  String get premiumContentTitle;

  /// No description provided for @premiumContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock full access to all articles and features.'**
  String get premiumContentDesc;

  /// No description provided for @getPro.
  ///
  /// In en, this message translates to:
  /// **'Get PRO Access'**
  String get getPro;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Fastable Pro'**
  String get proTitle;

  /// No description provided for @proMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get proMonthly;

  /// No description provided for @proAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual Subscription (40% Off)'**
  String get proAnnual;

  /// No description provided for @unlockAll.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Features'**
  String get unlockAll;

  /// No description provided for @accessStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Access'**
  String get accessStatus;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active until {date}'**
  String statusActive(Object date);

  /// No description provided for @statusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get statusFree;

  /// No description provided for @proRequired.
  ///
  /// In en, this message translates to:
  /// **'A PRO subscription is required to view this content'**
  String get proRequired;

  /// No description provided for @proComingSoon.
  ///
  /// In en, this message translates to:
  /// **'PRO version is coming soon! Stay tuned.'**
  String get proComingSoon;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'mo.'**
  String get month;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get historyCalendar;

  /// No description provided for @historyLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get historyLog;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed fasts yet. Your history will show up here!'**
  String get historyEmpty;

  /// No description provided for @fastComplete.
  ///
  /// In en, this message translates to:
  /// **'Fast Complete! 🎉'**
  String get fastComplete;

  /// No description provided for @fastCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'You have fasted for {time}. Save this record?'**
  String fastCompleteDesc(String time);

  /// No description provided for @noFastsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No fasts completed on this day.'**
  String get noFastsOnDay;

  /// No description provided for @detailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for'**
  String get detailsFor;

  /// No description provided for @endCyclePrompt.
  ///
  /// In en, this message translates to:
  /// **'End Eating Window?'**
  String get endCyclePrompt;

  /// No description provided for @endCyclePromptDesc.
  ///
  /// In en, this message translates to:
  /// **'This will stop the eating timer and reset the cycle.'**
  String get endCyclePromptDesc;

  /// No description provided for @endFastPrompt.
  ///
  /// In en, this message translates to:
  /// **'End your current cycle to change the plan.'**
  String get endFastPrompt;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// No description provided for @settingWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Goal'**
  String get settingWaterGoal;

  /// No description provided for @settingHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get settingHeight;

  /// No description provided for @settingGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal Weight'**
  String get settingGoalWeight;

  /// No description provided for @settingTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @settingsHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get settingsHealthConnect;

  /// No description provided for @settingsSyncWeight.
  ///
  /// In en, this message translates to:
  /// **'Sync weight & steps'**
  String get settingsSyncWeight;

  /// No description provided for @healthConnectSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with Health Connect'**
  String get healthConnectSyncTitle;

  /// No description provided for @healthConnectDisclosureIntro.
  ///
  /// In en, this message translates to:
  /// **'Fastable requests READ and WRITE access to WEIGHT data via Health Connect.'**
  String get healthConnectDisclosureIntro;

  /// No description provided for @healthConnectDisclosureRead.
  ///
  /// In en, this message translates to:
  /// **'We use READ access to display your weight progress chart and stats based on historical data.'**
  String get healthConnectDisclosureRead;

  /// No description provided for @healthConnectDisclosureWrite.
  ///
  /// In en, this message translates to:
  /// **'We use WRITE access so you can save weight entries from Fastable to your phone\'s central database.'**
  String get healthConnectDisclosureWrite;

  /// No description provided for @healthConnectDisclosureSecure.
  ///
  /// In en, this message translates to:
  /// **'Data is stored locally and used only for weight tracking. You can revoke permissions at any time.'**
  String get healthConnectDisclosureSecure;

  /// No description provided for @healthConnectConnected.
  ///
  /// In en, this message translates to:
  /// **'Health Connect connected!'**
  String get healthConnectConnected;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notifyWater.
  ///
  /// In en, this message translates to:
  /// **'Water Reminders'**
  String get notifyWater;

  /// No description provided for @notifyWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reminded to drink water'**
  String get notifyWaterDesc;

  /// No description provided for @notifyWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight Reminder'**
  String get notifyWeight;

  /// No description provided for @notifyWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to weigh in'**
  String get notifyWeightDesc;

  /// No description provided for @notifyFastingStart.
  ///
  /// In en, this message translates to:
  /// **'Fasting Start'**
  String get notifyFastingStart;

  /// No description provided for @notifyFastingStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify when fasting window starts'**
  String get notifyFastingStartDesc;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfService;

  /// No description provided for @errorOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get errorOpenLink;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoading;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @tabFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get tabFasting;

  /// No description provided for @tabKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get tabKeto;

  /// No description provided for @tabPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get tabPartner;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @anonymousLogin.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Login'**
  String get anonymousLogin;

  /// No description provided for @dataOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Data saved on device'**
  String get dataOnDevice;

  /// No description provided for @connectGoogle.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Account'**
  String get connectGoogle;

  /// No description provided for @saveProgressCloud.
  ///
  /// In en, this message translates to:
  /// **'Save progress to cloud'**
  String get saveProgressCloud;

  /// No description provided for @accountLinked.
  ///
  /// In en, this message translates to:
  /// **'Account successfully linked!'**
  String get accountLinked;

  /// No description provided for @linkError.
  ///
  /// In en, this message translates to:
  /// **'Error linking account'**
  String get linkError;

  /// No description provided for @resetAndExit.
  ///
  /// In en, this message translates to:
  /// **'Reset Data & Exit'**
  String get resetAndExit;

  /// No description provided for @deleteAndExit.
  ///
  /// In en, this message translates to:
  /// **'Delete & Exit'**
  String get deleteAndExit;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmLogout;

  /// No description provided for @guestLogoutWarning.
  ///
  /// In en, this message translates to:
  /// **'You are using a Guest account. If you sign out, all local data will be deleted permanently.'**
  String get guestLogoutWarning;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will permanently delete all your data.'**
  String get deleteAccountWarning;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Modern Fasting'**
  String get authWelcome;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync data'**
  String get authSubtitle;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @continueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueGuest;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your fasting app!'**
  String get welcomeMessage;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get choosePlan;

  /// No description provided for @fastingPlan16_8.
  ///
  /// In en, this message translates to:
  /// **'16:8 Intermittent Fast'**
  String get fastingPlan16_8;

  /// No description provided for @fastingPlan18_6.
  ///
  /// In en, this message translates to:
  /// **'18:6 Intermittent Fast'**
  String get fastingPlan18_6;

  /// No description provided for @fastingPlan20_4.
  ///
  /// In en, this message translates to:
  /// **'20:4 The Warrior Diet'**
  String get fastingPlan20_4;

  /// No description provided for @fastingPlanEatStopEat.
  ///
  /// In en, this message translates to:
  /// **'Eat-Stop-Eat (24h)'**
  String get fastingPlanEatStopEat;

  /// No description provided for @bmiCalculator.
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get bmiCalculator;

  /// No description provided for @bmiCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bmiCategory;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Weight'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obesity'**
  String get bmiObese;

  /// No description provided for @enterHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Enter height (cm)'**
  String get enterHeightCm;

  /// No description provided for @enterGoalWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Enter goal weight (kg)'**
  String get enterGoalWeightKg;

  /// No description provided for @fastingStats.
  ///
  /// In en, this message translates to:
  /// **'Fasting Stats'**
  String get fastingStats;

  /// No description provided for @fastingStatsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get fastingStatsCurrentStreak;

  /// No description provided for @fastingStatsDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get fastingStatsDay;

  /// No description provided for @fastingStatsDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get fastingStatsDays;

  /// No description provided for @fastingStatsTotalFasts.
  ///
  /// In en, this message translates to:
  /// **'Total Fasts'**
  String get fastingStatsTotalFasts;

  /// No description provided for @fastingStatsTotalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get fastingStatsTotalHours;

  /// No description provided for @fastingStatsAvgFast.
  ///
  /// In en, this message translates to:
  /// **'Average Fast'**
  String get fastingStatsAvgFast;

  /// No description provided for @fastingStatsHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get fastingStatsHours;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to health. Let\'s set up your profile.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What are your goals?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your height and goal weight so we can calculate your BMI.'**
  String get onboardingGoalDesc;

  /// No description provided for @onboardingPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get onboardingPlanTitle;

  /// No description provided for @onboardingPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Which fasting plan would you like to start with? You can always change it later.'**
  String get onboardingPlanDesc;

  /// No description provided for @onboardingCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Your current weight'**
  String get onboardingCurrentWeight;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @currentStage.
  ///
  /// In en, this message translates to:
  /// **'Current Stage'**
  String get currentStage;

  /// No description provided for @nextStage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStage;

  /// No description provided for @stageAnabolicTitle.
  ///
  /// In en, this message translates to:
  /// **'Anabolic (Fed)'**
  String get stageAnabolicTitle;

  /// No description provided for @stageAnabolicDesc.
  ///
  /// In en, this message translates to:
  /// **'Your body is digesting and using glucose for energy. Cell growth is active.'**
  String get stageAnabolicDesc;

  /// No description provided for @stageCatabolicTitle.
  ///
  /// In en, this message translates to:
  /// **'Catabolic'**
  String get stageCatabolicTitle;

  /// No description provided for @stageCatabolicDesc.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar levels fall. Your body begins to use stored glycogen from the liver.'**
  String get stageCatabolicDesc;

  /// No description provided for @stageKetosisTitle.
  ///
  /// In en, this message translates to:
  /// **'Ketosis'**
  String get stageKetosisTitle;

  /// No description provided for @stageKetosisDesc.
  ///
  /// In en, this message translates to:
  /// **'Glycogen stores are depleted. Your body switches to burning fat as its primary fuel.'**
  String get stageKetosisDesc;

  /// No description provided for @stageAutophagyTitle.
  ///
  /// In en, this message translates to:
  /// **'Autophagy'**
  String get stageAutophagyTitle;

  /// No description provided for @stageAutophagyDesc.
  ///
  /// In en, this message translates to:
  /// **'The cellular cleanup process begins. Your body recycles old and damaged cell components.'**
  String get stageAutophagyDesc;

  /// No description provided for @stagePeakAutophagyTitle.
  ///
  /// In en, this message translates to:
  /// **'Peak Autophagy'**
  String get stagePeakAutophagyTitle;

  /// No description provided for @stagePeakAutophagyDesc.
  ///
  /// In en, this message translates to:
  /// **'The autophagy process reaches its peak, maximizing cellular renewal.'**
  String get stagePeakAutophagyDesc;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementsUnlocked;

  /// No description provided for @achievementsLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get achievementsLocked;

  /// No description provided for @achEarnedOn.
  ///
  /// In en, this message translates to:
  /// **'Earned on {date}'**
  String achEarnedOn(Object date);

  /// No description provided for @achFirstFastTitle.
  ///
  /// In en, this message translates to:
  /// **'First Fast!'**
  String get achFirstFastTitle;

  /// No description provided for @achFirstFastDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first fasting session.'**
  String get achFirstFastDesc;

  /// No description provided for @achStreak3Title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achStreak3Title;

  /// No description provided for @achStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 3-day fasting streak.'**
  String get achStreak3Desc;

  /// No description provided for @achStreak7Title.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get achStreak7Title;

  /// No description provided for @achStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day streak.'**
  String get achStreak7Desc;

  /// No description provided for @achTotal10Title.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get achTotal10Title;

  /// No description provided for @achTotal10Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 total fasts.'**
  String get achTotal10Desc;

  /// No description provided for @achTotalHours100Title.
  ///
  /// In en, this message translates to:
  /// **'100 Hour Club'**
  String get achTotalHours100Title;

  /// No description provided for @achTotalHours100Desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 100 hours of fasting.'**
  String get achTotalHours100Desc;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal Note'**
  String get journalTitle;

  /// No description provided for @journalHint.
  ///
  /// In en, this message translates to:
  /// **'How did you feel during this fast?'**
  String get journalHint;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @syncHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with Health App'**
  String get syncHealthTitle;

  /// No description provided for @syncHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically write fasting data and read weight.'**
  String get syncHealthDesc;

  /// No description provided for @shareProgress.
  ///
  /// In en, this message translates to:
  /// **'Share Progress'**
  String get shareProgress;

  /// No description provided for @metricPhase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get metricPhase;

  /// No description provided for @metricStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get metricStreak;

  /// No description provided for @metricStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get metricStatus;

  /// No description provided for @statusDigesting.
  ///
  /// In en, this message translates to:
  /// **'Digesting'**
  String get statusDigesting;

  /// No description provided for @statusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get statusStable;

  /// No description provided for @statusFatBurn.
  ///
  /// In en, this message translates to:
  /// **'Fat Burn'**
  String get statusFatBurn;

  /// No description provided for @statusKetosis.
  ///
  /// In en, this message translates to:
  /// **'Ketosis'**
  String get statusKetosis;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @titleCurrentPhase.
  ///
  /// In en, this message translates to:
  /// **'Current Phase'**
  String get titleCurrentPhase;

  /// No description provided for @valFastingZone.
  ///
  /// In en, this message translates to:
  /// **'Fasting Zone'**
  String get valFastingZone;

  /// No description provided for @valEatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Eating Window'**
  String get valEatingWindow;

  /// No description provided for @descFastingZone.
  ///
  /// In en, this message translates to:
  /// **'You are currently in the fasting window. No calories should be consumed.'**
  String get descFastingZone;

  /// No description provided for @descEatingWindow.
  ///
  /// In en, this message translates to:
  /// **'You are in your eating window. Focus on nutrient-dense foods.'**
  String get descEatingWindow;

  /// No description provided for @titleConsistencyStreak.
  ///
  /// In en, this message translates to:
  /// **'Consistency Streak'**
  String get titleConsistencyStreak;

  /// No description provided for @valStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Days 🔥'**
  String valStreakDays(int days);

  /// No description provided for @descStreak.
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit your fasting goal for {days} consecutive days. Keep it up to build a habit!'**
  String descStreak(int days);

  /// No description provided for @titleBodyStatus.
  ///
  /// In en, this message translates to:
  /// **'Body Status'**
  String get titleBodyStatus;

  /// No description provided for @descDigesting.
  ///
  /// In en, this message translates to:
  /// **'Your body is currently digesting food and replenishing glycogen stores. Insulin levels are rising.'**
  String get descDigesting;

  /// No description provided for @descStable.
  ///
  /// In en, this message translates to:
  /// **'Your blood sugar levels are normalizing. The body is preparing to switch from glucose to fat for fuel.'**
  String get descStable;

  /// No description provided for @descFatBurn.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your body is starting to burn stored fat for energy. Growth hormone levels may start to increase.'**
  String get descFatBurn;

  /// No description provided for @descKetosis.
  ///
  /// In en, this message translates to:
  /// **'Deep Ketosis! Your body is efficiently burning fat. Autophagy (cell cleaning) may be starting soon.'**
  String get descKetosis;

  /// No description provided for @btnGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get btnGotIt;

  /// No description provided for @stage0_4.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Rise'**
  String get stage0_4;

  /// No description provided for @stage0_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Your body is digesting your last meal. Blood sugar and insulin levels go up.'**
  String get stage0_4_desc;

  /// No description provided for @stage4_8.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Drop'**
  String get stage4_8;

  /// No description provided for @stage4_8_desc.
  ///
  /// In en, this message translates to:
  /// **'Insulin levels start to drop. Your body begins to use up stored glucose.'**
  String get stage4_8_desc;

  /// No description provided for @stage8_12.
  ///
  /// In en, this message translates to:
  /// **'Normalization'**
  String get stage8_12;

  /// No description provided for @stage8_12_desc.
  ///
  /// In en, this message translates to:
  /// **'Digestive system rests. Your body starts healing and cleaning itself.'**
  String get stage8_12_desc;

  /// No description provided for @stage12_16.
  ///
  /// In en, this message translates to:
  /// **'Fat Burning'**
  String get stage12_16;

  /// No description provided for @stage12_16_desc.
  ///
  /// In en, this message translates to:
  /// **'Insulin is low. Your body starts burning stored fat for energy.'**
  String get stage12_16_desc;

  /// No description provided for @stage16_18.
  ///
  /// In en, this message translates to:
  /// **'Ketosis'**
  String get stage16_18;

  /// No description provided for @stage16_18_desc.
  ///
  /// In en, this message translates to:
  /// **'Fat burning accelerates. You are in full fat-burning mode.'**
  String get stage16_18_desc;

  /// No description provided for @stage18_24.
  ///
  /// In en, this message translates to:
  /// **'Autophagy'**
  String get stage18_24;

  /// No description provided for @stage18_24_desc.
  ///
  /// In en, this message translates to:
  /// **'Cellular cleanup begins. Your body recycles old and damaged cells.'**
  String get stage18_24_desc;

  /// No description provided for @stage24_plus.
  ///
  /// In en, this message translates to:
  /// **'Deep Repair'**
  String get stage24_plus;

  /// No description provided for @stage24_plus_desc.
  ///
  /// In en, this message translates to:
  /// **'Growth hormone levels increase. Significant cellular regeneration occurs.'**
  String get stage24_plus_desc;

  /// No description provided for @viewTimeline.
  ///
  /// In en, this message translates to:
  /// **'View Body Timeline'**
  String get viewTimeline;

  /// No description provided for @navFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get navFood;

  /// No description provided for @circadianEnabled.
  ///
  /// In en, this message translates to:
  /// **'Circadian mode enabled'**
  String get circadianEnabled;

  /// No description provided for @circadianDisabled.
  ///
  /// In en, this message translates to:
  /// **'Circadian mode disabled'**
  String get circadianDisabled;

  /// No description provided for @tabRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get tabRecipes;

  /// No description provided for @tabKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get tabKnowledge;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get categoryKeto;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categoryVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get categoryVegan;

  /// No description provided for @recipeTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String recipeTime(int minutes);

  /// No description provided for @waterSettings.
  ///
  /// In en, this message translates to:
  /// **'Water Settings'**
  String get waterSettings;

  /// No description provided for @removeCup.
  ///
  /// In en, this message translates to:
  /// **'Remove Cup (-1)'**
  String get removeCup;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @bmiScore.
  ///
  /// In en, this message translates to:
  /// **'BMI Score'**
  String get bmiScore;

  /// No description provided for @bmiDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your height ({height} cm) and weight ({weight} kg).'**
  String bmiDescription(int height, String weight);

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Plan'**
  String get onboardingTitle;

  /// No description provided for @onboardingHeightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get onboardingHeightTitle;

  /// No description provided for @onboardingHeightDesc.
  ///
  /// In en, this message translates to:
  /// **'We need this to calibrate the Body Visualizer and calculate your health metrics accurately.'**
  String get onboardingHeightDesc;

  /// No description provided for @onboardingWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your weight?'**
  String get onboardingWeightTitle;

  /// No description provided for @onboardingWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'This helps us track your progress and adjust your fasting plan dynamically.'**
  String get onboardingWeightDesc;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnFinish.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get btnFinish;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @statsSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get statsSuccessRate;

  /// No description provided for @statsSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'{success} of {total} fasts were 16h+'**
  String statsSuccessDesc(int success, int total);

  /// No description provided for @statsTotalFasts.
  ///
  /// In en, this message translates to:
  /// **'Total Fasts'**
  String get statsTotalFasts;

  /// No description provided for @statsTotalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get statsTotalHours;

  /// No description provided for @statsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statsAverage;

  /// No description provided for @statsLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get statsLongest;

  /// No description provided for @circadianTitle.
  ///
  /// In en, this message translates to:
  /// **'Circadian Rhythm'**
  String get circadianTitle;

  /// No description provided for @circadianIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat with the Sun ☀️'**
  String get circadianIntroTitle;

  /// No description provided for @circadianIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Your metabolism is linked to the sun.\n\n• Sunrise: Best time to wake up and hydrate.\n• Daytime: High metabolism. Ideal for eating.\n• Sunset: Metabolism slows down. Stop eating.\n• Night: Deep repair mode. Fasting is effortless.\n\nThis mode automatically adjusts your fasting goals to sunrise and sunset times in your location.'**
  String get circadianIntroDesc;

  /// No description provided for @circadianBtnEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Circadian Mode'**
  String get circadianBtnEnable;

  /// No description provided for @circadianBtnDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get circadianBtnDisable;

  /// No description provided for @circadianTargetSunrise.
  ///
  /// In en, this message translates to:
  /// **'Until Sunrise'**
  String get circadianTargetSunrise;

  /// No description provided for @circadianTargetSunset.
  ///
  /// In en, this message translates to:
  /// **'Until Sunset'**
  String get circadianTargetSunset;

  /// No description provided for @circadianPhaseDay.
  ///
  /// In en, this message translates to:
  /// **'Daytime (Eat)'**
  String get circadianPhaseDay;

  /// No description provided for @circadianPhaseNight.
  ///
  /// In en, this message translates to:
  /// **'Nighttime (Fast)'**
  String get circadianPhaseNight;

  /// No description provided for @circadianWarnDayTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s Daytime ☀️'**
  String get circadianWarnDayTitle;

  /// No description provided for @circadianWarnDayDesc.
  ///
  /// In en, this message translates to:
  /// **'The sun is up! Your body is ready for food. Ideally, wait until sunset to start fasting.'**
  String get circadianWarnDayDesc;

  /// No description provided for @circadianWarnBtnStart.
  ///
  /// In en, this message translates to:
  /// **'Start Anyway'**
  String get circadianWarnBtnStart;

  /// No description provided for @circadianWarnBtnWait.
  ///
  /// In en, this message translates to:
  /// **'Wait for Sunset'**
  String get circadianWarnBtnWait;

  /// No description provided for @circadianBonusTime.
  ///
  /// In en, this message translates to:
  /// **'Bonus Time 🔥'**
  String get circadianBonusTime;

  /// No description provided for @circadianSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing with the Sun...'**
  String get circadianSyncing;

  /// No description provided for @circadianError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location. Using standard timer.'**
  String get circadianError;

  /// No description provided for @circadianManaged.
  ///
  /// In en, this message translates to:
  /// **'Solar Controlled'**
  String get circadianManaged;

  /// No description provided for @notifBio4hTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Stabilized 🩸'**
  String get notifBio4hTitle;

  /// No description provided for @notifBio4hBody.
  ///
  /// In en, this message translates to:
  /// **'Your insulin levels are dropping. False hunger pangs may disappear.'**
  String get notifBio4hBody;

  /// No description provided for @notifBio8hTitle.
  ///
  /// In en, this message translates to:
  /// **'Stomach is Empty ✅'**
  String get notifBio8hTitle;

  /// No description provided for @notifBio8hBody.
  ///
  /// In en, this message translates to:
  /// **'Digestion is complete. Your body is shifting into repair mode.'**
  String get notifBio8hBody;

  /// No description provided for @notifBio12hTitle.
  ///
  /// In en, this message translates to:
  /// **'Entering Ketosis 🔥'**
  String get notifBio12hTitle;

  /// No description provided for @notifBio12hBody.
  ///
  /// In en, this message translates to:
  /// **'Your body has started burning stored fat for energy!'**
  String get notifBio12hBody;

  /// No description provided for @notifBio16hTitle.
  ///
  /// In en, this message translates to:
  /// **'Fat Burning Peak ⚡️'**
  String get notifBio16hTitle;

  /// No description provided for @notifBio16hBody.
  ///
  /// In en, this message translates to:
  /// **'Metabolism is accelerated. You are in the intense burning zone.'**
  String get notifBio16hBody;

  /// No description provided for @notifBio18hTitle.
  ///
  /// In en, this message translates to:
  /// **'Autophagy Started ♻️'**
  String get notifBio18hTitle;

  /// No description provided for @notifBio18hBody.
  ///
  /// In en, this message translates to:
  /// **'Cellular cleaning active. Your body is recycling old cells.'**
  String get notifBio18hBody;

  /// No description provided for @notifBio24hTitle.
  ///
  /// In en, this message translates to:
  /// **'HGH Spike 🛡'**
  String get notifBio24hTitle;

  /// No description provided for @notifBio24hBody.
  ///
  /// In en, this message translates to:
  /// **'Growth hormone levels are up to protect your muscles.'**
  String get notifBio24hBody;

  /// No description provided for @notifProg50Title.
  ///
  /// In en, this message translates to:
  /// **'Halfway There! 🚀'**
  String get notifProg50Title;

  /// No description provided for @notifProg50Body.
  ///
  /// In en, this message translates to:
  /// **'You passed 50% of your goal. Keep going!'**
  String get notifProg50Body;

  /// No description provided for @notifProg1hTitle.
  ///
  /// In en, this message translates to:
  /// **'1 Hour Left ⏳'**
  String get notifProg1hTitle;

  /// No description provided for @notifProg1hBody.
  ///
  /// In en, this message translates to:
  /// **'Almost done! You can start preparing your meal.'**
  String get notifProg1hBody;

  /// No description provided for @notifProgFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached! 🏆'**
  String get notifProgFinishTitle;

  /// No description provided for @notifProgFinishBody.
  ///
  /// In en, this message translates to:
  /// **'You did it! Don\'t forget to stop the timer.'**
  String get notifProgFinishBody;

  /// No description provided for @notifWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Drink Water 💧'**
  String get notifWaterTitle;

  /// No description provided for @notifWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Hydration boosts your metabolism and reduces hunger.'**
  String get notifWaterBody;

  /// No description provided for @notifWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Weigh-in ⚖️'**
  String get notifWeightTitle;

  /// No description provided for @notifWeightBody.
  ///
  /// In en, this message translates to:
  /// **'Morning is the best time to track your weight.'**
  String get notifWeightBody;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Permissions'**
  String get permTitle;

  /// No description provided for @permDesc.
  ///
  /// In en, this message translates to:
  /// **'To give you the best experience, Fastable needs access to notifications and health data.'**
  String get permDesc;

  /// No description provided for @permNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifTitle;

  /// No description provided for @permNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay on track with fasting alerts.'**
  String get permNotifDesc;

  /// No description provided for @permHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get permHealthTitle;

  /// No description provided for @permHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync weight & water data.'**
  String get permHealthDesc;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permAllow;

  /// No description provided for @permContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permContinue;

  /// No description provided for @achFirstFast.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achFirstFast;

  /// No description provided for @achStreak3.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get achStreak3;

  /// No description provided for @achStreak7.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get achStreak7;

  /// No description provided for @achTotal10.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get achTotal10;

  /// No description provided for @achTotalHours100.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achTotalHours100;

  /// No description provided for @onboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s calculate your metabolic rate.'**
  String get onboardingDesc;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get btnStart;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get selectGender;

  /// No description provided for @selectAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get selectAge;

  /// No description provided for @selectWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get selectWeight;

  /// No description provided for @selectHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get selectHeight;

  /// No description provided for @selectActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get selectActivity;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get activityActive;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @metabolicProfile.
  ///
  /// In en, this message translates to:
  /// **'Metabolic Profile'**
  String get metabolicProfile;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} y.o.'**
  String ageYears(int age);

  /// No description provided for @metricBmrTitle.
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get metricBmrTitle;

  /// No description provided for @metricBmrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basal'**
  String get metricBmrSubtitle;

  /// No description provided for @metricBmrDesc.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate. Calories burned at complete rest.'**
  String get metricBmrDesc;

  /// No description provided for @metricTdeeTitle.
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get metricTdeeTitle;

  /// No description provided for @metricTdeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get metricTdeeSubtitle;

  /// No description provided for @metricTdeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy Expenditure. Calories needed to maintain current weight.'**
  String get metricTdeeDesc;

  /// No description provided for @dialogStartTitle.
  ///
  /// In en, this message translates to:
  /// **'When did your fast start?'**
  String get dialogStartTitle;

  /// No description provided for @btnStartFasting.
  ///
  /// In en, this message translates to:
  /// **'Start Fasting'**
  String get btnStartFasting;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @stage2Title.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar is dropping 📉'**
  String get stage2Title;

  /// No description provided for @stage2Body.
  ///
  /// In en, this message translates to:
  /// **'Your body is calming down. If you feel hungry, drink some water. 💧'**
  String get stage2Body;

  /// No description provided for @stage4Title.
  ///
  /// In en, this message translates to:
  /// **'Insulin is dropping ⬇️'**
  String get stage4Title;

  /// No description provided for @stage4Body.
  ///
  /// In en, this message translates to:
  /// **'Great! Your body stops storing fat and starts preparing to burn it.'**
  String get stage4Body;

  /// No description provided for @stage8Title.
  ///
  /// In en, this message translates to:
  /// **'Cleanup started ✨'**
  String get stage8Title;

  /// No description provided for @stage8Body.
  ///
  /// In en, this message translates to:
  /// **'8 hours in. Your stomach is resting. You are doing great for your health!'**
  String get stage8Body;

  /// No description provided for @stage11Title.
  ///
  /// In en, this message translates to:
  /// **'Fat Burning Mode 🔥'**
  String get stage11Title;

  /// No description provided for @stage11Body.
  ///
  /// In en, this message translates to:
  /// **'The fun part begins! Your body switches to internal reserves.'**
  String get stage11Body;

  /// No description provided for @stage12Title.
  ///
  /// In en, this message translates to:
  /// **'Ketosis Activated 🚀'**
  String get stage12Title;

  /// No description provided for @stage12Body.
  ///
  /// In en, this message translates to:
  /// **'Fat cells are turning into energy. Your mind is clearer now.'**
  String get stage12Body;

  /// No description provided for @stage14Title.
  ///
  /// In en, this message translates to:
  /// **'Deep Ketosis 🔥'**
  String get stage14Title;

  /// No description provided for @stage14Body.
  ///
  /// In en, this message translates to:
  /// **'You are in the fat-burning zone! Detox is happening fast now.'**
  String get stage14Body;

  /// No description provided for @stage16Title.
  ///
  /// In en, this message translates to:
  /// **'Autophagy (Cell Repair) 🧬'**
  String get stage16Title;

  /// No description provided for @stage16Body.
  ///
  /// In en, this message translates to:
  /// **'Your cells are renewing themselves. This is the fountain of youth!'**
  String get stage16Body;

  /// No description provided for @stage18Title.
  ///
  /// In en, this message translates to:
  /// **'Growth Hormone Peak 📈'**
  String get stage18Title;

  /// No description provided for @stage18Body.
  ///
  /// In en, this message translates to:
  /// **'Growth hormone helps muscle and burns fat. You are getting stronger!'**
  String get stage18Body;

  /// No description provided for @stage24Title.
  ///
  /// In en, this message translates to:
  /// **'24 Hours! 🏆'**
  String get stage24Title;

  /// No description provided for @stage24Body.
  ///
  /// In en, this message translates to:
  /// **'Incredible! Full day complete. Deep cleaning is in full effect.'**
  String get stage24Body;

  /// No description provided for @notifyHalfwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Halfway there! ⛰️'**
  String get notifyHalfwayTitle;

  /// No description provided for @notifyHalfwayBody.
  ///
  /// In en, this message translates to:
  /// **'The hardest part is over. Your body thanks you.'**
  String get notifyHalfwayBody;

  /// No description provided for @notify1hTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Stretch! 🏁'**
  String get notify1hTitle;

  /// No description provided for @notify1hBody.
  ///
  /// In en, this message translates to:
  /// **'Only 1 hour left. You are doing amazing!'**
  String get notify1hBody;

  /// No description provided for @notifyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached! 🎉'**
  String get notifyGoalTitle;

  /// No description provided for @notifyGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Break your fast gently.'**
  String get notifyGoalBody;

  /// No description provided for @notifyEatCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Eating window closing 🛑'**
  String get notifyEatCloseTitle;

  /// No description provided for @notifyEatCloseBody.
  ///
  /// In en, this message translates to:
  /// **'Time to start your next fast. Check the app!'**
  String get notifyEatCloseBody;

  /// No description provided for @notifyEat30mTitle.
  ///
  /// In en, this message translates to:
  /// **'30 mins left 🥗'**
  String get notifyEat30mTitle;

  /// No description provided for @notifyEat30mBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to drink water or eat a last snack.'**
  String get notifyEat30mBody;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn & Eat'**
  String get learnTitle;

  /// No description provided for @tabArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get tabArticles;

  /// No description provided for @catBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get catBasics;

  /// No description provided for @catNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get catNutrition;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get catKeto;

  /// No description provided for @headerLatestArticles.
  ///
  /// In en, this message translates to:
  /// **'Latest Articles'**
  String get headerLatestArticles;

  /// No description provided for @headerHealthyChoices.
  ///
  /// In en, this message translates to:
  /// **'Healthy Choices'**
  String get headerHealthyChoices;

  /// No description provided for @statusNoArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get statusNoArticles;

  /// No description provided for @msgComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get msgComingSoon;

  /// No description provided for @learnBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock 500+ Recipes'**
  String get learnBannerTitle;

  /// No description provided for @learnBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get full access with PRO'**
  String get learnBannerSubtitle;

  /// No description provided for @labelPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get labelPremium;

  /// No description provided for @bannerRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Healthy Recipes'**
  String get bannerRecipeTitle;

  /// No description provided for @bannerRecipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keto, Low-Carb & More'**
  String get bannerRecipeSubtitle;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// No description provided for @lblAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get lblAchievements;

  /// No description provided for @lblPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get lblPersonalData;

  /// No description provided for @lblSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get lblSettings;

  /// No description provided for @lblAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get lblAbout;

  /// No description provided for @lblHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get lblHeight;

  /// No description provided for @lblWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get lblWeight;

  /// No description provided for @lblAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get lblAge;

  /// No description provided for @lblGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get lblGender;

  /// No description provided for @lblActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get lblActivity;

  /// No description provided for @lblLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lblLanguage;

  /// No description provided for @msgHealthSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Health Sync Enabled!'**
  String get msgHealthSyncEnabled;

  /// No description provided for @msgHealthSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get msgHealthSyncFailed;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Fasty 🥑. How can I help you achieve your goals today?'**
  String get aiGreeting;

  /// No description provided for @aiConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Oops! I lost connection. Please check your internet or try again later. 🥑'**
  String get aiConnectionError;

  /// No description provided for @aiSystemError.
  ///
  /// In en, this message translates to:
  /// **'AI Service is not configured properly (Missing API Key).'**
  String get aiSystemError;

  /// No description provided for @aiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Fasting Coach'**
  String get aiCoachTitle;

  /// No description provided for @aiCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Get instant answers about Keto, Intermittent Fasting, and healthy habits from our smart AI assistant.'**
  String get aiCoachDesc;

  /// No description provided for @aiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about keto or fasting...'**
  String get aiChatHint;

  /// No description provided for @btnUnlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock with PRO'**
  String get btnUnlockPro;

  /// No description provided for @aiInsightFallback.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key! Drink water and keep moving. 💧'**
  String get aiInsightFallback;

  /// No description provided for @aiErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection issue. Please try again later.'**
  String get aiErrorConnection;

  /// No description provided for @aiInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY INSIGHT'**
  String get aiInsightTitle;

  /// No description provided for @aiInsightTeaser.
  ///
  /// In en, this message translates to:
  /// **'Based on your last 7 days of fasting, we found a significant pattern that affects your progress...'**
  String get aiInsightTeaser;

  /// No description provided for @tapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to Unlock'**
  String get tapToUnlock;

  /// No description provided for @notifyAiInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Daily AI Insight is Ready! 🥑'**
  String get notifyAiInsightTitle;

  /// No description provided for @notifyAiInsightBody.
  ///
  /// In en, this message translates to:
  /// **'Check what Fasty has analyzed for you today. Tap to unlock.'**
  String get notifyAiInsightBody;

  /// No description provided for @notifyWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your weight ⚖️'**
  String get notifyWeightTitle;

  /// No description provided for @notifyWeightBody.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key! Log your weight today.'**
  String get notifyWeightBody;

  /// No description provided for @aiInsightNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking! We need at least 3 fasts to analyze your unique patterns. 📊'**
  String get aiInsightNotEnoughData;

  /// No description provided for @msgLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String msgLoginFailed(Object error);

  /// No description provided for @msgAppleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple Login failed: {error}'**
  String msgAppleLoginFailed(Object error);

  /// No description provided for @msgSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get msgSyncCompleted;

  /// No description provided for @msgErrorRelogin.
  ///
  /// In en, this message translates to:
  /// **'Error: Please re-login and try again.'**
  String get msgErrorRelogin;

  /// No description provided for @signInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInApple;

  /// No description provided for @lblDangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get lblDangerZone;

  /// No description provided for @btnDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get btnDeleteAccount;

  /// No description provided for @dialogDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get dialogDeleteAccountTitle;

  /// No description provided for @dialogDeleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All your weight history, fasting records, and achievements will be deleted from the cloud.'**
  String get dialogDeleteAccountContent;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get btnDelete;

  /// No description provided for @dialogSyncConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Conflict'**
  String get dialogSyncConflictTitle;

  /// No description provided for @dialogSyncConflictContent.
  ///
  /// In en, this message translates to:
  /// **'Cloud data found. Merge with local data or overwrite?'**
  String get dialogSyncConflictContent;

  /// No description provided for @btnUseCloud.
  ///
  /// In en, this message translates to:
  /// **'Use Cloud\n(Discard Guest)'**
  String get btnUseCloud;

  /// No description provided for @btnMergeData.
  ///
  /// In en, this message translates to:
  /// **'Merge Data'**
  String get btnMergeData;

  /// No description provided for @lblVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String lblVersion(Object version);

  /// No description provided for @lblCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get lblCurrentWeight;

  /// No description provided for @lblBasalBmr.
  ///
  /// In en, this message translates to:
  /// **'Basal (BMR)'**
  String get lblBasalBmr;

  /// No description provided for @lblActiveTdee.
  ///
  /// In en, this message translates to:
  /// **'Active (TDEE)'**
  String get lblActiveTdee;

  /// No description provided for @lblTotalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get lblTotalHours;

  /// No description provided for @unitHoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHoursShort;

  /// No description provided for @lblConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get lblConsistency;

  /// No description provided for @lblLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lblLast7Days;

  /// No description provided for @lblFasts.
  ///
  /// In en, this message translates to:
  /// **'Fasts'**
  String get lblFasts;

  /// No description provided for @lblHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get lblHours;

  /// No description provided for @lblDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get lblDayStreak;

  /// No description provided for @msgStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey today'**
  String get msgStartJourney;

  /// No description provided for @lblToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get lblToday;

  /// No description provided for @lblYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get lblYesterday;

  /// No description provided for @confirmTime.
  ///
  /// In en, this message translates to:
  /// **'Confirm Time'**
  String get confirmTime;

  /// No description provided for @lblFastingTypeCircadian.
  ///
  /// In en, this message translates to:
  /// **'Circadian'**
  String get lblFastingTypeCircadian;

  /// No description provided for @lblFastingTypeWarrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get lblFastingTypeWarrior;

  /// No description provided for @lblFastingTypeOmad.
  ///
  /// In en, this message translates to:
  /// **'OMAD'**
  String get lblFastingTypeOmad;

  /// No description provided for @lblHistoryFor.
  ///
  /// In en, this message translates to:
  /// **'History for {date}'**
  String lblHistoryFor(Object date);

  /// No description provided for @lblNoRecordsForDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get lblNoRecordsForDay;

  /// No description provided for @lblCustomPlan.
  ///
  /// In en, this message translates to:
  /// **'Custom Plan'**
  String get lblCustomPlan;

  /// No description provided for @lblAdjustDuration.
  ///
  /// In en, this message translates to:
  /// **'Adjust Duration'**
  String get lblAdjustDuration;

  /// No description provided for @lblFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get lblFasting;

  /// No description provided for @lblEating.
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get lblEating;

  /// No description provided for @lblSlideToAdjust.
  ///
  /// In en, this message translates to:
  /// **'Slide to adjust hours'**
  String get lblSlideToAdjust;

  /// No description provided for @btnStartCustomPlan.
  ///
  /// In en, this message translates to:
  /// **'Start Custom Plan'**
  String get btnStartCustomPlan;

  /// No description provided for @btnUnlockFeature.
  ///
  /// In en, this message translates to:
  /// **'Unlock Custom Plan'**
  String get btnUnlockFeature;

  /// No description provided for @proFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeatureTitle;

  /// No description provided for @proFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Custom fasting schedules are available for Pro users.'**
  String get proFeatureDesc;

  /// No description provided for @setFastingGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Fasting Goal'**
  String get setFastingGoal;

  /// No description provided for @fastingSaved.
  ///
  /// In en, this message translates to:
  /// **'Fasting saved! 🏆'**
  String get fastingSaved;

  /// No description provided for @whenStopEating.
  ///
  /// In en, this message translates to:
  /// **'When did you stop eating?'**
  String get whenStopEating;

  /// No description provided for @editTime.
  ///
  /// In en, this message translates to:
  /// **'Edit Time'**
  String get editTime;

  /// No description provided for @customPlan.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customPlan;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to set goal'**
  String get tapToEdit;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'LEFT'**
  String get timeLeft;

  /// No description provided for @maxBenefits.
  ///
  /// In en, this message translates to:
  /// **'Maximum Benefits Reached'**
  String get maxBenefits;

  /// No description provided for @appNameUpper.
  ///
  /// In en, this message translates to:
  /// **'FASTABLE'**
  String get appNameUpper;

  /// No description provided for @splashSlogan.
  ///
  /// In en, this message translates to:
  /// **'Unlock your body\'s potential'**
  String get splashSlogan;

  /// No description provided for @weightSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight saved'**
  String get weightSaved;

  /// No description provided for @proSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to AI Coach & Recipes'**
  String get proSubtitle;

  /// No description provided for @featureCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach Fasty'**
  String get featureCoach;

  /// No description provided for @featureCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalized advice & motivation 24/7'**
  String get featureCoachDesc;

  /// No description provided for @featureRecipes.
  ///
  /// In en, this message translates to:
  /// **'Healthy Recipes'**
  String get featureRecipes;

  /// No description provided for @featureRecipesDesc.
  ///
  /// In en, this message translates to:
  /// **'Keto, Low-Carb & Fasting friendly meals'**
  String get featureRecipesDesc;

  /// No description provided for @featureNoAds.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get featureNoAds;

  /// No description provided for @featureNoAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on your goals without distractions'**
  String get featureNoAdsDesc;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @loadingOffers.
  ///
  /// In en, this message translates to:
  /// **'Loading offers...'**
  String get loadingOffers;

  /// No description provided for @welcomePro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pro! 🚀'**
  String get welcomePro;

  /// No description provided for @errorPro.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get errorPro;

  /// No description provided for @confirmDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be lost.'**
  String get confirmDeleteMsg;

  /// No description provided for @statusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get statusLocked;

  /// No description provided for @sectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get sectionLegal;

  /// No description provided for @btnOverwriteLocal.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Local'**
  String get btnOverwriteLocal;

  /// No description provided for @msgDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get msgDeleteError;

  /// No description provided for @msgDeleteReauthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Account deletion cancelled.'**
  String get msgDeleteReauthCancelled;

  /// No description provided for @msgDeleteReauthFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your identity. Please try again.'**
  String get msgDeleteReauthFailed;

  /// No description provided for @msgDeleteReauthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again with the original provider before deleting this account.'**
  String get msgDeleteReauthUnavailable;

  /// No description provided for @stepLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get stepLanguage;

  /// No description provided for @stepBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get stepBodyMetrics;

  /// No description provided for @stepBodyMetricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us calculate your BMI & goals'**
  String get stepBodyMetricsDesc;

  /// No description provided for @activityHint.
  ///
  /// In en, this message translates to:
  /// **'Used to calculate your daily energy burn.'**
  String get activityHint;

  /// No description provided for @activitySedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Office job, little exercise'**
  String get activitySedentaryDesc;

  /// No description provided for @activityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Active job or exercise 3-4x'**
  String get activityModerateDesc;

  /// No description provided for @activityActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical job or daily training'**
  String get activityActiveDesc;

  /// No description provided for @stepGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Goal'**
  String get stepGoal;

  /// No description provided for @recommendationMsg.
  ///
  /// In en, this message translates to:
  /// **'We recommend the 16-8 plan for you.'**
  String get recommendationMsg;

  /// No description provided for @planBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get planBeginner;

  /// No description provided for @planPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular (16:8)'**
  String get planPopular;

  /// No description provided for @planAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced (18:6)'**
  String get planAdvanced;

  /// No description provided for @planExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert (OMAD)'**
  String get planExpert;

  /// No description provided for @labelRecommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get labelRecommended;

  /// No description provided for @permHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get permHealthConnect;

  /// No description provided for @permHealthConnectDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync weight & steps with Google Fit'**
  String get permHealthConnectDesc;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get planAnnual;

  /// No description provided for @planLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'SAVE {percent}%'**
  String savePercent(String percent);

  /// No description provided for @medicalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer & Sources'**
  String get medicalDisclaimerTitle;

  /// No description provided for @medicalDisclaimerHeading.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimerHeading;

  /// No description provided for @medicalDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Fastable is designed to help you track your intermittent fasting and provide AI coaching based on general knowledge. It is NOT a medical device. The information provided is for educational purposes only and should not replace professional medical advice.\n\nPlease consult a doctor before starting any fasting regimen, especially if you are pregnant, nursing, diabetic, or have any other medical conditions.'**
  String get medicalDisclaimerBody;

  /// No description provided for @scientificSourcesHeading.
  ///
  /// In en, this message translates to:
  /// **'Scientific Sources & Citations'**
  String get scientificSourcesHeading;

  /// No description provided for @sourceJohnsHopkins.
  ///
  /// In en, this message translates to:
  /// **'Johns Hopkins Medicine'**
  String get sourceJohnsHopkins;

  /// No description provided for @sourceJohnsHopkinsDesc.
  ///
  /// In en, this message translates to:
  /// **'Intermittent Fasting: What is it, and how does it work?'**
  String get sourceJohnsHopkinsDesc;

  /// No description provided for @sourceMayoClinic.
  ///
  /// In en, this message translates to:
  /// **'Mayo Clinic'**
  String get sourceMayoClinic;

  /// No description provided for @sourceMayoClinicDesc.
  ///
  /// In en, this message translates to:
  /// **'Fasting diet: Can it improve my heart health?'**
  String get sourceMayoClinicDesc;

  /// No description provided for @sourceHarvard.
  ///
  /// In en, this message translates to:
  /// **'Harvard Medical School'**
  String get sourceHarvard;

  /// No description provided for @sourceHarvardDesc.
  ///
  /// In en, this message translates to:
  /// **'Intermittent fasting: Surprising update'**
  String get sourceHarvardDesc;

  /// No description provided for @legalAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to Apple\'s standard '**
  String get legalAgreementPrefix;

  /// No description provided for @legalTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get legalTermsOfUse;

  /// No description provided for @legalAgreementAnd.
  ///
  /// In en, this message translates to:
  /// **' and our '**
  String get legalAgreementAnd;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'We are working hard to prepare amazing content for you. Stay tuned!'**
  String get comingSoonDesc;

  /// No description provided for @statusNoRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get statusNoRecipes;

  /// No description provided for @aboutAndLegal.
  ///
  /// In en, this message translates to:
  /// **'About & Legal'**
  String get aboutAndLegal;

  /// No description provided for @settingsMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer & Sources'**
  String get settingsMedicalDisclaimer;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get settingsTermsOfUse;

  /// No description provided for @deleteAccountAndData.
  ///
  /// In en, this message translates to:
  /// **'Delete Account & Data'**
  String get deleteAccountAndData;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your fasting history and local data will be permanently deleted.'**
  String get deleteAccountContent;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @planExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get planExtended;

  /// No description provided for @zoneSugarRises.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Rises'**
  String get zoneSugarRises;

  /// No description provided for @zoneSugarRisesDesc.
  ///
  /// In en, this message translates to:
  /// **'Your body is processing your last meal and storing energy.'**
  String get zoneSugarRisesDesc;

  /// No description provided for @zoneSugarDrops.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Drops'**
  String get zoneSugarDrops;

  /// No description provided for @zoneSugarDropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Digestion ends. Blood sugar levels return to normal.'**
  String get zoneSugarDropsDesc;

  /// No description provided for @zoneFatBurning.
  ///
  /// In en, this message translates to:
  /// **'Fat Burning'**
  String get zoneFatBurning;

  /// No description provided for @zoneFatBurningDesc.
  ///
  /// In en, this message translates to:
  /// **'Your body starts burning stored fat for energy.'**
  String get zoneFatBurningDesc;

  /// No description provided for @zoneKetosis.
  ///
  /// In en, this message translates to:
  /// **'Ketosis'**
  String get zoneKetosis;

  /// No description provided for @zoneKetosisDesc.
  ///
  /// In en, this message translates to:
  /// **'Fat burning accelerates. Mental clarity increases.'**
  String get zoneKetosisDesc;

  /// No description provided for @zoneAutophagy.
  ///
  /// In en, this message translates to:
  /// **'Autophagy'**
  String get zoneAutophagy;

  /// No description provided for @zoneAutophagyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cellular repair and recycling begins. Anti-aging effects.'**
  String get zoneAutophagyDesc;

  /// No description provided for @zoneGrowthHormone.
  ///
  /// In en, this message translates to:
  /// **'Growth Hormone'**
  String get zoneGrowthHormone;

  /// No description provided for @zoneGrowthHormoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Peak fat burning, tissue repair, and muscle preservation.'**
  String get zoneGrowthHormoneDesc;

  /// No description provided for @continueForPrice.
  ///
  /// In en, this message translates to:
  /// **'Continue for {price}'**
  String continueForPrice(String price);

  /// No description provided for @offersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Offers are temporarily unavailable'**
  String get offersUnavailable;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @billedAnnually.
  ///
  /// In en, this message translates to:
  /// **'Billed annually'**
  String get billedAnnually;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get oneTimePurchase;

  /// No description provided for @goalPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'What matters most right now?'**
  String get goalPriorityTitle;

  /// No description provided for @goalPriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'We use this to balance speed, recovery, and long-term consistency.'**
  String get goalPriorityDesc;

  /// No description provided for @goalFatLossTitle.
  ///
  /// In en, this message translates to:
  /// **'Lose fat faster'**
  String get goalFatLossTitle;

  /// No description provided for @goalFatLossDesc.
  ///
  /// In en, this message translates to:
  /// **'Favor stronger fasting windows when your profile can handle them.'**
  String get goalFatLossDesc;

  /// No description provided for @goalHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Improve health and energy'**
  String get goalHealthTitle;

  /// No description provided for @goalHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Aim for a balanced plan that supports focus, energy, and adherence.'**
  String get goalHealthDesc;

  /// No description provided for @goalHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a sustainable habit'**
  String get goalHabitTitle;

  /// No description provided for @goalHabitDesc.
  ///
  /// In en, this message translates to:
  /// **'Start easier so the routine actually sticks.'**
  String get goalHabitDesc;

  /// No description provided for @routineTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your routine'**
  String get routineTitle;

  /// No description provided for @routineDesc.
  ///
  /// In en, this message translates to:
  /// **'Sleep and fasting experience change how aggressive your starting plan should be.'**
  String get routineDesc;

  /// No description provided for @fastingExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting experience'**
  String get fastingExperienceTitle;

  /// No description provided for @experienceBeginnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get experienceBeginnerTitle;

  /// No description provided for @experienceBeginnerDesc.
  ///
  /// In en, this message translates to:
  /// **'I am new to fasting or I usually stop early.'**
  String get experienceBeginnerDesc;

  /// No description provided for @experienceIntermediateTitle.
  ///
  /// In en, this message translates to:
  /// **'Some experience'**
  String get experienceIntermediateTitle;

  /// No description provided for @experienceIntermediateDesc.
  ///
  /// In en, this message translates to:
  /// **'I can handle 14-16 hour fasts without much trouble.'**
  String get experienceIntermediateDesc;

  /// No description provided for @experienceAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get experienceAdvancedTitle;

  /// No description provided for @experienceAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'I have done longer fasts and want a stronger protocol.'**
  String get experienceAdvancedDesc;

  /// No description provided for @sleepPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep schedule'**
  String get sleepPatternTitle;

  /// No description provided for @sleepRegularTitle.
  ///
  /// In en, this message translates to:
  /// **'Regular sleep'**
  String get sleepRegularTitle;

  /// No description provided for @sleepRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'My bedtime and wake time are mostly consistent.'**
  String get sleepRegularDesc;

  /// No description provided for @sleepLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Late nights'**
  String get sleepLateTitle;

  /// No description provided for @sleepLateDesc.
  ///
  /// In en, this message translates to:
  /// **'I often go to bed late or drift on weekends.'**
  String get sleepLateDesc;

  /// No description provided for @sleepIrregularTitle.
  ///
  /// In en, this message translates to:
  /// **'Irregular or shift work'**
  String get sleepIrregularTitle;

  /// No description provided for @sleepIrregularDesc.
  ///
  /// In en, this message translates to:
  /// **'My sleep changes a lot or I work rotating shifts.'**
  String get sleepIrregularDesc;

  /// No description provided for @smartPlanDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your current strategy'**
  String get smartPlanDashboardTitle;

  /// No description provided for @smartPlanProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your onboarding strategy'**
  String get smartPlanProfileTitle;

  /// No description provided for @smartPlanCurrentPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get smartPlanCurrentPlanLabel;

  /// No description provided for @smartPlanRecommendedPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendation'**
  String get smartPlanRecommendedPlanLabel;

  /// No description provided for @smartPlanSignalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get smartPlanSignalsLabel;

  /// No description provided for @smartPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendation'**
  String get smartPlanTitle;

  /// No description provided for @smartPlanBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best starting plan: {plan}'**
  String smartPlanBestMatch(String plan);

  /// No description provided for @smartPlanHint.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in settings.'**
  String get smartPlanHint;

  /// No description provided for @smartPlanWhyRecovery.
  ///
  /// In en, this message translates to:
  /// **'A gentler window is better for recovery, consistency, and adaptation.'**
  String get smartPlanWhyRecovery;

  /// No description provided for @smartPlanWhyActive.
  ///
  /// In en, this message translates to:
  /// **'Your activity level favors a plan that protects energy and training quality.'**
  String get smartPlanWhyActive;

  /// No description provided for @smartPlanWhyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Your goal and experience suggest starting with a plan you can repeat consistently.'**
  String get smartPlanWhyBeginner;

  /// No description provided for @smartPlanWhyBalanced.
  ///
  /// In en, this message translates to:
  /// **'This gives you stronger fasting benefits without becoming too aggressive.'**
  String get smartPlanWhyBalanced;

  /// No description provided for @smartPlanWhyAggressive.
  ///
  /// In en, this message translates to:
  /// **'Your current profile can handle a tighter window if you want faster progress.'**
  String get smartPlanWhyAggressive;

  /// No description provided for @smartPlanWhySleep.
  ///
  /// In en, this message translates to:
  /// **'Your sleep schedule favors a steadier plan that adds less stress to your routine.'**
  String get smartPlanWhySleep;

  /// No description provided for @smartPlanWhySustainable.
  ///
  /// In en, this message translates to:
  /// **'A sustainable start usually leads to better adherence in the first weeks.'**
  String get smartPlanWhySustainable;

  /// No description provided for @smartPlanAlternativeEasier.
  ///
  /// In en, this message translates to:
  /// **'{plan} is a softer option if you want an easier adjustment.'**
  String smartPlanAlternativeEasier(String plan);

  /// No description provided for @smartPlanAlternativeStronger.
  ///
  /// In en, this message translates to:
  /// **'{plan} is a stronger option if you want a more ambitious cut.'**
  String smartPlanAlternativeStronger(String plan);

  /// No description provided for @smartPlanCoachGreeting.
  ///
  /// In en, this message translates to:
  /// **'I\'m Fasty 🥑. You\'re currently on {plan} and focused on {goal}. With your {experience} background and {sleep} sleep pattern, I can help you stay consistent.'**
  String smartPlanCoachGreeting(String plan, String goal, String experience, String sleep);

  /// No description provided for @smartPlanUseRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Use smart recommendation'**
  String get smartPlanUseRecommendation;

  /// No description provided for @labelAlternative.
  ///
  /// In en, this message translates to:
  /// **'ALTERNATIVE'**
  String get labelAlternative;

  /// No description provided for @perMonthEquivalent.
  ///
  /// In en, this message translates to:
  /// **'~{price}/{period}'**
  String perMonthEquivalent(String price, String period);

  /// No description provided for @circadianProExclusive.
  ///
  /// In en, this message translates to:
  /// **'PRO EXCLUSIVE'**
  String get circadianProExclusive;

  /// No description provided for @circadianStartFast.
  ///
  /// In en, this message translates to:
  /// **'Start Circadian Fast'**
  String get circadianStartFast;

  /// No description provided for @sunriseLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunriseLabel;

  /// No description provided for @sunsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunsetLabel;

  /// No description provided for @lastMeal.
  ///
  /// In en, this message translates to:
  /// **'Last Meal'**
  String get lastMeal;

  /// No description provided for @circadianTotalWindow.
  ///
  /// In en, this message translates to:
  /// **'Total Fasting Window'**
  String get circadianTotalWindow;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursLabel;

  /// No description provided for @basedOnLocalCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Based on your local coordinates'**
  String get basedOnLocalCoordinates;

  /// No description provided for @locationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequiredTitle;

  /// No description provided for @locationRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'We need your location to calculate the exact sunset time in your city.'**
  String get locationRequiredDesc;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @circadianStarted.
  ///
  /// In en, this message translates to:
  /// **'Circadian Fast Started! 🌅'**
  String get circadianStarted;

  /// No description provided for @planCircadianTitle.
  ///
  /// In en, this message translates to:
  /// **'Circadian Fast'**
  String get planCircadianTitle;

  /// No description provided for @planCircadianSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Align fasting with the sun'**
  String get planCircadianSubtitle;

  /// No description provided for @planCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your own window'**
  String get planCustomSubtitle;

  /// No description provided for @planPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get planPresets;

  /// No description provided for @durationHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursShort(int hours);

  /// No description provided for @durationHoursMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutesShort(int hours, int minutes);

  /// No description provided for @endFastCongrats.
  ///
  /// In en, this message translates to:
  /// **'You did it! 🎉'**
  String get endFastCongrats;

  /// No description provided for @endFastTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total fasting time: {time}'**
  String endFastTotalTime(String time);

  /// No description provided for @endFastHowFeel.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get endFastHowFeel;

  /// No description provided for @endFastSaveEat.
  ///
  /// In en, this message translates to:
  /// **'Save & Eat'**
  String get endFastSaveEat;

  /// No description provided for @endFastKeepFasting.
  ///
  /// In en, this message translates to:
  /// **'Cancel, keep fasting'**
  String get endFastKeepFasting;

  /// No description provided for @proAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'PRO ACCESS'**
  String get proAccessLabel;

  /// No description provided for @timerEndTitle.
  ///
  /// In en, this message translates to:
  /// **'When did you break your fast?'**
  String get timerEndTitle;

  /// No description provided for @timerCannotStartFuture.
  ///
  /// In en, this message translates to:
  /// **'You can\'t start a fast in the future.'**
  String get timerCannotStartFuture;

  /// No description provided for @timerCannotEndFuture.
  ///
  /// In en, this message translates to:
  /// **'You can\'t end a fast in the future.'**
  String get timerCannotEndFuture;

  /// No description provided for @timerEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time can\'t be earlier than the start time.'**
  String get timerEndBeforeStart;

  /// No description provided for @timerGoalReachedExtra.
  ///
  /// In en, this message translates to:
  /// **'🔥 Goal reached (+ extra)'**
  String get timerGoalReachedExtra;

  /// No description provided for @timerWindowExtended.
  ///
  /// In en, this message translates to:
  /// **'Window extended'**
  String get timerWindowExtended;

  /// No description provided for @timerRemainingInWindow.
  ///
  /// In en, this message translates to:
  /// **'Remaining in window'**
  String get timerRemainingInWindow;

  /// No description provided for @timerUnknownPlan.
  ///
  /// In en, this message translates to:
  /// **'Unknown Plan'**
  String get timerUnknownPlan;

  /// No description provided for @timerLogMoodSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log mood & symptoms'**
  String get timerLogMoodSymptoms;

  /// No description provided for @timerBreakAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'You are already on a break. Enjoy your rest! ☕'**
  String get timerBreakAlreadyActive;

  /// No description provided for @timerRestDayStarted.
  ///
  /// In en, this message translates to:
  /// **'Eating window closed. Enjoy your rest day! 🏖️'**
  String get timerRestDayStarted;

  /// No description provided for @timerTakeBreak.
  ///
  /// In en, this message translates to:
  /// **'Take a break'**
  String get timerTakeBreak;

  /// No description provided for @timerLogStartEarlier.
  ///
  /// In en, this message translates to:
  /// **'Log start earlier'**
  String get timerLogStartEarlier;

  /// No description provided for @timerLogEndEarlier.
  ///
  /// In en, this message translates to:
  /// **'Log end earlier'**
  String get timerLogEndEarlier;

  /// No description provided for @timerLogFastStartEarlier.
  ///
  /// In en, this message translates to:
  /// **'Log fast start earlier'**
  String get timerLogFastStartEarlier;

  /// No description provided for @bodyMeasureChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodyMeasureChest;

  /// No description provided for @bodyMeasureWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get bodyMeasureWaist;

  /// No description provided for @bodyMeasureHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get bodyMeasureHips;

  /// No description provided for @bodyMeasureChestTitle.
  ///
  /// In en, this message translates to:
  /// **'Chest Size (cm)'**
  String get bodyMeasureChestTitle;

  /// No description provided for @bodyMeasureWaistTitle.
  ///
  /// In en, this message translates to:
  /// **'Waist Size (cm)'**
  String get bodyMeasureWaistTitle;

  /// No description provided for @bodyMeasureHipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hips Size (cm)'**
  String get bodyMeasureHipsTitle;

  /// No description provided for @bodyMeasureAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get bodyMeasureAdd;

  /// No description provided for @drinkWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get drinkWater;

  /// No description provided for @drinkBlackCoffee.
  ///
  /// In en, this message translates to:
  /// **'Black Coffee'**
  String get drinkBlackCoffee;

  /// No description provided for @drinkLatteSweetCoffee.
  ///
  /// In en, this message translates to:
  /// **'Latte / Sweet Coffee'**
  String get drinkLatteSweetCoffee;

  /// No description provided for @drinkGreenBlackTea.
  ///
  /// In en, this message translates to:
  /// **'Green / Black Tea'**
  String get drinkGreenBlackTea;

  /// No description provided for @drinkDietSoda.
  ///
  /// In en, this message translates to:
  /// **'Diet Soda'**
  String get drinkDietSoda;

  /// No description provided for @drinkSweetSoda.
  ///
  /// In en, this message translates to:
  /// **'Sweet Soda'**
  String get drinkSweetSoda;

  /// No description provided for @drinkJuice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get drinkJuice;

  /// No description provided for @drinkAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get drinkAlcohol;

  /// No description provided for @waterDrinkContainsCalories.
  ///
  /// In en, this message translates to:
  /// **'{drink} contains calories!'**
  String waterDrinkContainsCalories(String drink);

  /// No description provided for @waterBreakFastWarning.
  ///
  /// In en, this message translates to:
  /// **'Drinking this will break your current fast and automatically start your eating window. Are you sure?'**
  String get waterBreakFastWarning;

  /// No description provided for @waterConfirmDrinkBreakFast.
  ///
  /// In en, this message translates to:
  /// **'Yes, I drank it'**
  String get waterConfirmDrinkBreakFast;

  /// No description provided for @waterDrinkPrompt.
  ///
  /// In en, this message translates to:
  /// **'What did you drink?'**
  String get waterDrinkPrompt;

  /// No description provided for @waterFastStoppedByDrink.
  ///
  /// In en, this message translates to:
  /// **'Fasting timer stopped because you drank {drink}.'**
  String waterFastStoppedByDrink(String drink);

  /// No description provided for @waterUndoLastDrink.
  ///
  /// In en, this message translates to:
  /// **'Undo last drink'**
  String get waterUndoLastDrink;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @healthBadgeSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get healthBadgeSync;

  /// No description provided for @healthNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get healthNoData;

  /// No description provided for @healthSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get healthSleepLabel;

  /// No description provided for @healthCyclePhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle Phase'**
  String get healthCyclePhaseLabel;

  /// No description provided for @cyclePhaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get cyclePhaseMenstruation;

  /// No description provided for @cyclePhaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get cyclePhaseFollicular;

  /// No description provided for @cyclePhaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get cyclePhaseOvulation;

  /// No description provided for @cyclePhaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get cyclePhaseLuteal;

  /// No description provided for @learnQuickBites.
  ///
  /// In en, this message translates to:
  /// **'Quick Bites'**
  String get learnQuickBites;

  /// No description provided for @storyFasting101.
  ///
  /// In en, this message translates to:
  /// **'Fasting 101'**
  String get storyFasting101;

  /// No description provided for @storyAutophagy.
  ///
  /// In en, this message translates to:
  /// **'Autophagy'**
  String get storyAutophagy;

  /// No description provided for @storyKetoDiet.
  ///
  /// In en, this message translates to:
  /// **'Keto Diet'**
  String get storyKetoDiet;

  /// No description provided for @storyHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get storyHydration;

  /// No description provided for @storySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get storySleep;

  /// No description provided for @storyOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening story: {title}...'**
  String storyOpening(String title);

  /// No description provided for @recipeSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {title}'**
  String recipeSelected(String title);

  /// No description provided for @aiUpdatingConfig.
  ///
  /// In en, this message translates to:
  /// **'AI is updating configuration. Please check your internet and restart the app.'**
  String get aiUpdatingConfig;

  /// No description provided for @aiSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Coach session expired. Close and reopen the chat to continue.'**
  String get aiSessionExpired;

  /// No description provided for @aiEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'I\'m still thinking. Please try again.'**
  String get aiEmptyResponse;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @authAppleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is only available on iOS.'**
  String get authAppleUnavailable;

  /// No description provided for @authAppleFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In failed. Please try again.'**
  String get authAppleFailed;

  /// No description provided for @journalSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms & State'**
  String get journalSymptomsTitle;

  /// No description provided for @journalSymptomsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get journalSymptomsPrefix;

  /// No description provided for @journalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Journal updated! 📝'**
  String get journalUpdated;

  /// No description provided for @symptomEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get symptomEnergy;

  /// No description provided for @symptomFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get symptomFocus;

  /// No description provided for @symptomHungry.
  ///
  /// In en, this message translates to:
  /// **'Hungry'**
  String get symptomHungry;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomThirsty.
  ///
  /// In en, this message translates to:
  /// **'Thirsty'**
  String get symptomThirsty;

  /// No description provided for @moodTerrible.
  ///
  /// In en, this message translates to:
  /// **'Terrible'**
  String get moodTerrible;

  /// No description provided for @moodBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get moodBad;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
