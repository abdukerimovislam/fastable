import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Для iOS-style пикера
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/services/sound_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/utils/roulette_sheet.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/body_visualizer.dart';

class WaterWeightRow extends StatelessWidget {
  const WaterWeightRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final soundService = SoundService();

    return Row(
      children: [
        // --- WATER CARD ---
        Expanded(
          flex: 5,
          child: BlocBuilder<WaterBloc, WaterState>(
            builder: (context, waterState) {
              return GlassCard(
                onTap: () {
                  soundService.playWaterSound();
                  getIt<HapticService>().lightImpact();
                  context.read<WaterBloc>().add(AddWaterCup());
                },
                onLongPress: () => _showWaterMenu(context, waterState),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 20)),
                      Text("${(waterState.progress * 100).toInt()}%", style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 12),
                    Text(l10n.waterIntake, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text("${waterState.consumedCups}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      Padding(padding: const EdgeInsets.only(bottom: 4, left: 4), child: Text("/ ${waterState.dailyGoal}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))
                    ])
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // --- WEIGHT CARD ---
        Expanded(
          flex: 4,
          child: BlocBuilder<WeightBloc, WeightState>(
            builder: (context, weightState) {
              return GlassCard(
                // 🔥 ТУТ МЫ ВЫЗЫВАЕМ НОВУЮ ФУНКЦИЮ
                onTap: () => _showWeightPickerWithBody(context, weightState),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF00FA9A).withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.show_chart_rounded, color: Color(0xFF00FA9A), size: 20)),
                      Icon(Icons.arrow_right_alt_rounded, color: const Color(0xFF00FA9A).withOpacity(0.8), size: 16)
                    ]),
                    const SizedBox(height: 12),
                    Text(l10n.currentWeight, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(weightState.currentWeight.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text(l10n.unitKg, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))
                    ])
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Меню воды оставляем как есть
  void _showWaterMenu(BuildContext context, WaterState state) {
    getIt<HapticService>().mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    final goals = List.generate(20, (index) => index + 1);

    showRouletteSheet<int>(
      context: context,
      title: l10n.dailyGoal,
      items: goals,
      initialItem: state.dailyGoal,
      textMapper: (val) => "$val ${l10n.cups}",
      onSave: (newGoal) {
        context.read<WaterBloc>().add(UpdateWaterGoal(newGoal));
      },
    );
  }

  // 🔥 НОВАЯ ФУНКЦИЯ ДЛЯ ВЫБОРА ВЕСА С ВИЗУАЛИЗАЦИЕЙ
  void _showWeightPickerWithBody(BuildContext context, WeightState state) {
    getIt<HapticService>().mediumImpact();
    final l10n = AppLocalizations.of(context)!; // Получаем локализацию

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WeightPickerSheet(
        initialWeight: state.currentWeight > 0 ? state.currentWeight : 70.0,
        heightCm: state.heightCm,
      ),
    ).then((result) {
      // Если вернулся результат (нажали Save)
      if (result != null && result is double) {
        if (!context.mounted) return; // Проверка mounted перед использованием контекста

        context.read<WeightBloc>().add(AddWeightEntry(result));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.weightSaved), // 🔥 Используем перевод
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

// ---------------------------------------------------------------------------
// 🔥 НОВЫЙ ВИДЖЕТ ШТОРКИ (С ТЕЛОМ И РУЛЕТКОЙ)
// ---------------------------------------------------------------------------
class _WeightPickerSheet extends StatefulWidget {
  final double initialWeight;
  final double heightCm;

  const _WeightPickerSheet({
    required this.initialWeight,
    required this.heightCm,
  });

  @override
  State<_WeightPickerSheet> createState() => _WeightPickerSheetState();
}

class _WeightPickerSheetState extends State<_WeightPickerSheet> {
  late double _currentWeight;
  late FixedExtentScrollController _scrollController;

  // Генерируем веса от 30.0 до 300.0 с шагом 0.1
  // Это 2700 элементов
  final List<double> _weights = List.generate(2700, (index) => 30.0 + (index * 0.1));

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.initialWeight;

    // Находим индекс текущего веса, чтобы проскроллить к нему
    // Формула обратная генерации: (Weight - 30) * 10
    int initialIndex = ((_currentWeight - 30.0) * 10).round();
    if (initialIndex < 0) initialIndex = 0;
    if (initialIndex >= _weights.length) initialIndex = _weights.length - 1;

    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85, // Высокая шторка
        decoration: const BoxDecoration(
          color: Color(0xFF141414), // Темный фон
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.logWeight, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, _currentWeight), // Возвращаем вес
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.saveWeight, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),

            // --- BODY VISUALIZER ---
            Expanded(
              child: Center(
                child: BodyVisualizer(
                  weight: _currentWeight,
                  height: widget.heightCm,
                  isFasting: false, // Просто показываем тело
                  phaseColor: Colors.blueAccent,
                ),
              ),
            ),

            // --- WEIGHT VALUE DISPLAY ---
            Text(
              "${_currentWeight.toStringAsFixed(1)} ${l10n.unitKg}",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- ROULETTE (PICKER) ---
            Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 30),
              child: CupertinoPicker.builder(
                scrollController: _scrollController,
                itemExtent: 50,
                diameterRatio: 1.5,
                magnification: 1.2,
                useMagnifier: true,
                onSelectedItemChanged: (index) {
                  getIt<HapticService>().selectionClick();
                  setState(() {
                    _currentWeight = _weights[index];
                  });
                },
                childCount: _weights.length,
                itemBuilder: (context, index) {
                  final val = _weights[index];
                  // Подсвечиваем выбранный
                  final isSelected = (_currentWeight - val).abs() < 0.05;
                  return Center(
                    child: Text(
                      val.toStringAsFixed(1),
                      style: TextStyle(
                        color: isSelected ? Colors.greenAccent : Colors.white24,
                        fontSize: isSelected ? 32 : 24,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}