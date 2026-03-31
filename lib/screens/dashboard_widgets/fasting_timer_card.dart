import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/app_theme.dart';
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
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/ui/app_layout.dart';

import '../circadian_plan_screen.dart';
import '../plan_selection_screen.dart';

class FastingTimerCard extends StatefulWidget {
  final VoidCallback? onStartFasting;
  final VoidCallback? onEndFasting; // 🔥 ДОБАВЛЕНО для рекламы

  const FastingTimerCard({
    super.key,
    this.onStartFasting,
    this.onEndFasting, // 🔥 ДОБАВЛЕНО
  });

  @override
  State<FastingTimerCard> createState() => _FastingTimerCardState();
}

class _FastingTimerCardState extends State<FastingTimerCard> {
  HapticService get _haptic => getIt<HapticService>();

  void _startFastNow(BuildContext context, FastingState state) {
    _haptic.mediumImpact();

    if (state.planIndex == FastingState.circadianPlanIndex &&
        state.phase == FastingPhase.stopped) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CircadianPlanScreen()),
      );
      return;
    }

    widget.onStartFasting?.call();
    context.read<FastingBloc>().add(StartFasting(startTime: DateTime.now()));
  }

  Future<void> _logStartEarlier(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final pickedTime = await showTimePickerSheet(
      context: context,
      title: l10n.dialogStartTitle,
      initialTime: DateTime.now().subtract(const Duration(hours: 12)),
    );

    if (!context.mounted || pickedTime == null) return;

    if (pickedTime.isAfter(DateTime.now())) {
      _showSnack(context, l10n.timerCannotStartFuture);
      return;
    }

    widget.onStartFasting?.call(); // Показываем рекламу и тут
    context.read<FastingBloc>().add(StartFasting(startTime: pickedTime));
  }

  Future<void> _endFast(
      BuildContext context,
      FastingState state, {
        DateTime? customEndTime,
      }) async {
    final l10n = AppLocalizations.of(context)!;
    if (customEndTime != null) {
      _haptic.mediumImpact();
    }

    final endTime = customEndTime ?? DateTime.now();

    if (endTime.isAfter(DateTime.now())) {
      _showSnack(context, l10n.timerCannotEndFuture);
      return;
    }

    if (state.startTime != null && endTime.isBefore(state.startTime!)) {
      _showSnack(context, l10n.timerEndBeforeStart);
      return;
    }

    final result = await showModalBottomSheet<FastingMood>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EndFastDialog(duration: state.elapsed),
    );

    if (!context.mounted || result == null) return;

    widget.onEndFasting?.call(); // 🔥 Вызываем показ рекламы после завершения диалога!

    context.read<FastingBloc>().add(
      EndFasting(endTime: endTime, mood: result),
    );
  }

  Future<void> _logEndEarlier(BuildContext context, FastingState state) async {
    final l10n = AppLocalizations.of(context)!;

    final pickedTime = await showTimePickerSheet(
      context: context,
      title: l10n.timerEndTitle,
      initialTime: DateTime.now(),
    );

    if (!context.mounted || pickedTime == null) return;
    await _endFast(context, state, customEndTime: pickedTime);
  }

  void _takeBreak(BuildContext context, FastingState state) {
    final l10n = AppLocalizations.of(context)!;
    _haptic.mediumImpact();

    if (state.phase == FastingPhase.stopped) {
      _showSnack(
        context,
        l10n.timerBreakAlreadyActive,
        backgroundColor: AppTheme.heroSecondary,
      );
      return;
    }

    context.read<FastingBloc>().add(ResetFasting());
    _showSnack(
      context,
      l10n.timerRestDayStarted,
      backgroundColor: AppTheme.heroSecondary,
    );
  }

  void _showSnack(
      BuildContext context,
      String text, {
        Color? backgroundColor,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStageDetails(BuildContext context, Duration elapsed) {
    _haptic.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => GestureDetector(
        onTap: () => Navigator.pop(sheetContext),
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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

  void _showBodyVisualizerModal(
      BuildContext context,
      Color stateColor,
      bool isFasting,
      ) {
    final l10n = AppLocalizations.of(context)!;
    _haptic.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
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
                        initialItem: (weightState.chestCm ?? 90.0)
                            .toDouble()
                            .clamp(50.0, 200.0),
                        textMapper: (v) => "${v.toInt()} ${l10n.unitCm}",
                        onSave: (v) =>
                            ctx.read<WeightBloc>().add(UpdateChest(v)),
                      );
                    },
                    onWaistTap: () {
                      showRouletteSheet<double>(
                        context: ctx,
                        title: l10n.bodyMeasureWaistTitle,
                        items: List.generate(150, (i) => 40.0 + i),
                        initialItem: (weightState.waistCm ?? 70.0)
                            .toDouble()
                            .clamp(40.0, 190.0),
                        textMapper: (v) => "${v.toInt()} ${l10n.unitCm}",
                        onSave: (v) =>
                            ctx.read<WeightBloc>().add(UpdateWaist(v)),
                      );
                    },
                    onHipsTap: () {
                      showRouletteSheet<double>(
                        context: ctx,
                        title: l10n.bodyMeasureHipsTitle,
                        items: List.generate(150, (i) => 50.0 + i),
                        initialItem: (weightState.hipsCm ?? 95.0)
                            .toDouble()
                            .clamp(50.0, 200.0),
                        textMapper: (v) => "${v.toInt()} ${l10n.unitCm}",
                        onSave: (v) =>
                            ctx.read<WeightBloc>().add(UpdateHips(v)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPlanSelector(BuildContext context) async {
    _haptic.lightImpact();

    await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const PlanSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardPadding = AppLayout.cardPadding(context);
    final sectionGap = AppLayout.sectionGap(context);

    return BlocBuilder<FastingBloc, FastingState>(
      buildWhen: (prev, curr) =>
      prev.phase != curr.phase ||
          prev.planIndex != curr.planIndex ||
          prev.goalDuration != curr.goalDuration,
      builder: (context, state) {
        final vm = _FastingCardViewModel.fromState(state, l10n);

        return GlassCard(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: cardPadding + 2,
          ),
          child: Column(
            children: [
              _HeaderSection(
                title: vm.stateText,
                badge: vm.showHeaderBadge
                    ? _StageBadge(
                  title: vm.badgeText,
                  color: vm.stateColor,
                  icon: vm.stageIcon,
                  tappable: !vm.isCircadian,
                  onTap: vm.isCircadian
                      ? null
                      : () => _showStageDetails(context, state.elapsed),
                )
                    : null,
                action: _CircleIconButton(
                  icon: Icons.accessibility_new_rounded,
                  onTap: () => _showBodyVisualizerModal(
                    context,
                    vm.stateColor,
                    vm.isFasting,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PlanSelector(
                planName: vm.planName,
                isCircadian: vm.isCircadian,
                onTap: () => _openPlanSelector(context),
              ),
              SizedBox(height: sectionGap + 4),
              _HeroTimerSection(
                phase: state.phase,
                isCircadian: vm.isCircadian,
                stateColor: vm.stateColor,
                goalDuration: state.goalDuration,
                stateLabel: vm.heroLabel,
              ),
              SizedBox(height: sectionGap + 18),

              if (vm.isFasting)
                HoldToCompleteButton(
                  text: l10n.endFast,
                  holdText: l10n.holdToComplete,
                  color: vm.stateColor,
                  onCompleted: () => _endFast(context, state),
                )
              else
                _PrimaryHeroButton(
                  icon: Icons.play_arrow_rounded,
                  text: l10n.startFast,
                  color: vm.stateColor,
                  onTap: () => _startFastNow(context, state),
                ),

              SizedBox(height: sectionGap),
              if (vm.isFasting)
                _BottomActionsBar(
                  children: [
                    Expanded(
                      child: _SoftGlassButton(
                        icon: Icons.edit_note_rounded,
                        text: l10n.timerLogMoodSymptoms,
                        onTap: () => showLogMoodSheet(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SoftGlassButton(
                        icon: Icons.history_rounded,
                        text: l10n.timerLogEndEarlier,
                        onTap: () => _logEndEarlier(context, state),
                      ),
                    ),
                  ],
                )
              else
                _BottomActionsBar(
                  children: [
                    Expanded(
                      child: _SoftGlassButton(
                        icon: Icons.coffee_rounded,
                        text: l10n.timerTakeBreak,
                        onTap: () => _takeBreak(context, state),
                      ),
                    ),
                    if (!(state.phase == FastingPhase.stopped &&
                        vm.isCircadian)) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SoftGlassButton(
                          icon: Icons.history_rounded,
                          text: l10n.timerLogStartEarlier,
                          onTap: () => _logStartEarlier(context),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FastingCardViewModel {
  final bool isFasting;
  final bool isCircadian;
  final bool showHeaderBadge;
  final String stateText;
  final String badgeText;
  final String planName;
  final String heroLabel;
  final IconData stageIcon;
  final Color stateColor;

  const _FastingCardViewModel({
    required this.isFasting,
    required this.isCircadian,
    required this.showHeaderBadge,
    required this.stateText,
    required this.badgeText,
    required this.planName,
    required this.heroLabel,
    required this.stageIcon,
    required this.stateColor,
  });

  factory _FastingCardViewModel.fromState(
      FastingState state,
      AppLocalizations l10n,
      ) {
    final isFasting = state.phase == FastingPhase.fasting;
    final isCircadian = state.planIndex == FastingState.circadianPlanIndex;

    final currentStage = isFasting
        ? FastingStage.getCurrentStage(state.elapsed.inMinutes / 60.0)
        : FastingStage.allStages[0];

    final stateColor = state.phase == FastingPhase.eating
        ? AppTheme.heroPrimary
        : state.phase == FastingPhase.stopped
        ? AppTheme.heroSecondary
        : isCircadian
        ? AppTheme.heroSecondary
        : currentStage.color;

    final stageIcon = state.phase == FastingPhase.eating
        ? Icons.restaurant
        : isCircadian
        ? Icons.nights_stay_rounded
        : currentStage.icon;

    final stateText = isFasting
        ? l10n.fastingPhase
        : state.phase == FastingPhase.eating
        ? l10n.eatingWindow
        : l10n.readyToFast;

    final isOvertime =
        state.phase != FastingPhase.stopped &&
            state.elapsed >= state.goalDuration;

    String planName;
    if (state.planIndex == FastingState.circadianPlanIndex) {
      planName = "☀️ ${l10n.planCircadianTitle}";
    } else if (state.planIndex == FastingState.customPlanIndex) {
      planName =
      "${l10n.customPlan} (${l10n.durationHoursShort(state.goalDuration.inHours)})";
    } else if (state.planIndex >= 0 &&
        state.planIndex < FastingPlan.defaultPlans.length) {
      final plan = FastingPlan.defaultPlans[state.planIndex];
      planName =
      "${plan.fastingDuration.inHours}:${plan.eatingDuration.inHours}";
    } else {
      planName = l10n.timerUnknownPlan;
    }

    final heroLabel = state.phase == FastingPhase.fasting
        ? l10n.heroActiveSession
        : state.phase == FastingPhase.eating
        ? l10n.heroEatingWindow
        : l10n.heroNextFast;

    return _FastingCardViewModel(
      isFasting: isFasting,
      isCircadian: isCircadian,
      showHeaderBadge: isFasting && !isOvertime,
      stateText: stateText,
      badgeText: isCircadian
          ? l10n.circadianManaged
          : currentStage.getTitle(l10n),
      planName: planName,
      heroLabel: heroLabel,
      stageIcon: stageIcon,
      stateColor: stateColor,
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String title;
  final Widget? badge;
  final Widget action;

  const _HeaderSection({
    required this.title,
    required this.action,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 8),
                badge!,
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        action,
      ],
    );
  }
}

class _StageBadge extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final bool tappable;
  final VoidCallback? onTap;

  const _StageBadge({
    required this.title,
    required this.color,
    required this.icon,
    this.tappable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tappable ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (tappable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.70),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: 0.90),
        ),
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final String planName;
  final bool isCircadian;
  final VoidCallback onTap;

  const _PlanSelector({
    required this.planName,
    required this.isCircadian,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                planName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCircadian ? AppTheme.premiumGold : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_calendar_rounded,
              size: 14,
              color: isCircadian ? AppTheme.premiumGold : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTimerSection extends StatelessWidget {
  final FastingPhase phase;
  final bool isCircadian;
  final Color stateColor;
  final Duration goalDuration;
  final String stateLabel;

  const _HeroTimerSection({
    required this.phase,
    required this.isCircadian,
    required this.stateColor,
    required this.goalDuration,
    required this.stateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: stateColor.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              stateLabel,
              style: TextStyle(
                color: stateColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            width: 220,
            child: _TimerDisplay(
              phase: phase,
              isCircadian: isCircadian,
              stateColor: stateColor,
              goalDuration: goalDuration,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryHeroButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryHeroButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.95),
              color.withValues(alpha: 0.78),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  final List<Widget> children;

  const _BottomActionsBar({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: children);
  }
}

class _SoftGlassButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SoftGlassButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoldToCompleteButton extends StatefulWidget {
  final VoidCallback onCompleted;
  final String text;
  final String holdText;
  final Color color;

  const HoldToCompleteButton({
    super.key,
    required this.onCompleted,
    required this.text,
    required this.holdText,
    required this.color,
  });

  @override
  State<HoldToCompleteButton> createState() => _HoldToCompleteButtonState();
}

class _HoldToCompleteButtonState extends State<HoldToCompleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _hapticTimer;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller.addListener(() {
      setState(() {});
      if (_controller.value == 1.0 && !_isCompleted) {
        _isCompleted = true;
        _hapticTimer?.cancel();
        getIt<HapticService>().success();
        widget.onCompleted();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _controller.reverse();
            _isCompleted = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    if (_isCompleted) return;
    getIt<HapticService>().heavyImpact();
    _controller.forward();

    _hapticTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      getIt<HapticService>().selectionClick();
    });
  }

  void _cancelHold() {
    if (_isCompleted) return;
    _controller.reverse();
    _hapticTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isHolding = _controller.value > 0;

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedScale(
        scale: isHolding && !_isCompleted ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _controller.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHolding ? Icons.lock_open_rounded : Icons.flag_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isHolding ? widget.holdText : widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

    return BlocSelector<FastingBloc, FastingState, Duration>(
      selector: (state) => state.elapsed,
      builder: (context, elapsed) {
        final l10n = AppLocalizations.of(context)!;

        Duration displayTime;
        String timeSubtext;
        Color subtextColor = Colors.white70;
        Color timeColor = Colors.white;
        bool isOvertime = false;

        if (phase == FastingPhase.stopped) {
          displayTime = goalDuration;
          timeSubtext = l10n.targetGoal;
        } else if (elapsed >= goalDuration) {
          isOvertime = true;
          displayTime = elapsed;

          if (isFasting) {
            timeSubtext = l10n.timerGoalReachedExtra;
            subtextColor = AppTheme.premiumGold;
            timeColor = AppTheme.premiumGold;
          } else {
            timeSubtext = l10n.timerWindowExtended;
            subtextColor = Colors.white60;
            timeColor = Colors.white;
          }
        } else {
          displayTime = goalDuration - elapsed;
          timeSubtext = isCircadian
              ? (phase == FastingPhase.eating
              ? l10n.circadianTargetSunset
              : l10n.circadianTargetSunrise)
              : (phase == FastingPhase.eating
              ? l10n.timerRemainingInWindow
              : l10n.remaining);
        }

        final timeString =
            "${displayTime.inHours.toString().padLeft(2, '0')}:"
            "${(displayTime.inMinutes % 60).toString().padLeft(2, '0')}:"
            "${(displayTime.inSeconds % 60).toString().padLeft(2, '0')}";

        final blobPercent = phase == FastingPhase.stopped
            ? 0.0
            : (elapsed.inSeconds / goalDuration.inSeconds).clamp(0.0, 1.0);

        return GradientTimerBlob(
          percent: blobPercent,
          isFasting: isFasting,
          colors: [
            stateColor.withValues(alpha: 0.45),
            stateColor,
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isFasting
                        ? l10n.fastingPhase
                        : phase == FastingPhase.eating
                        ? l10n.eatingWindow
                        : l10n.readyToFast,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: timeColor,
                      letterSpacing: -2.0,
                      height: 0.95,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    timeSubtext,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 14,
                      fontWeight:
                      isOvertime ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}