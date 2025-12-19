import 'dart:async';
import 'dart:ui'; // Для FontFeature
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- НАШИ ВИДЖЕТЫ ---
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/widgets/gradient_timer_blob.dart';
// ---------------------

import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/models/fasting_record.dart';

// --- РЕПОЗИТОРИИ ---
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/repositories/weight_repository.dart'; // Убедитесь, что создали этот файл
// -------------------

import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/sound_service.dart';

import 'package:fastable/screens/history_screen.dart';
import 'package:fastable/screens/stats_screen.dart';
import 'package:fastable/screens/learn_screen.dart';
import 'package:fastable/screens/profile_screen.dart';
import 'package:fastable/screens/pro_screen.dart';

const String kWaterGoalKey = 'water_goal';
const String kGoalWeightKey = 'user_goal_weight';
const String kCurrentWeightKey = 'user_current_weight';

enum AppState { stopped, fasting, eating }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- ТАЙМЕР ---
  Timer? _timer;
  AppState _appState = AppState.stopped;
  Duration _currentPlanFastDuration = const Duration(hours: 16);
  Duration _currentPlanEatDuration = const Duration(hours: 8);
  Duration _elapsedTime = Duration.zero;
  DateTime? _startTime;
  int _currentPlanIndex = 0;

  // --- ДАННЫЕ ПОЛЬЗОВАТЕЛЯ ---
  int _waterCount = 0;
  int _waterGoal = 8;
  double _currentWeight = 70.0;
  int _streakDays = 1;

  int _selectedIndex = 1; // По умолчанию Таймер

  // --- СЕРВИСЫ И РЕПОЗИТОРИИ ---
  final HistoryRepository _historyRepository = HistoryRepository();
  final WaterRepository _waterRepository = WaterRepository();
  final WeightRepository _weightRepository = WeightRepository(); // НОВОЕ
  final NotificationService _notificationService = NotificationService();
  final SoundService _soundService = SoundService();

  InterstitialAd? _interstitialAd;

  final List<FastingPlan> _plans = [
    FastingPlan(fastingDuration: const Duration(hours: 16), eatingDuration: const Duration(hours: 8), translationKey: "fastingPlan16_8"),
    FastingPlan(fastingDuration: const Duration(hours: 18), eatingDuration: const Duration(hours: 6), translationKey: "fastingPlan18_6"),
    FastingPlan(fastingDuration: const Duration(hours: 20), eatingDuration: const Duration(hours: 4), translationKey: "fastingPlan20_4"),
    FastingPlan(fastingDuration: const Duration(hours: 24), eatingDuration: const Duration(hours: 24), translationKey: "fastingPlanEatStopEat"),
  ];

  static const String kStateKey = 'app_state';
  static const String kStartTimeKey = 'cycle_start_time';
  static const String kPlanIndexKey = 'fast_plan_index';

  @override
  void initState() {
    super.initState();
    _notificationService.requestPermissions();
    _loadStateData();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // --- REKLAMA ---
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }

  Widget _buildBannerAd() {
    final BannerAd bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  // --- ЗАГРУЗКА ДАННЫХ (LOGIC) ---
  Future<void> _loadStateData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Состояние таймера
    String stateString = prefs.getString(kStateKey) ?? AppState.stopped.name;
    _appState = AppState.values.firstWhere((e) => e.name == stateString);

    _currentPlanIndex = prefs.getInt(kPlanIndexKey) ?? 0;
    if (_currentPlanIndex < 0 || _currentPlanIndex >= _plans.length) _currentPlanIndex = 0;
    _updatePlanDurations();

    if (_appState != AppState.stopped) {
      String? startTimeString = prefs.getString(kStartTimeKey);
      if (startTimeString != null) {
        _startTime = DateTime.parse(startTimeString);
        _elapsedTime = DateTime.now().difference(_startTime!);
        Duration totalDuration = (_appState == AppState.fasting) ? _currentPlanFastDuration : _currentPlanEatDuration;
        if (_elapsedTime >= totalDuration) {
          _elapsedTime = totalDuration;
        } else {
          _runTimerTick();
        }
      }
    }

    // 2. Вода (Сброс каждый день)
    String? lastWaterDate = prefs.getString('last_water_date');
    String todayStr = DateTime.now().toIso8601String().substring(0, 10);

    if (lastWaterDate != todayStr) {
      _waterCount = 0; // Новый день
      prefs.setString('last_water_date', todayStr);
      _waterRepository.addOrUpdateWaterForDay(DateTime.now(), 0);
    } else {
      _waterCount = await _waterRepository.getWaterForDay(DateTime.now());
    }
    _waterGoal = prefs.getInt(kWaterGoalKey) ?? 8;

    // 3. Вес (Реальные данные)
    _currentWeight = await _weightRepository.getCurrentWeight() ?? 70.0;

    // 4. Серия (Упрощенная логика)
    int savedStreak = prefs.getInt('user_streak') ?? 1;
    _streakDays = savedStreak;

    setState(() {});
  }

  Future<void> _saveStateData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kStateKey, _appState.name);
    prefs.setInt(kPlanIndexKey, _currentPlanIndex);
    if (_appState != AppState.stopped && _startTime != null) {
      prefs.setString(kStartTimeKey, _startTime!.toIso8601String());
    } else {
      prefs.remove(kStartTimeKey);
    }
  }

  Future<void> _clearStateData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kStateKey);
    await prefs.remove(kStartTimeKey);
  }

  void _updatePlanDurations() {
    final selectedPlan = _plans[_currentPlanIndex];
    _currentPlanFastDuration = selectedPlan.fastingDuration;
    _currentPlanEatDuration = selectedPlan.eatingDuration;
  }

  void _runTimerTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_appState == AppState.stopped) {
        timer.cancel();
        return;
      }
      final Duration nextTick = _elapsedTime + const Duration(seconds: 1);
      Duration totalDuration = (_appState == AppState.fasting) ? _currentPlanFastDuration : _currentPlanEatDuration;

      if (nextTick >= totalDuration) {
        _timer?.cancel();
        setState(() => _elapsedTime = totalDuration);
        if (_appState == AppState.eating) _performReset();
      } else {
        setState(() => _elapsedTime = nextTick);
      }
    });
  }

  // --- ACTIONS ---
  void _startFasting() {
    HapticFeedback.mediumImpact();
    if (_interstitialAd != null) {
      _interstitialAd!.show().then((_) {
        _interstitialAd = null;
        _loadInterstitialAd();
      });
    }
    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    setState(() => _appState = AppState.fasting);
    _runTimerTick();
    _saveStateData();

    final DateTime completionTime = _startTime!.add(_currentPlanFastDuration);
    _notificationService.scheduleFastCompletion(completionTime, "Goal Reached!");
  }

  void _startEating() async {
    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    setState(() => _appState = AppState.eating);
    _runTimerTick();
    _saveStateData();
  }

  void _performReset() {
    _timer?.cancel();
    setState(() {
      _appState = AppState.stopped;
      _elapsedTime = Duration.zero;
      _startTime = null;
      _waterCount = 0;
    });
    _waterRepository.addOrUpdateWaterForDay(DateTime.now(), 0);
    _clearStateData();
    _saveStateData();
    _notificationService.cancelAllNotifications();
  }

  void _addWater() async {
    _soundService.playWaterSound();
    HapticFeedback.lightImpact();
    setState(() => _waterCount = (_waterCount + 1).clamp(0, 99));

    // Сохраняем в репозиторий и обновляем дату
    await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), _waterCount);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_water_date', DateTime.now().toIso8601String().substring(0, 10));
  }

  void _promptToManuallyEndFast() {
    HapticFeedback.mediumImpact();
    Duration finalDuration = _elapsedTime;
    if (finalDuration >= _currentPlanFastDuration) finalDuration = _currentPlanFastDuration;

    final FastingRecord record = FastingRecord(
      startTime: _startTime!,
      endTime: _startTime!.add(finalDuration),
      duration: finalDuration,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(AppLocalizations.of(context)!.fastComplete, style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.of(context)!.fastCompleteDesc(_formatDuration(finalDuration)), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.discard, style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await _historyRepository.addRecord(record);
              if (mounted) Navigator.pop(ctx);
              _startEating();
            },
          ),
        ],
      ),
    );
  }

  void _promptToStopEating() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(AppLocalizations.of(context)!.endCyclePrompt, style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.of(context)!.endCyclePromptDesc, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.endCycle, style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(ctx);
              _performReset();
            },
          ),
        ],
      ),
    );
  }

  // --- СТЕКЛЯННАЯ ЛИНЕЙКА (Ввод веса) ---
  void _showWeightPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        // Начинаем с текущего веса (если 0, то 70)
        double tempWeight = _currentWeight > 0 ? _currentWeight : 70.0;

        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),

              const SizedBox(height: 30),
              Text(AppLocalizations.of(context)!.logWeight, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),

              const Spacer(),

              StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        Text(
                          "${tempWeight.toStringAsFixed(1)} ${AppLocalizations.of(context)!.unitKg}",
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),

                        // ЛИНЕЙКА
                        SizedBox(
                          height: 100,
                          child: PageView.builder(
                            // Центрируем на значении
                            controller: PageController(
                                viewportFraction: 0.2,
                                initialPage: (tempWeight * 10).toInt() - 300
                            ),
                            onPageChanged: (index) {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                tempWeight = (index + 300) / 10.0;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Center(
                                child: Container(
                                  width: 2,
                                  height: index % 10 == 0 ? 40 : 20,
                                  color: Colors.white.withOpacity(index % 10 == 0 ? 0.8 : 0.3),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _currentWeight = tempWeight);

                    // Сохраняем в историю и обновляем текущий
                    await _weightRepository.addWeight(tempWeight);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Weight saved"), backgroundColor: Colors.green, duration: Duration(milliseconds: 800)),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text(AppLocalizations.of(context)!.saveWeight, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  // --- UI WIDGETS ---

  Widget _buildTimerGlassCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFasting = _appState == AppState.fasting;

    final Color stateColor = isFasting
        ? const Color(0xFFFF9A9E)
        : (_appState == AppState.eating ? const Color(0xFF84FAB0) : Colors.blueAccent);

    String stateText;
    if (isFasting) stateText = l10n.fastingPhase;
    else if (_appState == AppState.eating) stateText = l10n.eatingWindow;
    else stateText = l10n.readyToFast;

    Duration totalDuration = isFasting ? _currentPlanFastDuration : _currentPlanEatDuration;
    if (_appState == AppState.stopped) totalDuration = const Duration(hours: 16);

    final double percent = (_appState == AppState.stopped)
        ? 0.0
        : (_elapsedTime.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);

    final timeLeft = (_appState == AppState.stopped) ? Duration.zero : totalDuration - _elapsedTime;
    final timeString = (_appState == AppState.stopped) ? "16:00:00" : _formatDuration(timeLeft);

    VoidCallback onAction;
    String btnLabel;
    if (_appState == AppState.stopped) {
      onAction = _startFasting;
      btnLabel = l10n.startFast;
    } else if (isFasting) {
      onAction = _promptToManuallyEndFast;
      btnLabel = l10n.endFast;
    } else {
      onAction = _promptToStopEating;
      btnLabel = l10n.endCycle;
    }

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stateText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  if (isFasting)
                    Text(l10n.autophagyZone, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: stateColor.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(isFasting ? Icons.local_fire_department : Icons.restaurant, color: stateColor, size: 20),
              )
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 240,
            width: 240,
            child: GradientTimerBlob(
              percent: percent,
              isFasting: isFasting,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFasting ? l10n.remaining : l10n.targetGoal,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Center(
                child: Text(
                  btnLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({required IconData icon, required Color color, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // TIMER
            _buildTimerGlassCard(context),

            const SizedBox(height: 16),

            // ИНФО-СТРОКА (Фаза, Серия, Статус)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    label: "Phase",
                    value: _appState == AppState.fasting ? "Fat Burn" : "Fed",
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                  _buildInfoColumn(
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFF9D423),
                    label: "Streak",
                    value: "$_streakDays Days",
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                  _buildInfoColumn(
                    icon: Icons.favorite_rounded,
                    color: Colors.redAccent,
                    label: "Health",
                    value: "Good",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // АСИММЕТРИЧНЫЙ БЕНТО (Вода и Вес)
            Row(
              children: [
                // ВОДА (Шире)
                Expanded(
                  flex: 5,
                  child: GlassCard(
                    onTap: _addWater,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 20),
                            ),
                            Text(
                                "${(_waterCount / (_waterGoal == 0 ? 1 : _waterGoal) * 100).toInt()}%",
                                style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.waterIntake, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("$_waterCount", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text("/ $_waterGoal", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ВЕС (Уже)
                Expanded(
                  flex: 4,
                  child: GlassCard(
                    onTap: _showWeightPicker, // Вызов линейки
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF00FA9A).withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.show_chart_rounded, color: Color(0xFF00FA9A), size: 20),
                            ),
                            Icon(Icons.arrow_right_alt_rounded, color: const Color(0xFF00FA9A).withOpacity(0.8), size: 16),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.currentWeight, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_currentWeight.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 2),
                              child: Text(l10n.unitKg, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // PRO BANNER
            GlassCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.star, color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.proBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(l10n.proBannerDesc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, int index, String label) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              size: 26,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4, height: 4,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ВАЖНО: Прозрачный Scaffold
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: MeshBackground(
        isFasting: _appState == AppState.fasting,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HistoryScreen(historyRepository: _historyRepository, waterRepository: _waterRepository),
            _buildDashboard(context),
            StatsScreen(repository: _historyRepository),
            const LearnScreen(),
          ],
        ),
      ),

      // FLOATING GLASS DOCK
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        color: Colors.transparent,
        child: GlassCard(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(Icons.calendar_month_rounded, 0, l10n.navHistory),
              _buildDockItem(Icons.timer_rounded, 1, l10n.navTimer),
              _buildDockItem(Icons.bar_chart_rounded, 2, l10n.navStats),
              _buildDockItem(Icons.school_rounded, 3, l10n.navLearn),
            ],
          ),
        ),
      ),
    );
  }
}