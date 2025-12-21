import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  int _selectedIndex = 0; // Индекс текущего выбранного плана

  // Список планов (должен совпадать с тем, что в HomePage, или быть вынесен в отдельный репозиторий)
  final List<FastingPlan> plans = [
    FastingPlan(
      fastingDuration: const Duration(hours: 16),
      eatingDuration: const Duration(hours: 8),
      translationKey: "fastingPlan16_8",
    ),
    FastingPlan(
      fastingDuration: const Duration(hours: 18),
      eatingDuration: const Duration(hours: 6),
      translationKey: "fastingPlan18_6",
    ),
    FastingPlan(
      fastingDuration: const Duration(hours: 20),
      eatingDuration: const Duration(hours: 4),
      translationKey: "fastingPlan20_4",
    ),
    FastingPlan(
      fastingDuration: const Duration(hours: 24),
      eatingDuration: const Duration(hours: 0), // 24 часа голода (OMAD/EatStopEat)
      translationKey: "fastingPlanEatStopEat",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
  }

  // Загружаем текущий выбор из памяти
  Future<void> _loadCurrentSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('fast_plan_index') ?? 0;
    });
  }

  // Сохраняем выбор и закрываем экран
  Future<void> _selectPlan(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fast_plan_index', index);

    setState(() {
      _selectedIndex = index;
    });

    // Небольшая задержка для визуального эффекта нажатия перед закрытием
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      // Возвращаем true, чтобы HomePage знал, что нужно обновиться
      Navigator.of(context).pop(true);
    }
  }

  String _getTranslatedName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "fastingPlan16_8": return l10n.fastingPlan16_8;
      case "fastingPlan18_6": return l10n.fastingPlan18_6;
      case "fastingPlan20_4": return l10n.fastingPlan20_4;
      case "fastingPlanEatStopEat": return l10n.fastingPlanEatStopEat;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black, // Подложка для MeshBackground
      body: MeshBackground(
        isFasting: true, // Используем теплый фон, так как мы выбираем режим
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER (Custom Apple Style) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Кнопка назад (Стеклянная круглая)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.choosePlan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- СПИСОК ПЛАНОВ ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isSelected = index == _selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _selectPlan(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          // Анимация границ при выборе
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)]
                                : [],
                          ),
                          child: GlassCard(
                            // Если выбран, делаем фон чуть светлее/золотее
                            color: isSelected ? Colors.amber.withOpacity(0.15) : null,
                            border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Название плана
                                      Text(
                                        _getTranslatedName(context, plan.translationKey),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Визуализация часов (Fasting / Eating)
                                      Row(
                                        children: [
                                          _buildPhaseBadge(
                                            Icons.local_fire_department,
                                            "${plan.fastingDuration.inHours}h",
                                            Colors.orangeAccent,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildPhaseBadge(
                                            Icons.restaurant,
                                            "${plan.eatingDuration.inHours}h",
                                            const Color(0xFF84FAB0),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),

                                // Индикатор выбора (Checkmark)
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.black, size: 16),
                                  )
                                else
                                  Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24, width: 2),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Маленький бейдж для отображения часов
  Widget _buildPhaseBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}