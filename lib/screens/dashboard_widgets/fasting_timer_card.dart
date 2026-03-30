import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';

import 'package:fastable/bloc/weight/weight_state.dart';
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
import 'package:fastable/ui/app_layout.dart';

import '../../models/fasting_record.dart';
import '../circadian_plan_screen.dart';
import '../plan_selection_screen.dart';

class FastingTimerCard extends StatefulWidget {
  final VoidCallback? onStartFasting;

  const FastingTimerCard({super.key, this.onStartFasting});

  @override
  State<FastingTimerCard> createState() => _FastingTimerCardState();
}

class _FastingTimerCardState extends State<FastingTimerCard> {

  void _startFastNow(BuildContext context, FastingState state) {
    getIt<HapticService>().mediumImpact();
    if (state.planIndex == FastingState.circadianPlanIndex &&
        state.phase == FastingPhase.stopped) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CircadianPlanScreen()),
      );
      return;
    }
    if (widget.onStartFasting != null) widget.onStartFasting!();
    context.read<FastingBloc>().add(StartFasting(startTime: DateTime.now()));
  }

  void _logStartEarlier(BuildContext context) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: AppLocalizations.of(context)!.dialogStartTitle,
      initialTime: DateTime.now().subtract(const Duration(hours: 12)),
    );

    if (!context.mounted || pickedTime == null) {
      return;
    }

    if (pickedTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.timerCannotStartFuture),
        ),
      );
      return;
    }

    context.read<FastingBloc>().add(StartFasting(startTime: pickedTime));
  }

  void _endFast(
      BuildContext context,
      FastingState state, {
        DateTime? customEndTime,
      }) async {
    getIt<HapticService>().mediumImpact();
    final endTimeToUse = customEndTime ?? DateTime.now();

    if (endTimeToUse.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.timerCannotEndFuture),
        ),
      );
      return;
    }

    if (state.startTime != null && endTimeToUse.isBefore(state.startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.timerEndBeforeStart),
        ),
      );
      return;
    }

    final FastingMood? result = await showModalBottomSheet<FastingMood>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EndFastDialog(duration: state.elapsed),
    );

    if (!context.mounted || result == null) {
      return;
    }

    context.read<FastingBloc>().add(
      EndFasting(endTime: endTimeToUse, mood: result),
    );
  }

  void _logEndEarlier(BuildContext context, FastingState state) async {
    final pickedTime = await showTimePickerSheet(
      context: context,
      title: AppLocalizations.of(context)!.timerEndTitle,
      initialTime: DateTime.now(),
    );
    if (!context.mounted || pickedTime == null) {
      return;
    }

    _endFast(context, state, customEndTime: pickedTime);
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

  void _showBodyVisualizerModal(BuildContext context, Color stateColor, bool isFasting) {
    getIt<HapticService>().selectionClick();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: BlocBuilder<WeightBloc, WeightState>(
                      builder: (ctxWeight, weightState) {
                        return BodyVisualizer(
                          weight: weightState.currentWeight,
                          height: weightState.heightCm,
                          phaseColor: stateColor,
                          isFasting: isFasting,
                          chestCm: weightState.chestCm,
                          waistCm: weightState.waistCm,
                          hipsCm: weightState.hipsCm,
                          onChestTap: () {
                            showRouletteSheet<double>(
                              context: ctx,
                              title: l10n.bodyMeasureChestTitle,
                              items: List.generate(150, (i) => 50.0 + i),
                              initialItem: (weightState.chestCm ?? 90.0).toDouble().clamp(50.0, 200.0),
                              textMapper: (val) => "${val.toInt()} ${l10n.unitCm}",
                              onSave: (val) => ctx.read<WeightBloc>().add(UpdateChest(val)),
                            );
                          },
                          onWaistTap: () {
                            showRouletteSheet<double>(
                              context: ctx,
                              title: l10n.bodyMeasureWaistTitle,
                              items: List.generate(150, (i) => 40.0 + i),
                              initialItem: (weightState.waistCm ?? 70.0).toDouble().clamp(40.0, 190.0),
                              textMapper: (val) => "${val.toInt()} ${l10n.unitCm}",
                              onSave: (val) => ctx.read<WeightBloc>().add(UpdateWaist(val)),
                            );
                          },
                          onHipsTap: () {
                            showRouletteSheet<double>(
                              context: ctx,
                              title: l10n.bodyMeasureHipsTitle,
                              items: List.generate(150, (i) => 50.0 + i),
                              initialItem: (weightState.hipsCm ?? 95.0).toDouble().clamp(50.0, 200.0),
                              textMapper: (val) => "${val.toInt()} ${l10n.unitCm}",
                              onSave: (val) => ctx.read<WeightBloc>().add(UpdateHips(val)),
                            );
                          },
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FastingBloc, FastingState>(
      buildWhen: (prev, curr) =>
      prev.phase != curr.phase ||
          prev.planIndex != curr.planIndex ||
          prev.goalDuration != curr.goalDuration,
      builder: (context, state) {

        final isFasting = state.phase == FastingPhase.fasting;
        final isCircadian =
            state.planIndex ==
                FastingState.circadianPlanIndex;

        final currentStage = isFasting
            ? FastingStage.getCurrentStage(state.elapsed.inMinutes / 60.0)
            : FastingStage.allStages[0];

        final Color stateColor = state.phase == FastingPhase.eating
            ? const Color(0xFF84FAB0)
            : (state.phase == FastingPhase.stopped
            ? Colors.blueAccent
            : (isCircadian
            ? Colors.indigoAccent
            : currentStage
            .color));

        final IconData stageIcon = state.phase == FastingPhase.eating
            ? Icons.restaurant
            : (isCircadian
            ? Icons.nights_stay_rounded
            : currentStage.icon);

        String stateText = isFasting
            ? l10n.fastingPhase
            : (state.phase == FastingPhase.eating
            ? l10n.eatingWindow
            : l10n.readyToFast);

        bool isOvertime = state.phase != FastingPhase.stopped && state.elapsed >= state.goalDuration;

        String planName;
        if (state.planIndex == FastingState.circadianPlanIndex) {
          planName = "☀️ ${l10n.planCircadianTitle}";
        } else if (state.planIndex == FastingState.customPlanIndex) {
          planName =
          "${l10n.customPlan} (${l10n.durationHoursShort(state.goalDuration.inHours)})";
        } else if (state.planIndex >= 0 &&
            state.planIndex < FastingPlan.defaultPlans.length) {
          planName =
          "${FastingPlan.defaultPlans[state.planIndex].fastingDuration.inHours}:${FastingPlan.defaultPlans[state.planIndex].eatingDuration.inHours}";
        } else {
          planName = l10n.timerUnknownPlan;
        }

        final Widget? headerBadge = isFasting && !isOvertime
            ? Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: isCircadian
                ? null
                : () => _showStageDetails(
                context, context.read<FastingBloc>().state.elapsed),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: stateColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stateColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(stageIcon, color: stateColor, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isCircadian
                          ? l10n.circadianManaged
                          : currentStage.getTitle(l10n),
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isCircadian) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: stateColor.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
            : null;

        final Widget viewToggleButton = GestureDetector(
          onTap: () => _showBodyVisualizerModal(context, stateColor, isFasting),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(
              Icons.accessibility_new_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 20,
            ),
          ),
        );

        final Widget planSelector = GestureDetector(
          onTap: () async {
            getIt<HapticService>().lightImpact();
            final int? result = await Navigator.push<int>(
              context,
              MaterialPageRoute(builder: (_) => const PlanSelectionScreen()),
            );
            if (!context.mounted || result == null) {
              return;
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    planName,
                    style: TextStyle(
                      color: isCircadian ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_calendar_rounded,
                  color: isCircadian ? Colors.amber : Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
        );

        final Widget breakButton = GestureDetector(
          onTap: () {
            getIt<HapticService>().mediumImpact();
            if (state.phase == FastingPhase.stopped) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.timerBreakAlreadyActive),
                  backgroundColor: Colors.blueAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              context.read<FastingBloc>().add(ResetFasting());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.timerRestDayStarted),
                  backgroundColor: Colors.blueAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.coffee_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.timerTakeBreak,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final Widget startButton = GestureDetector(
          onTap: () => _startFastNow(context, context.read<FastingBloc>().state),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: stateColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.startFast,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final bool useStackedIdleButtons =
            MediaQuery.sizeOf(context).width < 430;
        final cardPadding = AppLayout.cardPadding(context);
        final sectionGap = AppLayout.sectionGap(context);

        return GlassCard(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: cardPadding + 2,
          ),
          child: Column(
            children: [
              // --- 1. ОРГАНИЗОВАННЫЙ HEADER ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stateText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (headerBadge != null) headerBadge,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  viewToggleButton,
                ],
              ),
              const SizedBox(height: 6),
              planSelector,
              SizedBox(height: sectionGap + 4),

              // --- 2. ЦЕНТРАЛЬНЫЙ КОНТЕНТ ---
              SizedBox(
                height: 190,
                width: double.infinity,
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: _TimerDisplay(
                    phase: state.phase,
                    isCircadian: isCircadian,
                    stateColor: stateColor,
                    goalDuration: state.goalDuration,
                  ),
                ),
              ),
              SizedBox(height: sectionGap + 18),

              // --- 3. БЛОК ДЕЙСТВИЙ ---

              // Премиальная кнопка Дневника (Log Mood)
              if (isFasting) ...[
                GestureDetector(
                  onTap: () => showLogMoodSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            l10n.timerLogMoodSymptoms,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sectionGap + 4),
              ],

              // Главные кнопки (Start / Stop / Break)
              if (isFasting)
                GestureDetector(
                  onTap: () => _endFast(context, context.read<FastingBloc>().state),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: stateColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: stateColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 20,
                        ), // Иконка финиша
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.endFast,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                useStackedIdleButtons
                    ? Column(
                  children: [
                    breakButton,
                    SizedBox(height: sectionGap),
                    startButton,
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: breakButton),
                    SizedBox(width: sectionGap),
                    Expanded(child: startButton),
                  ],
                ),

              const SizedBox(height: 8),

              // Ретроактивная кнопка с иконкой (Log earlier)
              if (!(state.phase == FastingPhase.stopped && isCircadian))
                TextButton(
                  onPressed: () {
                    if (state.phase == FastingPhase.stopped) {
                      _logStartEarlier(context);
                    } else if (isFasting) {
                      _logEndEarlier(context, state);
                    } else {
                      _logStartEarlier(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Icon(Icons.history_rounded, size: 16),
                      Text(
                        state.phase == FastingPhase.stopped
                            ? l10n.timerLogStartEarlier
                            : (isFasting
                            ? l10n.timerLogEndEarlier
                            : l10n.timerLogFastStartEarlier),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// 🔥 ОПТИМИЗИРОВАННЫЙ ВИДЖЕТ ТАЙМЕРА (Перерисовывается только текст!)
class _TimerDisplay extends StatelessWidget {
  final FastingPhase phase;
  final bool isCircadian;
  final Color stateColor;
  final Duration goalDuration;

  const _TimerDisplay({
    required this.phase,
    required this.isCircadian,
    required this.stateColor,
    required this.goalDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isFasting = phase == FastingPhase.fasting;

    // BlocSelector слушает только изменение elapsed-времени!
    return BlocSelector<FastingBloc, FastingState, Duration>(
      selector: (state) => state.elapsed,
      builder: (context, elapsed) {
        final l10n = AppLocalizations.of(context)!;

        Duration displayTime;
        String timeSubtext;
        Color subtextColor = Colors.white70;
        bool isOvertime = false;
        Color timeColor = Colors.white;

        if (phase == FastingPhase.stopped) {
          displayTime = goalDuration;
          timeSubtext = l10n.targetGoal;
        } else {
          if (elapsed >= goalDuration) {
            isOvertime = true;
            displayTime = elapsed;

            if (isFasting) {
              timeSubtext = l10n.timerGoalReachedExtra;
              subtextColor = Colors.amber;
              timeColor = Colors.amberAccent;
            } else {
              timeSubtext = l10n.timerWindowExtended;
              subtextColor = Colors.white54;
              timeColor = Colors.white.withValues(alpha: 0.9);
            }
          } else {
            displayTime = goalDuration - elapsed;
            if (isCircadian) {
              timeSubtext = phase == FastingPhase.eating
                  ? l10n.circadianTargetSunset
                  : l10n.circadianTargetSunrise;
            } else {
              timeSubtext = phase == FastingPhase.eating
                  ? l10n.timerRemainingInWindow
                  : l10n.remaining;
            }
          }
        }

        final String timeString = "${displayTime.inHours.toString().padLeft(2, '0')}:${(displayTime.inMinutes % 60).toString().padLeft(2, '0')}:${(displayTime.inSeconds % 60).toString().padLeft(2, '0')}";

        final double blobPercent = (phase == FastingPhase.stopped)
            ? 0.0
            : (elapsed.inSeconds / goalDuration.inSeconds).clamp(0.0, 1.0);

        return GradientTimerBlob(
          percent: blobPercent,
          isFasting: isFasting,
          colors: [
            stateColor.withValues(alpha: 0.5),
            stateColor,
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: timeColor,
                      letterSpacing: -1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  timeSubtext,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: isOvertime ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}