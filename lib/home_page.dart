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
import 'package:fastable/widgets/body_visualizer.dart';
import 'package:fastable/widgets/circadian_card.dart';
// ---------------------

import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/models/fasting_record.dart';

// --- РЕПОЗИТОРИИ ---
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/repositories/weight_repository.dart';
// -------------------

import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/sound_service.dart';

// --- ЭКРАНЫ ---
import 'package:fastable/screens/history_screen.dart';
import 'package:fastable/screens/stats_screen.dart';
import 'package:fastable/screens/learn_screen.dart';
import 'package:fastable/screens/profile_screen.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/plan_selection_screen.dart';

const String kWaterGoalKey = 'water_goal';
const String kGoalWeightKey = 'user_goal_weight';
const String kCurrentWeightKey = 'user_current_weight';

enum AppState { stopped, fasting, eating }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
  double _userHeight = 175.0;
  int _streakDays = 1;

  // --- НАСТРОЙКИ UI ---
  // Начинаем с Таймера (Центральная иконка, индекс 2)
  int _selectedIndex = 2;
  bool _isCircadianMode = false;
  bool _isBodyView = false;

  // --- СЕРВИСЫ И РЕПОЗИТОРИИ ---
  final HistoryRepository _historyRepository = HistoryRepository();
  final WaterRepository _waterRepository = WaterRepository();
  final WeightRepository _weightRepository = WeightRepository();
  final NotificationService _notificationService = NotificationService();
  final SoundService _soundService = SoundService();

  // Кэшированные страницы для предотвращения мигания
  late final List<Widget> _pages;

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
    WidgetsBinding.instance.addObserver(this);

    // Инициализируем страницы один раз.
    // Dashboard (Таймер) не добавляем сюда, он строится динамически.
    _pages = [
      HistoryScreen(historyRepository: _historyRepository, waterRepository: _waterRepository), // 0
      StatsScreen(repository: _historyRepository), // 1
      const SizedBox(), // 2 (Placeholder для Таймера)
      const LearnScreen(), // 3
      const ProfileScreen(), // 4
    ];

    _notificationService.requestPermissions();
    _loadStateData();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _soundService.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStateData();
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
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

  Future<void> _loadStateData() async {
    final prefs = await SharedPreferences.getInstance();

    String stateString = prefs.getString(kStateKey) ?? AppState.stopped.name;
    try {
      _appState = AppState.values.firstWhere((e) => e.name == stateString);
    } catch(e) {
      _appState = AppState.stopped;
    }

    _currentPlanIndex = prefs.getInt(kPlanIndexKey) ?? 0;
    if (_currentPlanIndex < 0 || _currentPlanIndex >= _plans.length) _currentPlanIndex = 0;
    _updatePlanDurations();

    _isCircadianMode = prefs.getBool('circadian_mode') ?? false;
    _userHeight = (prefs.getInt('user_height') ?? 175).toDouble();

    if (_appState != AppState.stopped) {
      String? startTimeString = prefs.getString(kStartTimeKey);
      if (startTimeString != null) {
        _startTime = DateTime.parse(startTimeString);

        final now = DateTime.now();
        _elapsedTime = now.difference(_startTime!);

        Duration totalDuration = (_appState == AppState.fasting) ? _currentPlanFastDuration : _currentPlanEatDuration;

        if (_elapsedTime >= totalDuration) {
          _elapsedTime = totalDuration;
        }

        _runTimerTick();
      }
    }

    String? lastWaterDate = prefs.getString('last_water_date');
    String todayStr = DateTime.now().toIso8601String().substring(0, 10);

    if (lastWaterDate != todayStr) {
      _waterCount = 0;
      prefs.setString('last_water_date', todayStr);
      _waterRepository.addOrUpdateWaterForDay(DateTime.now(), 0);
    } else {
      _waterCount = await _waterRepository.getWaterForDay(DateTime.now());
    }
    _waterGoal = prefs.getInt(kWaterGoalKey) ?? 8;

    _currentWeight = await _weightRepository.getCurrentWeight() ?? 70.0;
    int savedStreak = prefs.getInt('user_streak') ?? 1;
    _streakDays = savedStreak;

    if (mounted) setState(() {});
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

      if (_startTime != null) {
        final now = DateTime.now();
        final diff = now.difference(_startTime!);
        Duration totalDuration = (_appState == AppState.fasting) ? _currentPlanFastDuration : _currentPlanEatDuration;

        if (diff >= totalDuration) {
          _timer?.cancel();
          setState(() => _elapsedTime = totalDuration);
          if (_appState == AppState.eating) _performReset();
        } else {
          setState(() => _elapsedTime = diff);
        }
      }
    });
  }

  void _toggleCircadianMode() async {
    HapticFeedback.mediumImpact();
    setState(() => _isCircadianMode = !_isCircadianMode);

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('circadian_mode', _isCircadianMode);
  }

  void _startFasting() {
    HapticFeedback.mediumImpact();

    if (_interstitialAd != null) {
      try {
        _interstitialAd!.show();
        _interstitialAd = null;
      } catch (e) {
        // ignore
      }
    } else {
      _loadInterstitialAd();
    }

    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    setState(() => _appState = AppState.fasting);
    _runTimerTick();
    _saveStateData();

    final DateTime completionTime = _startTime!.add(_currentPlanFastDuration);
    _notificationService.scheduleFastCompletion(completionTime, "Goal Reached!");
    _notificationService.scheduleWaterReminder();
  }

  void _startEating() async {
    _startTime = DateTime.now();
    _elapsedTime = Duration.zero;
    setState(() => _appState = AppState.eating);
    _runTimerTick();
    _saveStateData();

    final DateTime endTime = _startTime!.add(_currentPlanEatDuration);
    _notificationService.scheduleEatingCompletion(endTime);
    _notificationService.scheduleFastingStartReminder(endTime);
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

  // --- ВОДА (Добавление, Удаление, Настройка) ---

  void _addWater() async {
    _soundService.playWaterSound();
    HapticFeedback.lightImpact();
    setState(() => _waterCount = (_waterCount + 1).clamp(0, 99));

    await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), _waterCount);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_water_date', DateTime.now().toIso8601String().substring(0, 10));
  }

  void _removeWater() async {
    if (_waterCount > 0) {
      HapticFeedback.mediumImpact();
      setState(() => _waterCount = _waterCount - 1);
      await _waterRepository.addOrUpdateWaterForDay(DateTime.now(), _waterCount);
    }
  }

  void _setWaterGoal(int newGoal) async {
    setState(() => _waterGoal = newGoal);
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(kWaterGoalKey, newGoal);
  }

  // Меню воды (вызывается долгим нажатием)
  void _showWaterMenu() {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.98),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.waterSettings, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Кнопка: Убрать стакан
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                title: Text(l10n.removeCup, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeWater();
                },
              ),
              const Divider(color: Colors.white12),

              const SizedBox(height: 10),
              // Скролл: Выбор цели
              Text(l10n.dailyGoal, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: (_waterGoal - 1).clamp(0, 19)),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    _setWaterGoal(index + 1);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 20,
                    builder: (context, index) {
                      final val = index + 1;
                      return Center(
                        child: Text(
                          "$val ${l10n.cups}",
                          style: TextStyle(
                              color: val == _waterGoal ? Colors.blueAccent : Colors.white38,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(l10n.fastComplete, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.fastCompleteDesc(_formatDuration(finalDuration)), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(l10n.discard, style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(l10n.save, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(l10n.endCyclePrompt, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.endCyclePromptDesc, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(l10n.endCycle, style: const TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(ctx);
              _performReset();
            },
          ),
        ],
      ),
    );
  }

  void _showWeightPicker() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        double tempWeight = _currentWeight > 0 ? _currentWeight : 70.0;

        return Container(
          height: 650,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              Text(l10n.logWeight, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),

              const Spacer(),

              StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 280,
                          child: BodyVisualizer(
                            weight: tempWeight,
                            height: _userHeight,
                            phaseColor: Colors.blueAccent,
                            isFasting: false,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          "${tempWeight.toStringAsFixed(1)} ${l10n.unitKg}",
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 48, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          height: 80,
                          child: PageView.builder(
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
                    await _weightRepository.addWeightOrUpdateToday(tempWeight);

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
                    child: Center(child: Text(l10n.saveWeight, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
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

  Color _getPhaseColor() {
    if (_appState == AppState.eating) return const Color(0xFF84FAB0);
    if (_appState == AppState.stopped) return Colors.blueAccent;

    final hours = _elapsedTime.inHours;
    if (hours < 12) return Colors.blueAccent;
    if (hours < 16) return Colors.orangeAccent;
    if (hours < 18) return Colors.purpleAccent;
    return const Color(0xFFFFD700);
  }

  IconData _getPhaseIcon() {
    if (_appState == AppState.eating) return Icons.restaurant;
    final hours = _elapsedTime.inHours;
    if (hours < 12) return Icons.bloodtype;
    if (hours < 16) return Icons.local_fire_department;
    if (hours < 18) return Icons.bolt;
    return Icons.auto_awesome;
  }

  String _getHealthStatus(AppLocalizations l10n) {
    if (_appState == AppState.eating) return l10n.statusDigesting;
    if (_elapsedTime.inHours < 12) return l10n.statusStable;
    if (_elapsedTime.inHours >= 12 && _elapsedTime.inHours < 16) return l10n.statusFatBurn;
    if (_elapsedTime.inHours >= 16) return l10n.statusKetosis;
    return l10n.statusNormal;
  }

  String _getHealthDescription(AppLocalizations l10n) {
    if (_appState == AppState.eating) return l10n.descDigesting;
    if (_elapsedTime.inHours < 12) return l10n.descStable;
    if (_elapsedTime.inHours >= 12 && _elapsedTime.inHours < 16) return l10n.descFatBurn;
    return l10n.descKetosis;
  }

  Map<String, String> _getCurrentStageDetail(AppLocalizations l10n, int hours) {
    if (_appState == AppState.eating) {
      return {"title": l10n.eatingWindow, "desc": l10n.descEatingWindow};
    }
    if (hours < 4) return {"title": l10n.stage0_4, "desc": l10n.stage0_4_desc};
    if (hours < 8) return {"title": l10n.stage4_8, "desc": l10n.stage4_8_desc};
    if (hours < 12) return {"title": l10n.stage8_12, "desc": l10n.stage8_12_desc};
    if (hours < 16) return {"title": l10n.stage12_16, "desc": l10n.stage12_16_desc};
    if (hours < 18) return {"title": l10n.stage16_18, "desc": l10n.stage16_18_desc};
    if (hours < 24) return {"title": l10n.stage18_24, "desc": l10n.stage18_24_desc};
    return {"title": l10n.stage24_plus, "desc": l10n.stage24_plus_desc};
  }

  // --- BMI CALCULATOR ---
  double _calculateBMI() {
    if (_userHeight <= 0) return 0;
    double heightM = _userHeight / 100.0;
    return _currentWeight / (heightM * heightM);
  }

  String _getBMICategory(double bmi, AppLocalizations l10n) {
    if (bmi < 18.5) return l10n.bmiUnderweight;
    if (bmi < 25) return l10n.bmiNormal;
    if (bmi < 30) return l10n.bmiOverweight;
    return l10n.bmiObese;
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return Colors.greenAccent;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _showBodyTimeline() {
    final l10n = AppLocalizations.of(context)!;
    final currentHours = _elapsedTime.inHours;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(l10n.viewTimeline, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  children: [
                    _buildTimelineItem(l10n, 0, 4, l10n.stage0_4, l10n.stage0_4_desc, currentHours),
                    _buildTimelineItem(l10n, 4, 8, l10n.stage4_8, l10n.stage4_8_desc, currentHours),
                    _buildTimelineItem(l10n, 8, 12, l10n.stage8_12, l10n.stage8_12_desc, currentHours),
                    _buildTimelineItem(l10n, 12, 16, l10n.stage12_16, l10n.stage12_16_desc, currentHours),
                    _buildTimelineItem(l10n, 16, 18, l10n.stage16_18, l10n.stage16_18_desc, currentHours),
                    _buildTimelineItem(l10n, 18, 24, l10n.stage18_24, l10n.stage18_24_desc, currentHours),
                    _buildTimelineItem(l10n, 24, 100, l10n.stage24_plus, l10n.stage24_plus_desc, currentHours),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.btnGotIt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(AppLocalizations l10n, int start, int end, String title, String desc, int currentHours) {
    bool isActive = currentHours >= start && (end == 100 ? true : currentHours < end);
    bool isPassed = currentHours >= end;

    if (_appState == AppState.eating) {
      isActive = false; isPassed = false;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isActive ? Colors.blueAccent : (isPassed ? Colors.green : Colors.grey.withOpacity(0.3)),
                  shape: BoxShape.circle,
                  border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: isPassed ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isPassed ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    end == 100 ? "$start+ h" : "$start - $end h",
                    style: TextStyle(color: isActive ? Colors.blueAccent : Colors.white54, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showMetricInfo({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    HapticFeedback.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(description, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.btnGotIt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required Color color, required String label, required String value, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerGlassCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFasting = _appState == AppState.fasting;
    final Color stateColor = _getPhaseColor();

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

    final stageInfo = _getCurrentStageDetail(l10n, _elapsedTime.inHours);
    final String detailText = isFasting ? stageInfo['title']! : "";
    final IconData stageIcon = _getPhaseIcon();

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

    final currentPlan = _plans[_currentPlanIndex];
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
                    Text(stateText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    if (isFasting && !_isBodyView)
                      GestureDetector(
                        onTap: _showBodyTimeline,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(detailText, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              const SizedBox(width: 4),
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.4), size: 14)
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isBodyView = !_isBodyView);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: _isBodyView ? stateColor : Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(_isBodyView ? Icons.timer_outlined : Icons.accessibility_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final bool? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanSelectionScreen()));
                      if (result == true) {
                        _loadStateData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Row(children: [Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(width: 4), const Icon(Icons.edit, color: Colors.white70, size: 12)]),
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
                ? Center(child: BodyVisualizer(weight: _currentWeight, height: _userHeight, phaseColor: stateColor, isFasting: isFasting))
                : SizedBox(
              width: 240, height: 240,
              child: GradientTimerBlob(
                percent: percent, isFasting: isFasting,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeString, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
                    const SizedBox(height: 8),
                    if (isFasting)
                      GestureDetector(
                        onTap: _showBodyTimeline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: stateColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: stateColor.withOpacity(0.5))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(stageIcon, color: stateColor, size: 14), const SizedBox(width: 6), Text(detailText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
                        ),
                      )
                    else
                      Text(l10n.targetGoal, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: stateColor.withOpacity(0.8), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: stateColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
              child: Center(child: Text(btnLabel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // РАСЧЕТ BMI
    final double bmi = _calculateBMI();
    final String bmiStr = bmi.toStringAsFixed(1);
    final String bmiCat = _getBMICategory(bmi, l10n);
    final Color bmiColor = _getBMIColor(bmi);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ВЕРХНЯЯ ПАНЕЛЬ
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
                // КНОПКА ЦИРКАДНОГО РИТМА
                GestureDetector(
                  onTap: _toggleCircadianMode,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _isCircadianMode ? Colors.orange.withOpacity(0.2) : Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: _isCircadianMode ? Colors.orange : Colors.transparent, width: 1)),
                    child: Icon(_isCircadianMode ? Icons.wb_sunny : Icons.wb_sunny_outlined, color: _isCircadianMode ? Colors.orange : Colors.white54, size: 22),
                  ),
                ),
              ],
            ),

            // КАРТОЧКА ЦИРКАДНОГО РИТМА
            if (_isCircadianMode)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CircadianCard(
                  onClose: _toggleCircadianMode,
                ),
              ),

            const SizedBox(height: 24),

            // ТАЙМЕР
            _buildTimerGlassCard(context),

            const SizedBox(height: 16),

            // ИНФО-ПАНЕЛЬ (Phase, Streak, BMI)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(icon: Icons.local_fire_department_rounded, color: Colors.orangeAccent, label: l10n.metricPhase, value: _appState == AppState.fasting ? l10n.fastingPhase : l10n.eatingWindow, onTap: () => _showMetricInfo(title: l10n.titleCurrentPhase, value: _appState == AppState.fasting ? l10n.valFastingZone : l10n.valEatingWindow, description: _appState == AppState.fasting ? l10n.descFastingZone : l10n.descEatingWindow, icon: Icons.local_fire_department_rounded, color: Colors.orangeAccent)),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                  _buildInfoItem(icon: Icons.bolt_rounded, color: const Color(0xFFF9D423), label: l10n.metricStreak, value: l10n.valStreakDays(_streakDays), onTap: () => _showMetricInfo(title: l10n.titleConsistencyStreak, value: l10n.valStreakDays(_streakDays), description: l10n.descStreak(_streakDays), icon: Icons.bolt_rounded, color: const Color(0xFFF9D423))),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),

                  // BMI ВМЕСТО STATUS
                  _buildInfoItem(
                      icon: Icons.health_and_safety_rounded,
                      color: bmiColor,
                      label: l10n.bmiScore,
                      value: bmiStr,
                      onTap: () => _showMetricInfo(
                          title: l10n.bmiScore,
                          value: "$bmiStr ($bmiCat)",
                          description: l10n.bmiDescription(_userHeight.toInt(), _currentWeight.toStringAsFixed(1)),
                          icon: Icons.health_and_safety_rounded,
                          color: bmiColor
                      )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ВОДА И ВЕС
            Row(
              children: [
                // ВОДА С ДОЛГИМ НАЖАТИЕМ
                Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: _addWater,
                      onLongPress: _showWaterMenu,
                      child: GlassCard(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 20)), Text("${(_waterCount / (_waterGoal == 0 ? 1 : _waterGoal) * 100).toInt()}%", style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontWeight: FontWeight.bold))]), const SizedBox(height: 12), Text(l10n.waterIntake, style: const TextStyle(color: Colors.white54, fontSize: 12)), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("$_waterCount", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)), Padding(padding: const EdgeInsets.only(bottom: 4, left: 4), child: Text("/ $_waterGoal", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))])])
                      ),
                    )
                ),
                const SizedBox(width: 12),
                // ВЕС
                Expanded(flex: 4, child: GlassCard(onTap: _showWeightPicker, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00FA9A).withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.show_chart_rounded, color: Color(0xFF00FA9A), size: 20)), Icon(Icons.arrow_right_alt_rounded, color: const Color(0xFF00FA9A).withOpacity(0.8), size: 16)]), const SizedBox(height: 12), Text(l10n.currentWeight, style: const TextStyle(color: Colors.white54, fontSize: 12)), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_currentWeight.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)), Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text(l10n.unitKg, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)))])]))),
              ],
            ),

            const SizedBox(height: 16),

            // PRO БАННЕР
            GlassCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
              child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.amber)), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.proBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(l10n.proBannerDesc, style: const TextStyle(color: Colors.white54, fontSize: 13))]), const Spacer(), Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))]),
            ),

            const SizedBox(height: 20),

            // РЕКЛАМА
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, int index, String label, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = isCenter ? 32 : 26;
    final Color activeColor = isCenter ? Colors.blueAccent : Colors.white;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = index);
        // Если перешли на таймер (индекс 2), обновляем данные
        if (index == 2) _loadStateData();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isCenter ? 14 : 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isCenter ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2))
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected && isCenter
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15)]
                  : [],
            ),
            child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.white.withOpacity(0.4),
                size: iconSize
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: MeshBackground(
        isFasting: _appState == AppState.fasting,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _pages[0], // History (0)
            _pages[1], // Stats (1)
            _buildDashboard(context), // Timer (2 - Центр)
            _pages[3], // Food (3)
            _pages[4], // Profile (4)
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
        color: Colors.transparent,
        child: GlassCard(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockItem(Icons.calendar_month_rounded, 0, l10n.navHistory),
              _buildDockItem(Icons.bar_chart_rounded, 1, l10n.navStats),
              _buildDockItem(Icons.timer_rounded, 2, l10n.navTimer, isCenter: true),
              _buildDockItem(Icons.restaurant_menu_rounded, 3, l10n.navFood),
              _buildDockItem(Icons.person_rounded, 4, l10n.navProfile),
            ],
          ),
        ),
      ),
    );
  }
}