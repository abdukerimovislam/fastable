import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/screens/custom_plan_screen.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  int _selectedIndex = 0;
  final List<FastingPlan> plans = FastingPlan.defaultPlans;

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('fast_plan_index') ?? 0;
    });
  }

  Future<void> _selectPlan(int index) async {
    getIt<HapticService>().selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fast_plan_index', index);

    setState(() => _selectedIndex = index);

    if (mounted) {
      context.read<FastingBloc>().add(ChangePlan(index));
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openCustomPlan() async {
    getIt<HapticService>().mediumImpact();

    final int? customHours = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomPlanScreen()),
    );

    if (customHours != null && mounted) {
      context.read<FastingBloc>().add(SetCustomPlan(customHours));
      setState(() {
        _selectedIndex = FastingState.customPlanIndex;
      });
      Navigator.of(context).pop(true);
    }
  }

  String _getTranslatedName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    if (key.contains("16")) return l10n.fastingPlan16_8;
    if (key.contains("18")) return l10n.fastingPlan18_6;
    if (key.contains("20")) return l10n.fastingPlan20_4;
    if (key.contains("Stop")) return l10n.fastingPlanEatStopEat;
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid; // 🔥 Проверка платформы

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: true,
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
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

              // --- LIST ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    // 🔥 КНОПКА CUSTOM PLAN (Скрыта на Android)
                    if (!isAndroid)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: _openCustomPlan,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: _selectedIndex == FastingState.customPlanIndex
                                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)]
                                  : [],
                            ),
                            child: GlassCard(
                              color: _selectedIndex == FastingState.customPlanIndex
                                  ? Colors.blueAccent.withOpacity(0.15)
                                  : null,
                              border: _selectedIndex == FastingState.customPlanIndex
                                  ? Border.all(color: Colors.blueAccent, width: 2)
                                  : null,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.tune, color: Colors.blueAccent),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // Убедитесь, что l10n.customPlan существует, иначе используйте хардкод "Custom Plan"
                                          l10n.customPlan,
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Set your own window", // Можно вынести в l10n
                                          style: TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedIndex == FastingState.customPlanIndex)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent),
                                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                                    )
                                  else
                                    const Icon(Icons.chevron_right, color: Colors.white54),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ЗАГОЛОВОК ПРЕСЕТОВ (Показываем только если есть кастомный план, для разделения)
                    if (!isAndroid)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Text(
                          "PRESETS",
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),

                    // СТАНДАРТНЫЕ ПЛАНЫ
                    ...List.generate(plans.length, (index) {
                      final plan = plans[index];
                      final isSelected = _selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _selectPlan(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)]
                                  : [],
                            ),
                            child: GlassCard(
                              color: isSelected ? Colors.amber.withOpacity(0.15) : null,
                              border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getTranslatedName(context, plan.translationKey),
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildPhaseBadge(Icons.local_fire_department, "${plan.fastingDuration.inHours}h", Colors.orangeAccent),
                                            const SizedBox(width: 8),
                                            _buildPhaseBadge(Icons.restaurant, "${plan.eatingDuration.inHours}h", const Color(0xFF84FAB0)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                                      child: const Icon(Icons.check, color: Colors.black, size: 16),
                                    )
                                  else
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}