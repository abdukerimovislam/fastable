import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart'; // Для Enums
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';

// --- MODELS & SERVICES ---
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/l10n/app_localizations.dart'; // Локализация

// --- WIDGETS ---
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/permissions_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Локальное состояние (для плавности UI перед сохранением)
  Gender _gender = Gender.male;
  int _age = 25;
  double _weight = 70.0;
  double _height = 170.0;
  ActivityLevel _activity = ActivityLevel.moderate;
  int _planIndex = 1; // По умолчанию 16:8 (самый популярный)

  // --- ACTIONS ---

  void _nextPage() {
    getIt<HapticService>().mediumImpact();
    if (_currentPage < 4) {
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
    // Сохраняем ВСЕ данные в Блок (и в Prefs через Блок)
    final wb = context.read<WeightBloc>();
    wb.add(UpdateGender(_gender));
    wb.add(UpdateAge(_age));
    wb.add(UpdateHeight(_height));
    wb.add(AddWeightEntry(_weight));
    wb.add(UpdateActivityLevel(_activity));

    context.read<FastingBloc>().add(ChangePlan(_planIndex));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PermissionsScreen()),
      );
    }
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    // Оборачиваем весь экран в BlocBuilder настроек, чтобы язык менялся на лету
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          body: Stack(
            children: [
              // 1. ФОН
              const MeshBackground(isFasting: false, child: SizedBox.expand()),

              SafeArea(
                child: Column(
                  children: [
                    // 2. HEADER (Progress + Language Button)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          // Кнопка "Назад" (только если не первая страница)
                          if (_currentPage > 0)
                            GestureDetector(
                              onTap: _prevPage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                              ),
                            )
                          else
                            const SizedBox(width: 36), // Заглушка для симметрии

                          const SizedBox(width: 16),

                          // Индикаторы прогресса
                          Expanded(
                            child: Row(
                              children: List.generate(5, (index) => Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: index <= _currentPage ? Colors.white : Colors.white24,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              )),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Кнопка выбора языка
                          _buildLanguageButton(context, settingsState.locale.languageCode),
                        ],
                      ),
                    ),

                    // 3. CONTENT (PageView)
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(), // Блокируем свайп рукой
                        onPageChanged: (idx) => setState(() => _currentPage = idx),
                        children: [
                          _buildIntroPage(l10n),
                          _buildGenderAgePage(l10n),
                          _buildBodyMetricsPage(l10n),
                          _buildActivityPage(l10n),
                          _buildPlanPage(l10n),
                        ],
                      ),
                    ),

                    // 4. BOTTOM BUTTON
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          color: Colors.blueAccent.withOpacity(0.8), // Акцентный цвет
                          child: Center(
                            child: Text(
                              _currentPage == 4 ? l10n.btnStart : l10n.btnContinue,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  // --- LANGUAGE SELECTION ---

  Widget _buildLanguageButton(BuildContext context, String currentCode) {
    String flag = '🇺🇸';
    if (currentCode == 'ru') flag = '🇷🇺';
    if (currentCode == 'es') flag = '🇪🇸';
    if (currentCode == 'pt') flag = '🇧🇷';

    return GestureDetector(
      onTap: () => _showLanguageSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Select Language",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            _langOption(context, 'English', 'en', '🇺🇸'),
            _langOption(context, 'Русский', 'ru', '🇷🇺'),
            _langOption(context, 'Español', 'es', '🇪🇸'),
            _langOption(context, 'Português', 'pt', '🇧🇷'),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, String name, String code, String flag) {
    final currentCode = context.read<SettingsBloc>().state.locale.languageCode;
    final isSelected = currentCode == code;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blueAccent) : null,
      onTap: () {
        context.read<SettingsBloc>().add(ChangeLocale(Locale(code)));
        Navigator.pop(context);
      },
    );
  }

  // --- PAGE 1: INTRO ---
  Widget _buildIntroPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 5)
                ]
            ),
            child: const Icon(Icons.bolt_rounded, size: 80, color: Colors.blueAccent),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingTitle,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDesc,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- PAGE 2: GENDER & AGE ---
  Widget _buildGenderAgePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.selectGender, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _buildGenderCard(l10n.genderMale, Icons.male, Gender.male)),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderCard(l10n.genderFemale, Icons.female, Gender.female)),
            ],
          ),
          const SizedBox(height: 40),
          Text(l10n.selectAge, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: CupertinoPicker(
              itemExtent: 40,
              magnification: 1.2,
              useMagnifier: true,
              scrollController: FixedExtentScrollController(initialItem: _age - 10),
              onSelectedItemChanged: (idx) {
                getIt<HapticService>().selectionClick();
                setState(() => _age = 10 + idx);
              },
              children: List.generate(90, (i) => Center(
                child: Text("${10 + i}", style: const TextStyle(color: Colors.white, fontSize: 24)),
              )),
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- PAGE 3: BODY METRICS ---
  Widget _buildBodyMetricsPage(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Body Metrics", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Help us calculate your BMI & goals", style: TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(l10n.selectWeight, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            Text(l10n.selectHeight, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Weight Wheel
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  magnification: 1.2,
                  useMagnifier: true,
                  scrollController: FixedExtentScrollController(initialItem: (_weight - 30).toInt()),
                  onSelectedItemChanged: (idx) {
                    getIt<HapticService>().selectionClick();
                    setState(() => _weight = 30.0 + idx);
                  },
                  children: List.generate(150, (i) => Center(
                    child: Text("${30 + i} kg", style: const TextStyle(color: Colors.white, fontSize: 22)),
                  )),
                ),
              ),
              // Height Wheel
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  magnification: 1.2,
                  useMagnifier: true,
                  scrollController: FixedExtentScrollController(initialItem: (_height - 100).toInt()),
                  onSelectedItemChanged: (idx) {
                    getIt<HapticService>().selectionClick();
                    setState(() => _height = 100.0 + idx);
                  },
                  children: List.generate(120, (i) => Center(
                    child: Text("${100 + i} cm", style: const TextStyle(color: Colors.white, fontSize: 22)),
                  )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PAGE 4: ACTIVITY ---
  Widget _buildActivityPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.selectActivity, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Used to calculate your daily energy burn.", style: TextStyle(color: Colors.white.withOpacity(0.6)), textAlign: TextAlign.center),
          const SizedBox(height: 30),

          _buildActivityCard(l10n.activitySedentary, "Office job, little exercise", ActivityLevel.sedentary),
          const SizedBox(height: 12),
          _buildActivityCard(l10n.activityModerate, "Active job or exercise 3-4x", ActivityLevel.moderate),
          const SizedBox(height: 12),
          _buildActivityCard(l10n.activityActive, "Physical job or daily training", ActivityLevel.active),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, ActivityLevel level) {
    final isSelected = _activity == level;
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().selectionClick();
        setState(() => _activity = level);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? Colors.orangeAccent : Colors.transparent, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  // --- PAGE 5: PLAN SELECTION ---
  Widget _buildPlanPage(AppLocalizations l10n) {
    int recommendedIndex = 0; // Default: Beginner (12:12)

    // Простая логика рекомендации
    if (_gender == Gender.male && _age >= 18 && _age < 60) recommendedIndex = 1; // 16:8
    if (_activity == ActivityLevel.active) recommendedIndex = 1; // 16:8

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Choose Your Goal", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (recommendedIndex == 1)
            Text("We recommend the 16-8 plan for you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.greenAccent.withOpacity(0.8), fontSize: 14)),

          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: FastingPlan.defaultPlans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = FastingPlan.defaultPlans[index];
                final isSelected = _planIndex == index;
                final isRecommended = index == recommendedIndex;

                String label = "Beginner";
                if (index == 1) label = "Popular (16:8)";
                if (index == 2) label = "Advanced (18:6)";
                if (index == 3) label = "Expert (OMAD)";

                return GestureDetector(
                  onTap: () {
                    getIt<HapticService>().selectionClick();
                    setState(() => _planIndex = index);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          border: Border.all(
                              color: isSelected ? Colors.greenAccent : (isRecommended ? Colors.amber.withOpacity(0.5) : Colors.transparent),
                              width: isRecommended || isSelected ? 1.5 : 1
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${plan.fastingDuration.inHours}-${plan.eatingDuration.inHours}",
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                            const Spacer(),
                            if (isSelected) const Icon(Icons.check_circle, color: Colors.greenAccent),
                          ],
                        ),
                      ),
                      if (isRecommended)
                        Positioned(
                          top: -8,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                            child: const Text("RECOMMENDED", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
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