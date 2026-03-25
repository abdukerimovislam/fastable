import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/gradient_timer_blob.dart';
import 'package:fastable/widgets/body_visualizer.dart';
import 'package:fastable/widgets/end_fast_dialog.dart';
import 'package:fastable/widgets/fasting_stage_widget.dart';
import 'package:fastable/utils/time_picker_sheet.dart';
import 'package:fastable/utils/roulette_sheet.dart';
import 'package:fastable/utils/log_mood_sheet.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/models/fasting_stage.dart';

import '../../models/fasting_record.dart';
import '../plan_selection_screen.dart';

class FastingTimerCard extends StatefulWidget {
  final VoidCallback? onStartFasting;

  const FastingTimerCard({
    super.key,
    this.onStartFasting,
  });

  @override
  State<FastingTimerCard> createState() => _FastingTimerCardState();
}

class _FastingTimerCardState extends State<FastingTimerCard> {
  bool _isBodyView = false;

  // --- INTENT-BASED ACTIONS (СТАРТ) ---
  void _startFastNow(BuildContext context) {
    getIt<HapticService>().mediumImpact();
    if (widget.onStartFasting != null) widget.onStartFasting!();
    context.read<FastingBloc>().add(StartFasting(startTime: DateTime.now()));
  }

  void _logStartEarlier(BuildContext context) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: "When did you start?",
      initialTime: DateTime.now().subtract(const Duration(hours: 12)),
    );

    if (pickedTime != null && mounted) {
      if (pickedTime.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot start in the future!"))
        );
        return;
      }
      context.read<FastingBloc>().add(StartFasting(startTime: pickedTime));
    }
  }

  // --- INTENT-BASED ACTIONS (КОНЕЦ ГОЛОДАНИЯ) ---
  void _endFast(BuildContext context, FastingState state, {DateTime? customEndTime}) async {
    getIt<HapticService>().mediumImpact();
    final endTimeToUse = customEndTime ?? DateTime.now();
    if (state.startTime != null && endTimeToUse.isBefore(state.startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End time cannot be before start time!"))
      );
      return;
    }

    final FastingMood? result = await showModalBottomSheet<FastingMood>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EndFastDialog(duration: state.elapsed),
    );

    if (result != null && mounted) {
      context.read<FastingBloc>().add(EndFasting(endTime: endTimeToUse, mood: result));
    }
  }

  void _logEndEarlier(BuildContext context, FastingState state) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: "When did you break your fast?",
      initialTime: DateTime.now(),
    );
    if (pickedTime != null && mounted) {
      _endFast(context, state, customEndTime: pickedTime);
    }
  }

  // --- INTENT-BASED ACTIONS (КОНЕЦ ОКНА ЕДЫ) ---
  void _endEatingNow(BuildContext context) {
    getIt<HapticService>().mediumImpact();
    context.read<FastingBloc>().add(EndEatingWindow(endTime: DateTime.now()));
  }

  void _logEatingEndEarlier(BuildContext context) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: "When did you stop eating?",
      initialTime: DateTime.now(),
    );
    if (pickedTime != null && mounted) {
      context.read<FastingBloc>().add(EndEatingWindow(endTime: pickedTime));
    }
  }

  // --- UI HELPERS ---
  void _showStageDetails(BuildContext context, Duration elapsed) {
    getIt<HapticService>().selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () {},
                child: FastingStageWidget(elapsedDuration: elapsed),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) => "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FastingBloc, FastingState>(
      builder: (context, state) {
        final weight = context.select((WeightBloc b) => b.state.currentWeight);
        final height = context.select((WeightBloc b) => b.state.heightCm);

        final isFasting = state.phase == FastingPhase.fasting;
        final currentStage = isFasting ? FastingStage.getCurrentStage(state.elapsed.inMinutes / 60.0) : FastingStage.allStages[0];

        final Color stateColor = state.phase == FastingPhase.eating
            ? const Color(0xFF84FAB0)
            : (state.phase == FastingPhase.stopped ? Colors.blueAccent : currentStage.color);

        final IconData stageIcon = state.phase == FastingPhase.eating ? Icons.restaurant : currentStage.icon;

        String stateText = isFasting ? l10n.fastingPhase : (state.phase == FastingPhase.eating ? l10n.eatingWindow : "Resting Phase");

        Duration displayTime;
        String timeSubtext;
        Color subtextColor = Colors.white70;
        bool isOvertime = false;
        Color timeColor = Colors.white;

        if (state.phase == FastingPhase.stopped) {
          displayTime = state.goalDuration;
          timeSubtext = "Target Goal";
        } else {
          if (state.elapsed >= state.goalDuration) {
            isOvertime = true;
            displayTime = state.elapsed;

            if (isFasting) {
              timeSubtext = "🔥 Goal Reached! (+ Extra)";
              subtextColor = Colors.amber;
              timeColor = Colors.amberAccent;
            } else {
              timeSubtext = "Window extended";
              subtextColor = Colors.white54;
              timeColor = Colors.white.withOpacity(0.9);
            }
          } else {
            displayTime = state.goalDuration - state.elapsed;
            timeSubtext = state.phase == FastingPhase.eating ? "Remaining in window" : "Remaining";
          }
        }

        final timeString = _formatDuration(displayTime);
        final double blobPercent = (state.phase == FastingPhase.stopped) ? 0.0 : (state.elapsed.inSeconds / state.goalDuration.inSeconds).clamp(0.0, 1.0);

        String planName = state.planIndex == FastingState.customPlanIndex
            ? "${l10n.customPlan} (${state.goalDuration.inHours}h)"
            : "${FastingPlan.defaultPlans[state.planIndex].fastingDuration.inHours}:${FastingPlan.defaultPlans[state.planIndex].eatingDuration.inHours}";

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // --- 1. ОРГАНИЗОВАННЫЙ HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stateText, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                        if (isFasting && !_isBodyView && !isOvertime)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: GestureDetector(
                              onTap: () => _showStageDetails(context, state.elapsed),
                              child: Row(
                                children: [
                                  Icon(stageIcon, color: stateColor, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(child: Text(currentStage.getTitle(l10n), style: TextStyle(color: stateColor, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.info_outline, color: stateColor.withOpacity(0.5), size: 14),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Кнопка смены вида 3D
                      GestureDetector(
                        onTap: () {
                          getIt<HapticService>().selectionClick();
                          setState(() => _isBodyView = !_isBodyView);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: _isBodyView ? stateColor.withOpacity(0.5) : Colors.white.withOpacity(0.1))),
                          child: Icon(_isBodyView ? Icons.timer_outlined : Icons.accessibility_new_rounded, color: Colors.white70, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Кнопка смены плана
                      GestureDetector(
                        onTap: () async {
                          getIt<HapticService>().lightImpact();
                          final bool? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));
                          if (result == true && mounted) {
                            final prefs = await SharedPreferences.getInstance();
                            final newIdx = prefs.getInt('fast_plan_index') ?? 0;
                            if (newIdx != FastingState.customPlanIndex) {
                              context.read<FastingBloc>().add(ChangePlan(newIdx));
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                          child: Row(children: [
                            Text(planName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, color: Colors.white54, size: 14)
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- 2. ЦЕНТРАЛЬНЫЙ КОНТЕНТ ---
              SizedBox(
                height: 280,
                width: double.infinity,
                child: _isBodyView
                    ? Center(
                  child: BodyVisualizer(
                    weight: weight, height: height, phaseColor: stateColor, isFasting: isFasting,
                    chestCm: context.select((WeightBloc b) => b.state.chestCm),
                    waistCm: context.select((WeightBloc b) => b.state.waistCm),
                    hipsCm: context.select((WeightBloc b) => b.state.hipsCm),
                    onChestTap: () {
                      showRouletteSheet<double>(
                        context: context, title: "Chest Size (cm)", items: List.generate(150, (i) => 50.0 + i),
                        initialItem: (context.read<WeightBloc>().state.chestCm ?? 90.0).clamp(50.0, 200.0), textMapper: (val) => "${val.toInt()} cm",
                        onSave: (val) => context.read<WeightBloc>().add(UpdateChest(val)),
                      );
                    },
                    onWaistTap: () {
                      showRouletteSheet<double>(
                        context: context, title: "Waist Size (cm)", items: List.generate(150, (i) => 40.0 + i),
                        initialItem: (context.read<WeightBloc>().state.waistCm ?? 70.0).clamp(40.0, 190.0), textMapper: (val) => "${val.toInt()} cm",
                        onSave: (val) => context.read<WeightBloc>().add(UpdateWaist(val)),
                      );
                    },
                    onHipsTap: () {
                      showRouletteSheet<double>(
                        context: context, title: "Hips Size (cm)", items: List.generate(150, (i) => 50.0 + i),
                        initialItem: (context.read<WeightBloc>().state.hipsCm ?? 95.0).clamp(50.0, 200.0), textMapper: (val) => "${val.toInt()} cm",
                        onSave: (val) => context.read<WeightBloc>().add(UpdateHips(val)),
                      );
                    },
                  ),
                )
                    : SizedBox(
                  width: 250, height: 250,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: GradientTimerBlob(
                      key: ValueKey<bool>(isFasting),
                      percent: blobPercent,
                      isFasting: isFasting,
                      colors: [stateColor.withOpacity(0.5), stateColor],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 52, fontWeight: FontWeight.w900, color: timeColor, letterSpacing: -1.0,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        shadows: const [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                                      )
                                  )
                              )
                          ),
                          const SizedBox(height: 4),
                          Text(timeSubtext, style: TextStyle(color: subtextColor, fontSize: 14, fontWeight: isOvertime ? FontWeight.bold : FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- 3. БЛОК ДЕЙСТВИЙ И КНОПОК ---

              // Кнопка дневника (Широкая, с текстом)
              if (isFasting) ...[
                GestureDetector(
                  onTap: () => showLogMoodSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_note_rounded, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text("Log Mood & Symptoms", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Главная массивная кнопка действия
              GestureDetector(
                onTap: () {
                  if (state.phase == FastingPhase.stopped) _startFastNow(context);
                  else if (isFasting) _endFast(context, state);
                  else _endEatingNow(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                      color: stateColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                  ),
                  child: Center(
                      child: Text(
                          state.phase == FastingPhase.stopped ? "START FAST NOW" : (isFasting ? "END FAST NOW" : "START NEXT FAST"),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)
                      )
                  ),
                ),
              ),

              // Ретроактивная текстовая кнопка в самом низу
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  if (state.phase == FastingPhase.stopped) _logStartEarlier(context);
                  else if (isFasting) _logEndEarlier(context, state);
                  else _logEatingEndEarlier(context);
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: Text(
                  state.phase == FastingPhase.stopped ? "Log start earlier" : (isFasting ? "Log end earlier" : "Log eating end earlier"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}