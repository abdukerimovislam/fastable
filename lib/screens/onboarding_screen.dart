import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

const String kHeightKey = 'user_height';
const String kGoalWeightKey = 'user_goal_weight';
const String kCurrentWeightKey = 'user_current_weight';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _height = 170;
  double _currentWeight = 70.0;
  double _goalWeight = 65.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MeshBackground(
      isFasting: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    // СТРАНИЦА 1
                    _buildPage(
                      title: l10n.onboardingWelcomeTitle,
                      desc: l10n.onboardingWelcomeDesc,
                      child: const Icon(Icons.favorite, size: 100, color: Colors.redAccent),
                    ),

                    // СТРАНИЦА 2
                    _buildDataPage(l10n),

                    // СТРАНИЦА 3
                    _buildPage(
                      title: "You are ready!",
                      desc: "Let's start your journey to a better version of yourself.",
                      child: const Icon(Icons.rocket_launch, size: 100, color: Colors.amber),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () async {
                    if (_currentPage < 2) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      // ФИНАЛ: Сохраняем данные
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt(kHeightKey, _height);
                      await prefs.setDouble(kGoalWeightKey, _goalWeight);
                      await prefs.setDouble(kCurrentWeightKey, _currentWeight);
                      await prefs.setBool('onboarding_complete', true);

                      // ИСПРАВЛЕНО: Используем безопасный метод сохранения веса
                      final weightRepo = WeightRepository();
                      await weightRepo.addWeightOrUpdateToday(_currentWeight);

                      if (mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == 2 ? l10n.getStarted : l10n.next,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String desc, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDataPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.onboardingGoalTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text("${l10n.settingHeight}: $_height cm", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Slider(
                  value: _height.toDouble(),
                  min: 100, max: 220,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _height = v.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text("${l10n.currentWeight}: ${_currentWeight.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Slider(
                  value: _currentWeight,
                  min: 40, max: 150,
                  activeColor: const Color(0xFF00FA9A),
                  onChanged: (v) => setState(() => _currentWeight = double.parse(v.toStringAsFixed(1))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}