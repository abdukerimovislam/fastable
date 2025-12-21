import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final WeightRepository _weightRepository = WeightRepository();

  int _currentPage = 0;

  // Данные для ввода
  int _height = 175;
  double _weight = 70.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false, // Спокойный фон
        child: SafeArea(
          child: Column(
            children: [
              // Прогресс бар
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    _buildProgressDot(0),
                    _buildProgressDot(1),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.onboardingTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Блокируем свайп, только кнопки
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    // СТР. 1: РОСТ
                    _buildInputPage(
                      title: l10n.onboardingHeightTitle,
                      desc: l10n.onboardingHeightDesc,
                      child: _buildHeightPicker(l10n),
                    ),

                    // СТР. 2: ВЕС
                    _buildInputPage(
                      title: l10n.onboardingWeightTitle,
                      desc: l10n.onboardingWeightDesc,
                      child: _buildWeightPicker(l10n),
                    ),
                  ],
                ),
              ),

              // Кнопка Далее/Финиш
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == 1 ? l10n.btnFinish : l10n.btnNext,
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

  Widget _buildProgressDot(int index) {
    bool isActive = index <= _currentPage;
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.white12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildInputPage({required String title, required String desc, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.4)),
              ],
            ),
          ),
          const Spacer(),
          child,
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeightPicker(AppLocalizations l10n) {
    return SizedBox(
      height: 200,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: _height - 100),
        onSelectedItemChanged: (index) => setState(() => _height = 100 + index),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 150,
          builder: (context, index) {
            final h = 100 + index;
            final isSelected = h == _height;
            return Center(
              child: Text(
                "$h ${l10n.cm}",
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.white30,
                  fontSize: isSelected ? 40 : 24,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeightPicker(AppLocalizations l10n) {
    return SizedBox(
      height: 200,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: (_weight * 10).toInt() - 300),
        onSelectedItemChanged: (index) {
          setState(() => _weight = (index + 300) / 10.0);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 1700, // 30.0 - 200.0 kg
          builder: (context, index) {
            final w = (index + 300) / 10.0;
            final isSelected = w == _weight;
            return Center(
              child: Text(
                "${w.toStringAsFixed(1)} ${l10n.kg}",
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.white30,
                  fontSize: isSelected ? 40 : 24,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _nextPage() async {
    if (_currentPage == 0) {
      // Сохраняем рост
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_height', _height);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Финиш: Сохраняем вес и завершаем
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_run', false); // Флаг: Онбординг пройден

      // Сохраняем вес через репозиторий (чтобы улетело и в Firebase, если юзер зашел)
      await _weightRepository.addWeightOrUpdateToday(_weight);

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage())
        );
      }
    }
  }
}