import 'package:flutter/material.dart';
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
    final soundService = SoundService(); // Лучше заинжектить через GetIt если singleton

    return Row(
      children: [
        // WATER CARD
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
        // WEIGHT CARD
        Expanded(
          flex: 4,
          child: BlocBuilder<WeightBloc, WeightState>(
            builder: (context, weightState) {
              return GlassCard(
                onTap: () => _showWeightPicker(context, weightState),
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

  void _showWeightPicker(BuildContext context, WeightState state) {
    final l10n = AppLocalizations.of(context)!;
    getIt<HapticService>().mediumImpact();

    // Оптимизация: не генерируем список здесь, если это возможно, но пока оставим
    final weights = List.generate(2700, (index) => 30.0 + (index * 0.1));

    double current = state.currentWeight > 0 ? state.currentWeight : 70.0;
    current = (current * 10).round() / 10.0;
    if (current < 30.0) current = 30.0;
    if (current > 299.9) current = 299.9;

    showRouletteSheet<double>(
      context: context,
      title: "${l10n.logWeight} (${l10n.unitKg})",
      items: weights,
      initialItem: current,
      textMapper: (val) => val.toStringAsFixed(1),
      onSave: (newWeight) {
        context.read<WeightBloc>().add(AddWeightEntry(newWeight));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Weight saved"), backgroundColor: Colors.green)
        );
      },
    );
  }
}