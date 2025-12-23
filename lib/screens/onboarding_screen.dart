import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
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

  // Начальные значения
  int _height = 175;
  double _weight = 70.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          child: Column(
            children: [
              // Прогресс бар (точки сверху)
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
                  physics: const NeverScrollableScrollPhysics(), // Запрещаем свайп пальцем, только кнопка
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    // СТР. 1: РОСТ (Рулетка)
                    _buildInputPage(
                      title: l10n.onboardingHeightTitle,
                      desc: l10n.onboardingHeightDesc,
                      // Диапазон 100 - 250 см
                      child: _buildRoulettePicker(
                        minValue: 100,
                        count: 151,
                        initialValue: _height,
                        suffix: l10n.cm,
                        onChanged: (val) => setState(() => _height = val),
                      ),
                    ),

                    // СТР. 2: ВЕС (Рулетка с дробными)
                    _buildInputPage(
                      title: l10n.onboardingWeightTitle,
                      desc: l10n.onboardingWeightDesc,
                      // Диапазон 30.0 - 200.0 кг
                      child: _buildDecimalRoulettePicker(
                        initialValue: _weight,
                        suffix: l10n.kg,
                        onChanged: (val) => setState(() => _weight = val),
                      ),
                    ),
                  ],
                ),
              ),

              // Кнопка Далее
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
          const SizedBox(height: 10),
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
          // Сама рулетка по центру
          Center(child: child),
          const Spacer(),
        ],
      ),
    );
  }

  // Рулетка для целых чисел (Рост)
  Widget _buildRoulettePicker({
    required int minValue,
    required int count,
    required int initialValue,
    required String suffix,
    required Function(int) onChanged,
  }) {
    return SizedBox(
      height: 250,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: initialValue - minValue),
        onSelectedItemChanged: (index) {
          HapticFeedback.selectionClick(); // Вибрация при прокрутке
          onChanged(minValue + index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            final value = minValue + index;
            final isSelected = value == _height; // Для подсветки (условно, т.к. перерисовка идет по setState)

            return Center(
              child: Text(
                "$value $suffix",
                style: TextStyle(
                  color: Colors.white, // Всегда белый, фокус по центру
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Рулетка для дробных чисел (Вес)
  Widget _buildDecimalRoulettePicker({
    required double initialValue,
    required String suffix,
    required Function(double) onChanged,
  }) {
    // 30.0 кг ... 200.0 кг (шаг 0.1) -> (200-30)*10 = 1700 элементов
    const int minWeightInt = 300; // 30.0 * 10

    return SizedBox(
      height: 250,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: (initialValue * 10).toInt() - minWeightInt),
        onSelectedItemChanged: (index) {
          HapticFeedback.selectionClick();
          double val = (minWeightInt + index) / 10.0;
          onChanged(val);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 1700,
          builder: (context, index) {
            final value = (minWeightInt + index) / 10.0;
            return Center(
              child: Text(
                "${value.toStringAsFixed(1)} $suffix",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
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
      await prefs.setBool('is_first_run', false);

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