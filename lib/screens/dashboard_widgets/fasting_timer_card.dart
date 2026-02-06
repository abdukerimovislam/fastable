import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/gradient_timer_blob.dart';
import 'package:fastable/widgets/body_visualizer.dart';
import 'package:fastable/widgets/end_fast_dialog.dart';
import 'package:fastable/utils/time_picker_sheet.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/screens/plan_selection_screen.dart';

class FastingTimerCard extends StatefulWidget {
  const FastingTimerCard({super.key});

  @override
  State<FastingTimerCard> createState() => _FastingTimerCardState();
}

class _FastingTimerCardState extends State<FastingTimerCard> {
  bool _isBodyView = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  // --- ACTIONS ---

  void _onStartFastingPressed(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }

    final DateTime? pickedTime = await showTimePickerSheet(
      context: context,
      title: l10n.dialogStartTitle,
      initialTime: DateTime.now(),
    );

    if (pickedTime != null && mounted) {
      context.read<FastingBloc>().add(StartFasting(startTime: pickedTime));
    }
  }

  void _onEndFastingPressed(BuildContext context, FastingState state) async {
    getIt<HapticService>().mediumImpact();

    final FastingMood? result = await showModalBottomSheet<FastingMood>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EndFastDialog(duration: state.elapsed),
    );

    if (result != null && mounted) {
      context.read<FastingBloc>().add(EndFasting(endTime: DateTime.now(), mood: result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fasting saved! 🏆"), backgroundColor: Colors.green),
      );
    }
  }

  void _onStopEatingPressed(BuildContext context) {
    getIt<HapticService>().mediumImpact();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag_rounded, color: Colors.orangeAccent, size: 40),
                const SizedBox(height: 20),
                Text(l10n.endCyclePrompt, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                GlassCard(
                  onTap: () {
                    context.read<FastingBloc>().add(EndEatingWindow());
                    Navigator.pop(ctx);
                  },
                  color: const Color(0xFFFF512F).withOpacity(0.8),
                  child: Center(child: Text(l10n.endCycle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final DateTime? pickedTime = await showTimePickerSheet(context: context, title: "When did you stop eating?", initialTime: DateTime.now());
                    if (pickedTime != null && mounted) {
                      context.read<FastingBloc>().add(EndEatingWindow(endTime: pickedTime));
                    }
                  },
                  color: Colors.white.withOpacity(0.1),
                  child: const Center(child: Text("Edit Time", style: TextStyle(color: Colors.white, fontSize: 16))),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FastingBloc, FastingState>(
      builder: (context, state) {
        final weight = context.select((WeightBloc b) => b.state.currentWeight);
        final height = context.select((WeightBloc b) => b.state.heightCm);

        final isFasting = state.phase == FastingPhase.fasting;
        final Color stateColor = _getPhaseColor(state);

        String stateText;
        if (isFasting) stateText = l10n.fastingPhase;
        else if (state.phase == FastingPhase.eating) stateText = l10n.eatingWindow;
        else stateText = l10n.readyToFast;

        final timeLeft = (state.phase == FastingPhase.stopped) ? state.goalDuration : state.remaining;
        final timeString = _formatDuration(timeLeft);

        final stageInfo = _getCurrentStageDetail(l10n, state);
        final String detailText = isFasting ? stageInfo['title']! : "";
        final IconData stageIcon = _getPhaseIcon(state);

        VoidCallback onAction;
        String btnLabel;

        if (state.phase == FastingPhase.stopped) {
          onAction = () => _onStartFastingPressed(context);
          btnLabel = l10n.startFast;
        } else if (isFasting) {
          onAction = () => _onEndFastingPressed(context, state);
          btnLabel = l10n.endFast;
        } else {
          onAction = () => _onStopEatingPressed(context);
          btnLabel = l10n.endCycle;
        }

        // 🔥 ЛОГИКА ОТОБРАЖЕНИЯ ПЛАНА (CUSTOM или PRESET)
        String planName;
        if (state.planIndex == FastingState.customPlanIndex) {
          planName = "Custom (${state.goalDuration.inHours}h)";
        } else {
          final currentPlan = FastingPlan.defaultPlans[state.planIndex];
          planName = "${currentPlan.fastingDuration.inHours}:${currentPlan.eatingDuration.inHours}";
        }

        return GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stateText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                        if (isFasting && !_isBodyView)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(children: [
                              Flexible(child: Text(detailText, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.4), size: 14)
                            ]),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          getIt<HapticService>().selectionClick();
                          setState(() => _isBodyView = !_isBodyView);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: _isBodyView ? stateColor : Colors.white.withOpacity(0.2))),
                          child: Icon(_isBodyView ? Icons.timer_outlined : Icons.accessibility_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // КНОПКА ВЫБОРА ПЛАНА
                      GestureDetector(
                        onTap: () async {
                          getIt<HapticService>().lightImpact();
                          final bool? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));

                          if (result == true && mounted) {
                            // Если выбрали пресет, обновляем через событие
                            final prefs = await SharedPreferences.getInstance();
                            final newIdx = prefs.getInt('fast_plan_index') ?? 0;

                            // Если это НЕ кастомный план, шлем событие смены
                            if (newIdx != FastingState.customPlanIndex) {
                              context.read<FastingBloc>().add(ChangePlan(newIdx));
                            }
                            // Если кастомный (-1), событие SetCustomPlan уже отправлено из CustomPlanScreen
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                          child: Row(children: [
                            Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, color: Colors.white70, size: 12)
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: _isBodyView
                    ? Center(child: BodyVisualizer(weight: weight, height: height, phaseColor: stateColor, isFasting: isFasting))
                    : SizedBox(
                  width: 240, height: 240,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: GradientTimerBlob(
                      key: ValueKey<bool>(isFasting),
                      percent: (state.phase == FastingPhase.stopped) ? 0.0 : state.progress,
                      isFasting: isFasting,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(timeString, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])))),
                            const SizedBox(height: 8),
                            if (isFasting)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: stateColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: stateColor.withOpacity(0.5))),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(stageIcon, color: stateColor, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(child: Text(detailText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis))
                                ]),
                              )
                            else
                              Text(l10n.targetGoal, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                onTap: onAction,
                color: stateColor.withOpacity(0.8),
                child: Center(child: Text(btnLabel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helpers (internal)
  String _formatDuration(Duration d) => "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  Color _getPhaseColor(FastingState state) { if (state.phase == FastingPhase.eating) return const Color(0xFF84FAB0); if (state.phase == FastingPhase.stopped) return Colors.blueAccent; final h = state.elapsed.inHours; if (h < 12) return Colors.blueAccent; if (h < 16) return Colors.orangeAccent; if (h < 18) return Colors.purpleAccent; return const Color(0xFFFFD700); }
  IconData _getPhaseIcon(FastingState state) { if (state.phase == FastingPhase.eating) return Icons.restaurant; final h = state.elapsed.inHours; if (h < 12) return Icons.bloodtype; if (h < 16) return Icons.local_fire_department; if (h < 18) return Icons.bolt; return Icons.auto_awesome; }
  Map<String, String> _getCurrentStageDetail(AppLocalizations l10n, FastingState state) { final h = state.elapsed.inHours; if (state.phase == FastingPhase.eating) return {"title": l10n.eatingWindow, "desc": l10n.descEatingWindow}; if (h < 4) return {"title": l10n.stage0_4, "desc": l10n.stage0_4_desc}; if (h < 8) return {"title": l10n.stage4_8, "desc": l10n.stage4_8_desc}; if (h < 12) return {"title": l10n.stage8_12, "desc": l10n.stage8_12_desc}; if (h < 16) return {"title": l10n.stage12_16, "desc": l10n.stage12_16_desc}; if (h < 18) return {"title": l10n.stage16_18, "desc": l10n.stage16_18_desc}; if (h < 24) return {"title": l10n.stage18_24, "desc": l10n.stage18_24_desc}; return {"title": l10n.stage24_plus, "desc": l10n.stage24_plus_desc}; }
}