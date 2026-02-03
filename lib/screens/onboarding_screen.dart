import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart'; // Для Enums
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';

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
  int _planIndex = 0;

  void _nextPage() {
    getIt<HapticService>().mediumImpact();
    // У нас теперь 5 страниц (0,1,2,3,4)
    if (_currentPage < 4) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Прогресс бар теперь делим на 5 частей
    return Scaffold(
      body: Stack(
        children: [
          const MeshBackground(isFasting: false, child: SizedBox.expand()),
          SafeArea(
            child: Column(
              children: [
                // Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: List.generate(5, (index) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentPage ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      _buildIntroPage(l10n),
                      _buildGenderAgePage(l10n), // NEW
                      _buildBodyMetricsPage(l10n), // Weight/Height
                      _buildActivityPage(l10n),  // NEW
                      _buildPlanPage(l10n),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 20),
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
  }

  // 1. INTRO
  Widget _buildIntroPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.bolt_rounded, size: 80, color: Colors.amber),
          ),
          const SizedBox(height: 40),
          Text(l10n.onboardingTitle, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(l10n.onboardingDesc,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // 2. GENDER & AGE (NEW)
  Widget _buildGenderAgePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.selectGender, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          // Gender
          Row(
            children: [
              Expanded(child: _buildGenderCard(l10n.genderMale, Icons.male, Gender.male)),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderCard(l10n.genderFemale, Icons.female, Gender.female)),
            ],
          ),

          const SizedBox(height: 40),
          Text(l10n.selectAge, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Age Picker
          SizedBox(
            height: 120,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              perspective: 0.005,
              controller: FixedExtentScrollController(initialItem: _age - 10),
              onSelectedItemChanged: (idx) {
                getIt<HapticService>().selectionClick();
                setState(() => _age = 10 + idx);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 90,
                builder: (c, i) {
                  final val = 10 + i;
                  return Center(child: Text("$val",
                      style: TextStyle(color: val == _age ? Colors.white : Colors.white24, fontSize: 28, fontWeight: FontWeight.bold)));
                },
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent),
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

  // 3. BODY METRICS
  Widget _buildBodyMetricsPage(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Body Metrics", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.selectWeight, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(width: 40),
            Text(l10n.selectHeight, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ],
        ),

        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  controller: FixedExtentScrollController(initialItem: (_weight - 30).toInt()),
                  onSelectedItemChanged: (idx) {
                    getIt<HapticService>().selectionClick();
                    setState(() => _weight = 30.0 + idx);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 150,
                    builder: (c, i) => Center(child: Text("${30 + i}", style: TextStyle(color: (30 + i) == _weight.toInt() ? Colors.white : Colors.white24, fontSize: 28, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  controller: FixedExtentScrollController(initialItem: (_height - 100).toInt()),
                  onSelectedItemChanged: (idx) {
                    getIt<HapticService>().selectionClick();
                    setState(() => _height = 100.0 + idx);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 120,
                    builder: (c, i) => Center(child: Text("${100 + i}", style: TextStyle(color: (100 + i) == _height.toInt() ? Colors.white : Colors.white24, fontSize: 28, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. ACTIVITY LEVEL (NEW)
  Widget _buildActivityPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.selectActivity, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Used to calculate your daily energy burn (TDEE).", style: TextStyle(color: Colors.white.withOpacity(0.6)), textAlign: TextAlign.center),
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
          border: Border.all(color: isSelected ? Colors.orangeAccent : Colors.transparent),
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

  // 5. PLAN SELECTION (С УМНОЙ РЕКОМЕНДАЦИЕЙ)
  Widget _buildPlanPage(AppLocalizations l10n) {
    // 1. Логика рекомендации
    int recommendedIndex = 0; // По умолчанию 12-12 (Beginner)

    // Если мужчина и возраст от 18 до 60 -> 16-8 (Index 1)
    if (_gender == Gender.male && _age >= 18 && _age < 60) {
      recommendedIndex = 1;
    }
    // Если активный образ жизни -> 16-8
    if (_activity == ActivityLevel.active) {
      recommendedIndex = 1;
    }

    // Если пользователь еще не выбирал, можем подставить рекомендованный (опционально)
    // if (_planIndex == 0 && _currentPage < 4) _planIndex = recommendedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Choose Your Goal", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Показываем пояснение
          if (recommendedIndex == 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text("Based on your gender and activity, we recommend the 16-8 plan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.greenAccent.withOpacity(0.8), fontSize: 14)),
            ),

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
                              width: isRecommended && !isSelected ? 1 : 1
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
                      // Бейджик рекомендации
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