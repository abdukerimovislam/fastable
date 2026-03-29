import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/models/fasting_record.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/services/sound_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/utils/roulette_sheet.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/body_visualizer.dart';
import 'package:fastable/models/drink_record.dart';
import 'package:fastable/ui/app_layout.dart';

// ---------------------------------------------------------------------------
// ВОДА (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoWaterCard extends StatelessWidget {
  const BentoWaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final soundService = SoundService();

    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, waterState) {
        final fastingState = context.watch<FastingBloc>().state;

        return GlassCard(
          onTap: () => _showDrinkPicker(context, soundService, fastingState),
          onLongPress: () => _showWaterMenu(context, waterState),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                  Text(
                    "${(waterState.progress * 100).toInt()}%",
                    style: TextStyle(
                      color: Colors.blueAccent.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.waterIntake,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Row(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Text(
                     "${math.max(0, waterState.totalHydrationMl).toInt()}",
                     style: const TextStyle(
                       color: Colors.white,
                       fontSize: 22,
                       fontWeight: FontWeight.bold,
                       letterSpacing: -0.5,
                     ),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(bottom: 2, left: 4),
                     child: Text(
                       "/ ${waterState.dailyGoal}",
                       style: TextStyle(
                         color: Colors.white.withValues(alpha: 0.5),
                         fontSize: 10,
                       ),
                     ),
                   ),
                 ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- МЕТОДЫ ИЗ WaterWeightRow ---
  Future<bool?> _showBreakFastWarning(BuildContext context, DrinkType drink) {
    getIt<HapticService>().heavyImpact();
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.waterDrinkContainsCalories(drink.localizedName(l10n)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.waterBreakFastWarning,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Text(l10n.cancel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(l10n.waterConfirmDrinkBreakFast, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDrinkPicker(BuildContext context, SoundService soundService, FastingState fastingState) {
    getIt<HapticService>().mediumImpact();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(AppLayout.cardPadding(context)),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text(l10n.waterDrinkPrompt, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 16, childAspectRatio: 0.75,
                ),
                itemCount: DrinkType.allTypes.length,
                itemBuilder: (context, index) {
                  final drink = DrinkType.allTypes[index];
                  return GestureDetector(
                    onTap: () async {
                      getIt<HapticService>().lightImpact();
                      bool shouldProceed = true;
                      if (drink.breaksFast && fastingState.phase == FastingPhase.fasting) {
                        final confirmed = await _showBreakFastWarning(context, drink);
                        if (confirmed != true) shouldProceed = false;
                      }
                      if (!shouldProceed) {
                        if (context.mounted) Navigator.pop(ctx);
                        return;
                      }
                      soundService.playWaterSound();
                      if (context.mounted) {
                        context.read<WaterBloc>().add(AddDrink(type: drink, volumeMl: 250));
                        Navigator.pop(ctx);
                        if (drink.breaksFast && fastingState.phase == FastingPhase.fasting) {
                          context.read<FastingBloc>().add(EndFasting(endTime: DateTime.now(), mood: FastingMood.bad));
                        }
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: drink.color.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: drink.color.withValues(alpha: 0.3)),
                          ),
                          child: Icon(drink.icon, color: drink.color, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(drink.localizedName(l10n), textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600, height: 1.1)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showWaterMenu(BuildContext context, WaterState state) {
    getIt<HapticService>().mediumImpact();
    final goals = List.generate(13, (index) => 1000 + (index * 250));
    showRouletteSheet<int>(
      context: context,
      title: AppLocalizations.of(context)!.dailyGoal,
      items: goals,
      initialItem: state.dailyGoal.clamp(1000, 4000),
      textMapper: (val) => "$val ${AppLocalizations.of(context)!.unitMl}",
      onSave: (newGoal) => context.read<WaterBloc>().add(UpdateWaterGoal(newGoal)),
    );
  }
}

// ---------------------------------------------------------------------------
// ВЕС (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoWeightCard extends StatelessWidget {
  const BentoWeightCard({super.key});

  void _showWeightPickerWithBody(BuildContext context, WeightState state) {
    getIt<HapticService>().mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WeightPickerSheet(
        initialWeight: state.currentWeight > 0 ? state.currentWeight : 70.0,
        heightCm: state.heightCm,
      ),
    ).then((result) {
      if (result != null && result is double) {
        if (!context.mounted) return;
        context.read<WeightBloc>().add(AddWeightEntry(result));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.weightSaved), backgroundColor: Colors.green));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, weightState) {
        return GlassCard(
          onTap: () => _showWeightPickerWithBody(context, weightState),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FA9A).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      color: Color(0xFF00FA9A),
                      size: 20,
                    ),
                  ),
                  Icon(
                    Icons.arrow_right_alt_rounded,
                    color: const Color(0xFF00FA9A).withValues(alpha: 0.8),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.currentWeight,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weightState.currentWeight.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(
                      l10n.unitKg,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeightPickerSheet extends StatefulWidget {
  final double initialWeight;
  final double heightCm;
  const _WeightPickerSheet({required this.initialWeight, required this.heightCm});
  @override
  State<_WeightPickerSheet> createState() => _WeightPickerSheetState();
}

class _WeightPickerSheetState extends State<_WeightPickerSheet> {
  late double _currentWeight;
  late FixedExtentScrollController _scrollController;
  final List<double> _weights = List.generate(2700, (index) => 30.0 + (index * 0.1));

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.initialWeight;
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
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppLayout.cardPadding(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.logWeight, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, _currentWeight),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.saveWeight, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: BodyVisualizer(weight: _currentWeight, height: widget.heightCm, isFasting: false, phaseColor: Colors.blueAccent),
              ),
            ),
            Text("${_currentWeight.toStringAsFixed(1)} ${l10n.unitKg}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
                  setState(() => _currentWeight = _weights[index]);
                },
                childCount: _weights.length,
                itemBuilder: (context, index) {
                  final val = _weights[index];
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
