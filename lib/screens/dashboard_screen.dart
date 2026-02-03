import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

// --- ИМПОРТЫ ---
import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/services/sound_service.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';

import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';

import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/gradient_timer_blob.dart';
import 'package:fastable/widgets/body_visualizer.dart';

import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/models/fasting_record.dart'; // Важно для FastingMood

import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/plan_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final HapticService _hapticService;
  final SoundService _soundService = SoundService();
  InterstitialAd? _interstitialAd;
  bool _isBodyView = false;

  @override
  void initState() {
    super.initState();
    _hapticService = getIt<HapticService>();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _soundService.dispose();
    _interstitialAd?.dispose();
    super.dispose();
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

  Widget _buildBannerAd() {
    final BannerAd bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdFailedToLoad: (ad, err) => ad.dispose()),
    )..load();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  // --- ACTIONS ---

  void _onStartFastingPressed() {
    if (_interstitialAd != null) {
      try {
        _interstitialAd!.show();
        _interstitialAd = null;
      } catch (e) {
        debugPrint("Ad show error: $e");
      }
    } else {
      _loadInterstitialAd();
    }
    _showStartDialog(context);
  }

  void _onEndFastingPressed(FastingState state) {
    _hapticService.mediumImpact();
    if (state.startTime != null) {
      _showStopDialog(context, state.startTime!);
    } else {
      context.read<FastingBloc>().add(const EndFasting());
    }
  }

  void _onStopEatingPressed() {
    _hapticService.mediumImpact();
    _showStopEatingModal();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;

    return BlocBuilder<FastingBloc, FastingState>(builder: (context, fastingState) {
      return BlocBuilder<WeightBloc, WeightState>(builder: (context, weightState) {
        return BlocBuilder<WaterBloc, WaterState>(builder: (context, waterState) {
          return BlocBuilder<ProBloc, ProState>(builder: (context, proState) {
            final isPro = proState.isPro;
            final showAds = isAndroid || !isPro;
            final showProBanner = !isAndroid && !isPro;

            final bmiStr = weightState.bmi.toStringAsFixed(1);
            final bmiColor = _getBMIColor(weightState.bmi);

            return SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.dashboardToday, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                            Text(l10n.dashboardOverview, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // MAIN TIMER CARD
                    _buildTimerGlassCard(fastingState, weightState),

                    const SizedBox(height: 16),

                    // STATS ROW
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                              icon: Icons.local_fire_department_rounded,
                              color: Colors.orangeAccent,
                              label: l10n.metricPhase,
                              value: fastingState.phase == FastingPhase.fasting ? l10n.fastingPhase : l10n.eatingWindow,
                              onTap: () {}),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                          _buildInfoItem(icon: Icons.bolt_rounded, color: const Color(0xFFF9D423), label: l10n.metricStreak, value: l10n.valStreakDays(1), onTap: () {}),
                          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                          _buildInfoItem(icon: Icons.health_and_safety_rounded, color: bmiColor, label: l10n.bmiScore, value: bmiStr, onTap: () {}),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // WATER & WEIGHT
                    Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: GestureDetector(
                                onTap: () {
                                  _soundService.playWaterSound();
                                  _hapticService.lightImpact();
                                  context.read<WaterBloc>().add(AddWaterCup());
                                },
                                onLongPress: () => _showWaterMenu(waterState),
                                child: GlassCard(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                                            child: Text("/ ${waterState.dailyGoal}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))
                                      ])
                                    ])))),
                        const SizedBox(width: 12),
                        Expanded(
                            flex: 4,
                            child: GlassCard(
                                onTap: () => _showWeightPicker(weightState),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 4, left: 2),
                                        child: Text(l10n.unitKg, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))
                                  ])
                                ]))),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (showProBanner)
                      GlassCard(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
                        child: Row(children: [
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.star, color: Colors.amber)),
                          const SizedBox(width: 16),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l10n.proBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(l10n.proBannerDesc, style: const TextStyle(color: Colors.white54, fontSize: 13))
                          ]),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))
                        ]),
                      ),

                    const SizedBox(height: 20),

                    if (showAds) _buildBannerAd(),
                  ],
                ),
              ),
            );
          });
        });
      });
    });
  }

  Widget _buildTimerGlassCard(FastingState state, WeightState weightState) {
    final l10n = AppLocalizations.of(context)!;
    final isFasting = state.phase == FastingPhase.fasting;
    final Color stateColor = _getPhaseColor(state);

    String stateText;
    if (isFasting) {
      stateText = l10n.fastingPhase;
    } else if (state.phase == FastingPhase.eating) {
      stateText = l10n.eatingWindow;
    } else {
      stateText = l10n.readyToFast;
    }

    final timeLeft = (state.phase == FastingPhase.stopped) ? state.goalDuration : state.remaining;
    final timeString = _formatDuration(timeLeft);

    final stageInfo = _getCurrentStageDetail(l10n, state);
    final String detailText = isFasting ? stageInfo['title']! : "";
    final IconData stageIcon = _getPhaseIcon(state);

    VoidCallback onAction;
    String btnLabel;

    if (state.phase == FastingPhase.stopped) {
      onAction = _onStartFastingPressed;
      btnLabel = l10n.startFast;
    } else if (isFasting) {
      onAction = () => _onEndFastingPressed(state);
      btnLabel = l10n.endFast;
    } else {
      onAction = _onStopEatingPressed;
      btnLabel = l10n.endCycle;
    }

    final currentPlan = FastingPlan.defaultPlans[state.planIndex];
    final planName = "${currentPlan.fastingDuration.inHours}:${currentPlan.eatingDuration.inHours}";

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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
                          child: child,
                        ));
                      },
                      child: Text(
                        stateText,
                        key: ValueKey<String>(stateText),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),

                    if (isFasting && !_isBodyView)
                      GestureDetector(
                        onTap: () => _showBodyTimeline(state),
                        child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            // ИСПРАВЛЕНИЕ #1: Добавлен Flexible и overflow для текста в заголовке
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Flexible(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    detailText,
                                    key: ValueKey<String>(detailText),
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.4), size: 14)
                            ])),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _hapticService.selectionClick();
                      setState(() => _isBodyView = !_isBodyView);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: _isBodyView ? stateColor : Colors.white.withOpacity(0.2))),
                        child: Icon(_isBodyView ? Icons.timer_outlined : Icons.accessibility_new_rounded, color: Colors.white, size: 18)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      _hapticService.lightImpact();
                      final bool? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));
                      if (result == true) {
                        final prefs = await SharedPreferences.getInstance();
                        final newIdx = prefs.getInt('fast_plan_index') ?? 0;
                        if (mounted) context.read<FastingBloc>().add(ChangePlan(newIdx));
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Row(children: [
                          Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, color: Colors.white70, size: 12)
                        ])),
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
                ? Center(
                child: BodyVisualizer(
                    weight: weightState.currentWeight, height: weightState.heightCm, phaseColor: stateColor, isFasting: isFasting))
                : SizedBox(
              width: 240,
              height: 240,
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
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              timeString,
                              style: const TextStyle(
                                  fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isFasting)
                          GestureDetector(
                            onTap: () => _showBodyTimeline(state),
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: stateColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: stateColor.withOpacity(0.5))),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(stageIcon, color: stateColor, size: 14),
                                  const SizedBox(width: 6),
                                  // ИСПРАВЛЕНИЕ #2: Добавлен Flexible и overflow для текста внутри таймера
                                  Flexible(
                                    child: Text(
                                      detailText,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ])),
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
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
              child: Center(child: Text(btnLabel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODALS ---

  void _showStartDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime selectedTime = DateTime.now();
    final fastingBloc = context.read<FastingBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Container(
          height: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.dialogStartTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark, textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20))),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: selectedTime,
                    maximumDate: DateTime.now(),
                    minimumDate: DateTime.now().subtract(const Duration(days: 2)),
                    onDateTimeChanged: (val) => selectedTime = val,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: Colors.white),
                  onPressed: () {
                    fastingBloc.add(StartFasting(startTime: selectedTime));
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.btnStartFasting, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStopDialog(BuildContext context, DateTime startTime) {
    final l10n = AppLocalizations.of(context)!;
    DateTime selectedTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Container(
          height: 340,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("When did you end?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark, textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20))),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: selectedTime,
                    maximumDate: DateTime.now(),
                    minimumDate: startTime,
                    onDateTimeChanged: (val) => selectedTime = val,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final duration = selectedTime.difference(startTime);
                    _showEndFastSummary(selectedTime, duration);
                  },
                  child: Text(l10n.endFast, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndFastSummary(DateTime endTime, Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    final String timeString = _formatDuration(duration);
    final fastingBloc = context.read<FastingBloc>();

    int selectedMoodIndex = 2;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.greenAccent, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.fastComplete, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(timeString, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()], letterSpacing: 2)),
                    Text("TOTAL DURATION", style: TextStyle(color: Colors.greenAccent.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 30),

                    const Text("How do you feel?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final isSelected = selectedMoodIndex == index;
                        final moods = ["😫", "😐", "🙂", "😁", "🔥"];
                        return GestureDetector(
                          onTap: () {
                            _hapticService.selectionClick();
                            setModalState(() => selectedMoodIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.white54) : null,
                            ),
                            child: Text(moods[index], style: const TextStyle(fontSize: 28)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () {
                        final moodValues = [
                          FastingMood.terrible,
                          FastingMood.bad,
                          FastingMood.neutral,
                          FastingMood.good,
                          FastingMood.great
                        ];
                        final selectedMood = moodValues[selectedMoodIndex];

                        fastingBloc.add(EndFasting(endTime: endTime, mood: selectedMood));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fasting saved! 🏆"), backgroundColor: Colors.green));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF43C6AC), Color(0xFF191654)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF43C6AC).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
                        ),
                        child: Center(child: Text(l10n.save, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _hapticService.mediumImpact();
                        Navigator.pop(ctx);
                      },
                      child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStopEatingModal() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) {
      return BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(decoration: BoxDecoration(color: const Color(0xFF1E1E1E).withOpacity(0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1))), padding: const EdgeInsets.fromLTRB(24, 16, 24, 40), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))), const SizedBox(height: 30), const Icon(Icons.flag_rounded, color: Colors.orangeAccent, size: 40), const SizedBox(height: 20), Text(l10n.endCyclePrompt, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 30), GestureDetector(onTap: () { context.read<FastingBloc>().add(EndEatingWindow()); Navigator.pop(ctx); }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF512F), Color(0xFFDD2476)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(l10n.endCycle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))))), const SizedBox(height: 16), TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)))])));
    });
  }

  void _showEndFastModal(Duration duration) {
    _showEndFastSummary(DateTime.now(), duration);
  }

  // --- HELPERS ---
  Widget _buildInfoItem({required IconData icon, required Color color, required String label, required String value, required VoidCallback onTap}) {
    return Expanded(child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 4), Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10))])));
  }

  void _showWaterMenu(WaterState state) {
    _hapticService.mediumImpact();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.98), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) {
      return Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l10n.waterSettings, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ListTile(leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), title: Text(l10n.removeCup, style: const TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); context.read<WaterBloc>().add(RemoveWaterCup()); }),
        const Divider(color: Colors.white12),
        const SizedBox(height: 10),
        Text(l10n.dailyGoal, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        SizedBox(height: 120, child: ListWheelScrollView.useDelegate(itemExtent: 40, perspective: 0.005, physics: const FixedExtentScrollPhysics(), controller: FixedExtentScrollController(initialItem: (state.dailyGoal - 1).clamp(0, 19)), onSelectedItemChanged: (index) { _hapticService.selectionClick(); context.read<WaterBloc>().add(UpdateWaterGoal(index + 1)); }, childDelegate: ListWheelChildBuilderDelegate(childCount: 20, builder: (context, index) { final val = index + 1; return Center(child: Text("$val ${l10n.cups}", style: TextStyle(color: val == state.dailyGoal ? Colors.blueAccent : Colors.white38, fontSize: 20, fontWeight: FontWeight.bold))); })))
      ]));
    });
  }

  void _showWeightPicker(WeightState state) {
    final l10n = AppLocalizations.of(context)!;
    _hapticService.mediumImpact();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (ctx) {
      double tempWeight = state.currentWeight > 0 ? state.currentWeight : 70.0;
      return Container(height: 650, decoration: BoxDecoration(color: const Color(0xFF1E1E1E).withOpacity(0.98), borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))), child: Column(children: [
        const SizedBox(height: 16), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20),
        Text(l10n.logWeight, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        StatefulBuilder(builder: (context, setModalState) { return Column(children: [SizedBox(height: 280, child: BodyVisualizer(weight: tempWeight, height: state.heightCm, phaseColor: Colors.blueAccent, isFasting: false)), const SizedBox(height: 20), Text("${tempWeight.toStringAsFixed(1)} ${l10n.unitKg}", style: const TextStyle(color: Colors.blueAccent, fontSize: 48, fontWeight: FontWeight.bold)), const SizedBox(height: 20), SizedBox(height: 80, child: PageView.builder(controller: PageController(viewportFraction: 0.2, initialPage: (tempWeight * 10).toInt() - 300), onPageChanged: (index) { _hapticService.selectionClick(); setModalState(() { tempWeight = (index + 300) / 10.0; }); }, itemBuilder: (context, index) { return Center(child: Container(width: 2, height: index % 10 == 0 ? 40 : 20, color: Colors.white.withOpacity(index % 10 == 0 ? 0.8 : 0.3))); }))]); }),
        const Spacer(),
        Padding(padding: const EdgeInsets.all(24.0), child: GestureDetector(onTap: () { context.read<WeightBloc>().add(AddWeightEntry(tempWeight)); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Weight saved"), backgroundColor: Colors.green)); }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)), child: Center(child: Text(l10n.saveWeight, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))))))
      ]));
    });
  }

  void _showBodyTimeline(FastingState state) {
    final l10n = AppLocalizations.of(context)!;
    final currentHours = state.elapsed.inHours;
    final isEating = state.phase == FastingPhase.eating;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) {
      return Container(height: MediaQuery.of(context).size.height * 0.75, decoration: BoxDecoration(color: const Color(0xFF1E1E1E).withOpacity(0.98), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))), child: Column(children: [const SizedBox(height: 16), Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))), const SizedBox(height: 24), Text(l10n.viewTimeline, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 20), Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), children: [_buildTimelineItem(l10n, 0, 4, l10n.stage0_4, l10n.stage0_4_desc, currentHours, isEating), _buildTimelineItem(l10n, 4, 8, l10n.stage4_8, l10n.stage4_8_desc, currentHours, isEating), _buildTimelineItem(l10n, 8, 12, l10n.stage8_12, l10n.stage8_12_desc, currentHours, isEating), _buildTimelineItem(l10n, 12, 16, l10n.stage12_16, l10n.stage12_16_desc, currentHours, isEating), _buildTimelineItem(l10n, 16, 18, l10n.stage16_18, l10n.stage16_18_desc, currentHours, isEating), _buildTimelineItem(l10n, 18, 24, l10n.stage18_24, l10n.stage18_24_desc, currentHours, isEating), _buildTimelineItem(l10n, 24, 100, l10n.stage24_plus, l10n.stage24_plus_desc, currentHours, isEating)])), Padding(padding: const EdgeInsets.all(24.0), child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () => Navigator.pop(context), child: Text(l10n.btnGotIt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))) ]));
    });
  }

  String _formatDuration(Duration d) => "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  Color _getPhaseColor(FastingState state) { if (state.phase == FastingPhase.eating) return const Color(0xFF84FAB0); if (state.phase == FastingPhase.stopped) return Colors.blueAccent; final h = state.elapsed.inHours; if (h < 12) return Colors.blueAccent; if (h < 16) return Colors.orangeAccent; if (h < 18) return Colors.purpleAccent; return const Color(0xFFFFD700); }
  IconData _getPhaseIcon(FastingState state) { if (state.phase == FastingPhase.eating) return Icons.restaurant; final h = state.elapsed.inHours; if (h < 12) return Icons.bloodtype; if (h < 16) return Icons.local_fire_department; if (h < 18) return Icons.bolt; return Icons.auto_awesome; }
  Map<String, String> _getCurrentStageDetail(AppLocalizations l10n, FastingState state) { final h = state.elapsed.inHours; if (state.phase == FastingPhase.eating) return {"title": l10n.eatingWindow, "desc": l10n.descEatingWindow}; if (h < 4) return {"title": l10n.stage0_4, "desc": l10n.stage0_4_desc}; if (h < 8) return {"title": l10n.stage4_8, "desc": l10n.stage4_8_desc}; if (h < 12) return {"title": l10n.stage8_12, "desc": l10n.stage8_12_desc}; if (h < 16) return {"title": l10n.stage12_16, "desc": l10n.stage12_16_desc}; if (h < 18) return {"title": l10n.stage16_18, "desc": l10n.stage16_18_desc}; if (h < 24) return {"title": l10n.stage18_24, "desc": l10n.stage18_24_desc}; return {"title": l10n.stage24_plus, "desc": l10n.stage24_plus_desc}; }
  Color _getBMIColor(double bmi) { if (bmi < 18.5) return Colors.blueAccent; if (bmi < 25) return Colors.greenAccent; if (bmi < 30) return Colors.orangeAccent; return Colors.redAccent; }
  Widget _buildTimelineItem(AppLocalizations l10n, int start, int end, String title, String desc, int currentHours, bool isEating) { bool isActive = currentHours >= start && (end == 100 ? true : currentHours < end); bool isPassed = currentHours >= end; if (isEating) { isActive = false; isPassed = false; } return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Column(children: [Container(width: 24, height: 24, decoration: BoxDecoration(color: isActive ? Colors.blueAccent : (isPassed ? Colors.green : Colors.grey.withOpacity(0.3)), shape: BoxShape.circle, border: isActive ? Border.all(color: Colors.white, width: 2) : null), child: isPassed ? const Icon(Icons.check, size: 14, color: Colors.black) : null), Expanded(child: Container(width: 2, color: isPassed ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.2)))]), const SizedBox(width: 16), Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(end == 100 ? "$start+ h" : "$start - $end h", style: TextStyle(color: isActive ? Colors.blueAccent : Colors.white54, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))])))])); }
}