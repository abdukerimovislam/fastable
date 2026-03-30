import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';

// --- MODELS & SERVICES ---
import 'package:fastable/core/app_prefs_keys.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/onboarding_plan_recommender.dart';

// --- WIDGETS ---
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/permissions_screen.dart';
import 'package:fastable/screens/medical_disclaimer_screen.dart';
import 'package:fastable/ui/app_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  Gender _gender = Gender.male;
  int _age = 25;
  double _weight = 70.0;
  double _height = 170.0;
  ActivityLevel _activity = ActivityLevel.moderate;
  PrimaryGoal _primaryGoal = PrimaryGoal.healthAndEnergy;
  FastingExperience _fastingExperience = FastingExperience.beginner;
  SleepPattern _sleepPattern = SleepPattern.regular;
  int _planIndex = 0;
  bool _hasManualPlanSelection = false;

  // Medical Disclaimer checkbox — required on first page
  bool _agreedToDisclaimer = false;

  // 🔥 ИСПРАВЛЕНО: Добавлен dispose для предотвращения утечки памяти
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _nextPage() {
    // Block Continue on page 0 until disclaimer is accepted
    if (_currentPage == 0 && !_agreedToDisclaimer) {
      getIt<HapticService>().lightImpact();
      return;
    }
    getIt<HapticService>().mediumImpact();
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    getIt<HapticService>().lightImpact();
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final selectedPlanIndex = _resolvedPlanIndex;
    final wb = context.read<WeightBloc>();
    wb.add(UpdateGender(_gender));
    wb.add(UpdateAge(_age));
    wb.add(UpdateHeight(_height));
    wb.add(AddWeightEntry(_weight));
    wb.add(UpdateActivityLevel(_activity));

    context.read<FastingBloc>().add(ChangePlan(selectedPlanIndex));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefsKeys.onboardingComplete, true);
    await prefs.setBool(AppPrefsKeys.disclaimerAccepted, true);
    await prefs.setString(AppPrefsKeys.onboardingPrimaryGoal, _primaryGoal.name);
    await prefs.setString(
      AppPrefsKeys.onboardingFastingExperience,
      _fastingExperience.name,
    );
    await prefs.setString(AppPrefsKeys.onboardingSleepPattern, _sleepPattern.name);

    if (mounted) {
      await context.read<OnboardingProfileCubit>().load();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PermissionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  // --- UI BUILDERS ---

  double _pageEdgePadding(BuildContext context) =>
      AppLayout.edgePadding(context) + 4;

  double _pageCardPadding(BuildContext context) =>
      AppLayout.cardPadding(context);

  OnboardingPlanRecommendation get _planRecommendation =>
      OnboardingPlanRecommender.recommend(
        age: _age,
        weightKg: _weight,
        heightCm: _height,
        activityLevel: _activity,
        primaryGoal: _primaryGoal,
        experience: _fastingExperience,
        sleepPattern: _sleepPattern,
      );

  int get _resolvedPlanIndex => _hasManualPlanSelection
      ? _planIndex
      : _planRecommendation.recommendedIndex;

  String _formatPlanWindow(FastingPlan plan) {
    return "${plan.fastingDuration.inHours}:${plan.eatingDuration.inHours}";
  }

  String _planRecommendationReasonText(
    AppLocalizations l10n,
    PlanRecommendationReason reason,
  ) {
    switch (reason) {
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

  String _planAlternativeText(
    AppLocalizations l10n,
    int recommendedIndex,
    int alternativeIndex,
  ) {
    final alternativePlan = FastingPlan.defaultPlans[alternativeIndex];
    final alternativeLabel = _formatPlanWindow(alternativePlan);

    if (alternativeIndex > recommendedIndex) {
      return l10n.smartPlanAlternativeStronger(alternativeLabel);
    }

    return l10n.smartPlanAlternativeEasier(alternativeLabel);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final l10n = AppLocalizations.of(context)!;
        final currentLanguageCode =
            settingsState.locale.languageCode; // Получаем текущую локаль

        return Scaffold(
          body: Stack(
            children: [
              const MeshBackground(isFasting: false, child: SizedBox.expand()),

              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _pageEdgePadding(context),
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          if (_currentPage > 0)
                            GestureDetector(
                              onTap: _prevPage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white10,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 36),

                          const SizedBox(width: 16),

                          // Индикатор
                          Expanded(
                            child: Row(
                              children: List.generate(
                                _totalPages,
                                (index) => Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: index <= _currentPage
                                          ? Colors.white
                                          : Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),

                    // Контент
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (idx) =>
                            setState(() => _currentPage = idx),
                        children: [
                          _buildLanguagePage(l10n, currentLanguageCode),
                          _buildIntroPage(l10n),
                          _buildGenderAgePage(l10n),
                          _buildBodyMetricsPage(l10n),
                          _buildActivityPage(l10n),
                          _buildGoalPriorityPage(l10n),
                          _buildRoutinePage(l10n),
                          _buildPlanPage(l10n),
                        ],
                      ),
                    ),

                    // Кнопка
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        _pageEdgePadding(context),
                        0,
                        _pageEdgePadding(context),
                        20,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: (_currentPage == 0 && !_agreedToDisclaimer)
                              ? Colors.white12
                              : Colors.blueAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GestureDetector(
                          onTap: _nextPage,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Text(
                                _currentPage == _totalPages - 1
                                    ? l10n.btnStart
                                    : l10n.btnContinue,
                                style: TextStyle(
                                  color: (_currentPage == 0 && !_agreedToDisclaimer)
                                      ? Colors.white38
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- PAGES ---

  Widget _buildLanguagePage(AppLocalizations l10n, String currentLanguageCode) {
    return Padding(
      padding: EdgeInsets.all(_pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 60, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            l10n.stepLanguage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _buildLangOption("English", "en", "🇺🇸", currentLanguageCode),
          const SizedBox(height: 12),
          _buildLangOption("Русский", "ru", "🇷🇺", currentLanguageCode),
          const SizedBox(height: 12),
          _buildLangOption("Español", "es", "🇪🇸", currentLanguageCode),
          const SizedBox(height: 12),
          _buildLangOption("Português", "pt", "🇧🇷", currentLanguageCode),
          const SizedBox(height: 32),
          // ─── Medical Disclaimer Checkbox ───────────────────────────
          GestureDetector(
            onTap: () {
              getIt<HapticService>().selectionClick();
              setState(() => _agreedToDisclaimer = !_agreedToDisclaimer);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _agreedToDisclaimer
                    ? Colors.blueAccent.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _agreedToDisclaimer ? Colors.blueAccent : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _agreedToDisclaimer ? Colors.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _agreedToDisclaimer ? Colors.blueAccent : Colors.white38,
                        width: 2,
                      ),
                    ),
                    child: _agreedToDisclaimer
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: l10n.disclaimerCheckboxPrefix),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MedicalDisclaimerScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.disclaimerCheckboxLink,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ИСПРАВЛЕНО: Убрали лишний BlocBuilder
  Widget _buildLangOption(
    String name,
    String code,
    String flag,
    String currentLanguageCode,
  ) {
    final isSelected = currentLanguageCode == code;
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().selectionClick();
        context.read<SettingsBloc>().add(ChangeLocale(Locale(code)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: _pageCardPadding(context),
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(_pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 80,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDesc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderAgePage(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.selectGender,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  l10n.genderMale,
                  Icons.male,
                  Gender.male,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderCard(
                  l10n.genderFemale,
                  Icons.female,
                  Gender.female,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            l10n.selectAge,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CupertinoPicker(
              itemExtent: 40,
              magnification: 1.2,
              useMagnifier: true,
              scrollController: FixedExtentScrollController(
                initialItem: _age - 10,
              ),
              onSelectedItemChanged: (idx) {
                getIt<HapticService>().selectionClick();
                setState(() => _age = 10 + idx);
              },
              children: List.generate(
                90,
                (i) => Center(
                  child: Text(
                    "${10 + i}",
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon, Gender g) {
    final isSelected = _gender == g;
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().selectionClick();
        setState(() => _gender = g);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsPage(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.stepBodyMetrics,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.stepBodyMetricsDesc,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 40),
        // 🔥 ИСПРАВЛЕНО: Верстка центрирована для любых языков
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    l10n.selectWeight,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      magnification: 1.2,
                      useMagnifier: true,
                      scrollController: FixedExtentScrollController(
                        initialItem: (_weight - 30).toInt(),
                      ),
                      onSelectedItemChanged: (idx) {
                        getIt<HapticService>().selectionClick();
                        setState(() => _weight = 30.0 + idx);
                      },
                      children: List.generate(
                        150,
                        (i) => Center(
                          child: Text(
                            "${30 + i} ${l10n.unitKg}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    l10n.selectHeight,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      magnification: 1.2,
                      useMagnifier: true,
                      scrollController: FixedExtentScrollController(
                        initialItem: (_height - 100).toInt(),
                      ),
                      onSelectedItemChanged: (idx) {
                        getIt<HapticService>().selectionClick();
                        setState(() => _height = 100.0 + idx);
                      },
                      children: List.generate(
                        120,
                        (i) => Center(
                          child: Text(
                            "${100 + i} cm",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityPage(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.selectActivity,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.activityHint,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildActivityCard(
            l10n.activitySedentary,
            l10n.activitySedentaryDesc,
            ActivityLevel.sedentary,
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            l10n.activityModerate,
            l10n.activityModerateDesc,
            ActivityLevel.moderate,
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            l10n.activityActive,
            l10n.activityActiveDesc,
            ActivityLevel.active,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    ActivityLevel level,
  ) {
    final isSelected = _activity == level;
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().selectionClick();
        setState(() => _activity = level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_pageCardPadding(context)),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orangeAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? Colors.orangeAccent : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPriorityPage(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.goalPriorityTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.goalPriorityDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 30),
          _buildSelectionCard(
            title: l10n.goalFatLossTitle,
            subtitle: l10n.goalFatLossDesc,
            icon: Icons.local_fire_department_rounded,
            color: Colors.redAccent,
            isSelected: _primaryGoal == PrimaryGoal.fatLoss,
            onTap: () {
              getIt<HapticService>().selectionClick();
              setState(() => _primaryGoal = PrimaryGoal.fatLoss);
            },
          ),
          const SizedBox(height: 12),
          _buildSelectionCard(
            title: l10n.goalHealthTitle,
            subtitle: l10n.goalHealthDesc,
            icon: Icons.favorite_rounded,
            color: Colors.greenAccent,
            isSelected: _primaryGoal == PrimaryGoal.healthAndEnergy,
            onTap: () {
              getIt<HapticService>().selectionClick();
              setState(() => _primaryGoal = PrimaryGoal.healthAndEnergy);
            },
          ),
          const SizedBox(height: 12),
          _buildSelectionCard(
            title: l10n.goalHabitTitle,
            subtitle: l10n.goalHabitDesc,
            icon: Icons.self_improvement_rounded,
            color: Colors.blueAccent,
            isSelected: _primaryGoal == PrimaryGoal.consistency,
            onTap: () {
              getIt<HapticService>().selectionClick();
              setState(() => _primaryGoal = PrimaryGoal.consistency);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinePage(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pageEdgePadding(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.routineTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.routineDesc,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.fastingExperienceTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.experienceBeginnerTitle,
              subtitle: l10n.experienceBeginnerDesc,
              icon: Icons.flag_rounded,
              color: Colors.tealAccent,
              isSelected: _fastingExperience == FastingExperience.beginner,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(() => _fastingExperience = FastingExperience.beginner);
              },
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.experienceIntermediateTitle,
              subtitle: l10n.experienceIntermediateDesc,
              icon: Icons.trending_up_rounded,
              color: Colors.amber,
              isSelected: _fastingExperience == FastingExperience.intermediate,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(
                  () => _fastingExperience = FastingExperience.intermediate,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.experienceAdvancedTitle,
              subtitle: l10n.experienceAdvancedDesc,
              icon: Icons.whatshot_rounded,
              color: Colors.deepOrangeAccent,
              isSelected: _fastingExperience == FastingExperience.advanced,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(() => _fastingExperience = FastingExperience.advanced);
              },
            ),
            const SizedBox(height: 28),
            Text(
              l10n.sleepPatternTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.sleepRegularTitle,
              subtitle: l10n.sleepRegularDesc,
              icon: Icons.bedtime_rounded,
              color: Colors.indigoAccent,
              isSelected: _sleepPattern == SleepPattern.regular,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(() => _sleepPattern = SleepPattern.regular);
              },
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.sleepLateTitle,
              subtitle: l10n.sleepLateDesc,
              icon: Icons.nights_stay_rounded,
              color: Colors.purpleAccent,
              isSelected: _sleepPattern == SleepPattern.late,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(() => _sleepPattern = SleepPattern.late);
              },
            ),
            const SizedBox(height: 12),
            _buildSelectionCard(
              title: l10n.sleepIrregularTitle,
              subtitle: l10n.sleepIrregularDesc,
              icon: Icons.sync_alt_rounded,
              color: Colors.cyanAccent,
              isSelected: _sleepPattern == SleepPattern.irregular,
              onTap: () {
                getIt<HapticService>().selectionClick();
                setState(() => _sleepPattern = SleepPattern.irregular);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_pageCardPadding(context)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanPage(AppLocalizations l10n) {
    final recommendation = _planRecommendation;
    final recommendedIndex = recommendation.recommendedIndex;
    final alternativeIndex = recommendation.alternativeIndex;
    final selectedPlanIndex = _resolvedPlanIndex;
    final recommendedPlanLabel = _formatPlanWindow(
      FastingPlan.defaultPlans[recommendedIndex],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _pageEdgePadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.stepGoal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: EdgeInsets.all(_pageCardPadding(context)),
            color: Colors.greenAccent.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.greenAccent.withValues(alpha: 0.35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.greenAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.smartPlanTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.smartPlanBestMatch(recommendedPlanLabel),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _planRecommendationReasonText(
                    l10n,
                    recommendation.primaryReason,
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _planAlternativeText(
                    l10n,
                    recommendedIndex,
                    alternativeIndex,
                  ),
                  style: TextStyle(
                    color: Colors.blue.shade100,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.smartPlanHint,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (_hasManualPlanSelection && _planIndex != recommendedIndex)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  getIt<HapticService>().selectionClick();
                  setState(() {
                    _hasManualPlanSelection = false;
                    _planIndex = recommendedIndex;
                  });
                },
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
                label: Text(
                  l10n.smartPlanUseRecommendation,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_hasManualPlanSelection && _planIndex != recommendedIndex)
            const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: FastingPlan.defaultPlans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = FastingPlan.defaultPlans[index];
                final isSelected = selectedPlanIndex == index;
                final isRecommended = index == recommendedIndex;
                final isAlternative = index == alternativeIndex;

                String label = l10n.planBeginner;
                switch (index) {
                  case 0:
                    label = l10n.planPopular;
                    break;
                  case 1:
                    label = l10n.planAdvanced;
                    break;
                  case 2:
                    label = l10n.planExpert;
                    break;
                  default:
                    label = l10n.planExtended;
                    break;
                }

                final accentColor = isSelected
                    ? Colors.greenAccent
                    : isRecommended
                    ? Colors.amber
                    : isAlternative
                    ? Colors.blueAccent
                    : Colors.transparent;

                return GestureDetector(
                  onTap: () {
                    getIt<HapticService>().selectionClick();
                    setState(() {
                      _planIndex = index;
                      _hasManualPlanSelection = true;
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(_pageCardPadding(context)),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.greenAccent.withValues(alpha: 0.2)
                              : isRecommended
                              ? Colors.amber.withValues(alpha: 0.08)
                              : isAlternative
                              ? Colors.blueAccent.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: accentColor,
                            width:
                                (isRecommended || isSelected || isAlternative)
                                ? 1.5
                                : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatPlanWindow(plan),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                              ),
                          ],
                        ),
                      ),
                      if (isRecommended || isAlternative)
                        Positioned(
                          top: -8,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isRecommended
                                  ? Colors.amber
                                  : Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isRecommended
                                  ? l10n.labelRecommended
                                  : l10n.labelAlternative,
                              style: TextStyle(
                                color: isRecommended
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
