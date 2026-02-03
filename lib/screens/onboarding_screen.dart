import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/body_visualizer.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';

import 'package:fastable/screens/permissions_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final HapticService _haptic = getIt<HapticService>();

  // Теперь у нас 4 шага: Intro -> Height -> Weight -> Goal
  int _currentPage = 0;
  final int _totalPages = 4;

  // Данные для формы
  double _height = 175;
  double _weight = 70;
  double _goalWeight = 65;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (Progress)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: List.generate(_totalPages, (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage ? Colors.blueAccent : Colors.white10,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Блокируем свайп
                    children: [
                      _buildWelcomeStep(l10n),
                      _buildHeightStep(l10n),
                      _buildWeightStep(l10n),
                      _buildGoalWeightStep(l10n), // Добавили шаг цели
                    ],
                  ),
                ),

                // Footer Buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _haptic.selectionClick();
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            setState(() => _currentPage--);
                          },
                          child: const Text("Back", style: TextStyle(color: Colors.white54)),
                        )
                      else
                        const SizedBox(width: 60),

                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Text(
                            _currentPage == _totalPages - 1 ? l10n.btnFinish : l10n.btnNext,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() async {
    _haptic.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      // --- ЗАВЕРШЕНИЕ: СОХРАНЕНИЕ ДАННЫХ ---

      // 1. Сохраняем РОСТ (через BLoC)
      context.read<WeightBloc>().add(UpdateHeight(_height));

      // 2. Сохраняем ТЕКУЩИЙ ВЕС (через BLoC)
      context.read<WeightBloc>().add(AddWeightEntry(_weight));

      // 3. Сохраняем ЦЕЛЕВОЙ ВЕС (в Prefs, так как WeightBloc читает оттуда)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_goal_weight', _goalWeight);

      // 4. Помечаем, что онбординг пройден
      await prefs.setBool('is_first_run', false);

      if (mounted) {
        // Переход на экран прав
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PermissionsScreen()),
        );
      }
    }
  }

  // --- STEPS ---

  Widget _buildWelcomeStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 30),
          Text(
            l10n.onboardingTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "Configure your profile to get personalized fasting plans and insights.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(l10n.onboardingHeightTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(l10n.onboardingHeightDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                // Визуализируем со стандартным весом, чтобы акцент был на росте
                child: BodyVisualizer(weight: 70, height: _height, phaseColor: Colors.blueAccent, isFasting: false),
              ),
              const SizedBox(width: 40),
              SizedBox(
                height: 300,
                width: 100,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: (_height - 100).toInt()),
                  onSelectedItemChanged: (index) {
                    _haptic.selectionClick();
                    setState(() => _height = (index + 100).toDouble());
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 150, // 100 - 250 cm
                    builder: (context, index) {
                      final val = index + 100;
                      final isSelected = val == _height.toInt();
                      return Center(child: Text("$val cm", style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white38, fontSize: isSelected ? 28 : 20, fontWeight: FontWeight.bold)));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(l10n.onboardingWeightTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(l10n.onboardingWeightDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ),
        const Spacer(),
        // Показываем текущий вес
        SizedBox(
          height: 200,
          child: BodyVisualizer(weight: _weight, height: _height, phaseColor: Colors.blueAccent, isFasting: false),
        ),
        Text("${_weight.toInt()} kg", style: const TextStyle(color: Colors.blueAccent, fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.2, initialPage: (_weight * 10).toInt() - 300),
            onPageChanged: (index) {
              _haptic.selectionClick();
              setState(() => _weight = (index + 300) / 10.0);
            },
            itemBuilder: (context, index) {
              return Center(child: Container(width: 2, height: index % 10 == 0 ? 40 : 20, color: Colors.white.withOpacity(index % 10 == 0 ? 0.8 : 0.3)));
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildGoalWeightStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(l10n.onboardingGoalTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(l10n.onboardingGoalDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ),
        const Spacer(),
        // Показываем целевой вес (зеленый цвет для цели)
        SizedBox(
          height: 200,
          child: BodyVisualizer(weight: _goalWeight, height: _height, phaseColor: Colors.greenAccent, isFasting: false),
        ),
        Text("${_goalWeight.toInt()} kg", style: const TextStyle(color: Colors.greenAccent, fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.2, initialPage: (_goalWeight * 10).toInt() - 300),
            onPageChanged: (index) {
              _haptic.selectionClick();
              setState(() => _goalWeight = (index + 300) / 10.0);
            },
            itemBuilder: (context, index) {
              return Center(child: Container(width: 2, height: index % 10 == 0 ? 40 : 20, color: Colors.white.withOpacity(index % 10 == 0 ? 0.8 : 0.3)));
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }
}