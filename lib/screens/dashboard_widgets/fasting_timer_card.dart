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

  void _endFast(BuildContext context, FastingState state, {DateTime? customEndTime}) async {
    getIt<HapticService>().mediumImpact();
    final endTimeToUse = customEndTime ?? DateTime.now();

    if (endTimeToUse.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot end fast in the future!"))
      );
      return;
    }

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

  void _logEatingEndEarlier(BuildContext context) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: "When did you stop eating?",
      initialTime: DateTime.now(),
    );
    if (pickedTime != null && mounted) {
      if (pickedTime.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot log time in the future!"))
        );
        return;
      }
      context.read<FastingBloc>().add(EndEatingWindow(endTime: pickedTime));
    }
  }

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
                        Text(stateText, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        if (isFasting && !_isBodyView && !isOvertime)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              onTap: () => _showStageDetails(context, state.elapsed),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: stateColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: stateColor.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(stageIcon, color: stateColor, size: 14),
                                    const SizedBox(width: 6),
                                    Flexible(child: Text(currentStage.getTitle(l10n), style: TextStyle(color: stateColor, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.chevron_right_rounded, color: stateColor.withOpacity(0.7), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Кнопка смены вида (3D / Таймер)
                      GestureDetector(
                        onTap: () {
                          getIt<HapticService>().selectionClick();
                          setState(() => _isBodyView = !_isBodyView);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: _isBodyView ? stateColor.withOpacity(0.6) : Colors.white.withOpacity(0.15))
                          ),
                          child: Icon(_isBodyView ? Icons.timer_outlined : Icons.accessibility_new_rounded, color: Colors.white.withOpacity(0.9), size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Кнопка выбора плана
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15))
                          ),
                          child: Row(children: [
                            Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit_calendar_rounded, color: Colors.white70, size: 14)
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

              // --- 3. БЛОК ДЕЙСТВИЙ ---

              // Премиальная кнопка Дневника (Log Mood)
              if (isFasting) ...[
                GestureDetector(
                  onTap: () => showLogMoodSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text("Log Mood & Symptoms", style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Главные кнопки (Start / Stop / Break)
              if (isFasting)
                GestureDetector(
                  onTap: () => _endFast(context, state),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                          color: stateColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_rounded, color: Colors.white, size: 20), // Иконка финиша
                          SizedBox(width: 8),
                          Text(
                              "END FAST NOW",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)
                          ),
                        ],
                      )
                  ),
                )
              else
                Row(
                  children: [
                    // КНОПКА ПЕРЕРЫВА (TAKE A BREAK)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          getIt<HapticService>().mediumImpact();
                          if (state.phase == FastingPhase.stopped) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("You are already on a break. Enjoy your rest! ☕"),
                                  backgroundColor: Colors.blueAccent,
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          } else {
                            context.read<FastingBloc>().add(ResetFasting());
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Eating window closed. Enjoy your rest day! 🏖️"),
                                  backgroundColor: Colors.blueAccent,
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.coffee_rounded, color: Colors.white70, size: 18),
                                SizedBox(width: 8),
                                Text(
                                    "TAKE A BREAK",
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5)
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // КНОПКА НАЧАЛА ГОЛОДАНИЯ (START FAST)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _startFastNow(context),
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                                color: stateColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text(
                                    "START FAST",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Ретроактивная кнопка с иконкой (Log earlier)
              TextButton.icon(
                onPressed: () {
                  if (state.phase == FastingPhase.stopped) _logStartEarlier(context);
                  else if (isFasting) _logEndEarlier(context, state);
                  else _logStartEarlier(context);
                },
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text(
                  state.phase == FastingPhase.stopped ? "Log start earlier" : (isFasting ? "Log end earlier" : "Log fast start earlier"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}