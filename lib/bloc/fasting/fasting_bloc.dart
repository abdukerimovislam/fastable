import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // Для debugPrint
import 'package:flutter/widgets.dart';    // Для WidgetsBindingObserver и AppLifecycleState
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/models/fasting_record.dart';

import '../../services/live_activity_services.dart';

@injectable
class FastingBloc extends Bloc<FastingEvent, FastingState> with WidgetsBindingObserver {
  final NotificationService _notificationService;
  final HapticService _hapticService;
  final HistoryRepository _historyRepository;
  final LiveActivityService _liveActivityService;

  Timer? _ticker;
  final List<FastingPlan> _plans = FastingPlan.defaultPlans;

  int _customTargetHours = 14;
  Duration _circadianDuration = const Duration(hours: 14); // Дефолт на случай ошибки

  FastingBloc(
      this._notificationService,
      this._hapticService,
      this._historyRepository,
      this._liveActivityService,
      )
      : super(const FastingState()) {

    WidgetsBinding.instance.addObserver(this);

    on<CheckFastingState>(_onCheckState);
    on<StartFasting>(_onStartFasting);
    on<EndFasting>(_onEndFasting);
    on<EndEatingWindow>(_onEndEatingWindow);
    on<TickTimer>(_onTick);
    on<ChangePlan>(_onChangePlan);
    on<SetCustomPlan>(_onSetCustomPlan);
    on<StartCircadianFast>(_onStartCircadianFast); // 🔥 ДОБАВЛЕНО
    on<ResetFasting>(_onReset);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState stateLifecycle) {
    if (stateLifecycle == AppLifecycleState.resumed) {
      if (state.startTime != null && state.phase != FastingPhase.stopped) {
        final now = DateTime.now();
        final diff = now.difference(state.startTime!);
        final elapsed = diff.isNegative ? Duration.zero : diff;

        add(TickTimer(elapsed));
      }
    }
  }

  Future<void> _onCheckState(
      CheckFastingState event, Emitter<FastingState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int planIdx = prefs.getInt('fast_plan_index') ?? 0;
      _customTargetHours = prefs.getInt('custom_target_hours') ?? 14;

      // Загружаем сохраненную длительность для циркадного плана, если она была
      final circadianMinutes = prefs.getInt('circadian_target_minutes');
      if (circadianMinutes != null) {
        _circadianDuration = Duration(minutes: circadianMinutes);
      }

      if (planIdx != FastingState.customPlanIndex &&
          planIdx != FastingState.circadianPlanIndex && // 🔥 Разрешаем этот индекс
          (planIdx < 0 || planIdx >= _plans.length)) {
        planIdx = 0;
      }

      String stateStr = prefs.getString('app_state') ?? 'stopped';
      FastingPhase phase = FastingPhase.values.firstWhere(
              (e) => e.name == stateStr,
          orElse: () => FastingPhase.stopped);

      String? startStr = prefs.getString('cycle_start_time');
      DateTime? startTime = startStr != null ? DateTime.tryParse(startStr) : null;

      final goal = _getGoalForPhase(phase, planIdx);

      if (phase != FastingPhase.stopped && startTime != null) {
        final now = DateTime.now();
        final diff = now.difference(startTime);
        final elapsed = diff.isNegative ? Duration.zero : diff;

        emit(state.copyWith(
          phase: phase,
          startTime: startTime,
          elapsed: elapsed,
          planIndex: planIdx,
          goalDuration: goal,
        ));
        _startTicker();

        _liveActivityService.startFastingActivity(
            startTime: startTime,
            goalDuration: goal,
            phaseName: phase == FastingPhase.fasting ? "Fasting" : "Eating"
        );

      } else {
        final fastingGoal = _getGoalForPhase(FastingPhase.fasting, planIdx);

        emit(state.copyWith(
          phase: FastingPhase.stopped,
          planIndex: planIdx,
          goalDuration: fastingGoal,
        ));

        _liveActivityService.stopActivity();
      }
    } catch (e) {
      debugPrint("FastingBloc Error in _onCheckState: $e");
      emit(const FastingState());
    }
  }

  // 🔥 НОВЫЙ МЕТОД ДЛЯ СТАРТА ЦИРКАДНОГО ГОЛОДАНИЯ
  Future<void> _onStartCircadianFast(
      StartCircadianFast event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем настройки плана
    await prefs.setInt('fast_plan_index', FastingState.circadianPlanIndex);
    await prefs.setInt('circadian_target_minutes', event.targetDuration.inMinutes);
    _circadianDuration = event.targetDuration;

    // Вызываем стандартный старт, но уже с новым стейтом
    emit(state.copyWith(
      planIndex: FastingState.circadianPlanIndex,
      goalDuration: event.targetDuration,
    ));

    add(const StartFasting());
  }

  Future<void> _onStartFasting(
      StartFasting event, Emitter<FastingState> emit) async {
    try {
      _hapticService.mediumImpact();

      final startDate = event.startTime ?? DateTime.now();
      final goal = state.goalDuration;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_state', FastingPhase.fasting.name);
      await prefs.setString('cycle_start_time', startDate.toIso8601String());

      try {
        final locale = PlatformDispatcher.instance.locale;
        final l10n = await lookupAppLocalizations(locale);

        await _notificationService.scheduleFastingNotifications(
          startTime: startDate,
          duration: goal,
          l10n: l10n,
        );
      } catch (e) {
        debugPrint("Notification Error: $e");
      }

      final now = DateTime.now();
      final diff = now.difference(startDate);
      final elapsed = diff.isNegative ? Duration.zero : diff;

      emit(state.copyWith(
        phase: FastingPhase.fasting,
        startTime: startDate,
        elapsed: elapsed,
        goalDuration: goal,
        isGoalReached: false,
      ));
      _startTicker();

      _liveActivityService.startFastingActivity(
        startTime: startDate,
        goalDuration: goal,
        phaseName: "Fasting",
      );

    } catch (e) {
      debugPrint("FastingBloc Error in _onStartFasting: $e");
    }
  }

  Future<void> _onEndFasting(
      EndFasting event, Emitter<FastingState> emit) async {
    try {
      _ticker?.cancel();

      final now = DateTime.now();
      DateTime endDate = event.endTime ?? now;
      if (endDate.isAfter(now)) {
        endDate = now;
      }

      if (state.startTime != null && state.phase == FastingPhase.fasting) {
        if (endDate.isBefore(state.startTime!)) {
          debugPrint("❌ Guardrail: End time is before Start time. Aborting save.");
        } else {
          final duration = endDate.difference(state.startTime!);

          if (duration.inMinutes >= 5) {
            _hapticService.success();
            try {
              final prefs = await SharedPreferences.getInstance();
              final savedMoodStr = prefs.getString('current_fast_mood');
              FastingMood? loggedMood;
              if (savedMoodStr != null) {
                try {
                  loggedMood = FastingMood.values.firstWhere((e) => e.name == savedMoodStr);
                } catch (_) {}
              }

              final savedSymptoms = prefs.getStringList('current_fast_symptoms') ?? [];
              String? finalNote;
              if (savedSymptoms.isNotEmpty) {
                finalNote = "Symptoms: ${savedSymptoms.join(', ')}";
              }

              await prefs.remove('current_fast_mood');
              await prefs.remove('current_fast_symptoms');

              final record = FastingRecord(
                startTime: state.startTime!,
                endTime: endDate,
                duration: duration,
                mood: event.mood ?? loggedMood,
                note: finalNote,
              );
              await _historyRepository.addRecord(record);
            } catch (e) {
              debugPrint("History Save Error: $e");
            }
          } else {
            debugPrint("⏳ Guardrail: Fasting too short (< 5 min), discarded.");
          }
        }
      }

      final eatGoal = _getGoalForPhase(FastingPhase.eating, state.planIndex);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_state', FastingPhase.eating.name);
      await prefs.setString('cycle_start_time', endDate.toIso8601String());

      try {
        final locale = PlatformDispatcher.instance.locale;
        final l10n = await lookupAppLocalizations(locale);

        await _notificationService.scheduleEatingNotifications(
          startTime: endDate,
          duration: eatGoal,
          l10n: l10n,
        );
      } catch (e) {
        debugPrint("Notification Error: $e");
      }

      final diff = DateTime.now().difference(endDate);
      final elapsed = diff.isNegative ? Duration.zero : diff;

      emit(state.copyWith(
        phase: FastingPhase.eating,
        startTime: endDate,
        elapsed: elapsed,
        goalDuration: eatGoal,
        isGoalReached: false,
      ));
      _startTicker();

      await _liveActivityService.stopActivity();
      _liveActivityService.startFastingActivity(
        startTime: endDate,
        goalDuration: eatGoal,
        phaseName: "Eating",
      );

    } catch (e) {
      debugPrint("FastingBloc Error in _onEndFasting: $e");
    }
  }

  Future<void> _onEndEatingWindow(
      EndEatingWindow event, Emitter<FastingState> emit) async {
    add(ResetFasting());
  }

  Future<void> _onReset(ResetFasting event, Emitter<FastingState> emit) async {
    try {
      _ticker?.cancel();
      _hapticService.mediumImpact();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_state');
      await prefs.remove('cycle_start_time');

      await prefs.remove('current_fast_mood');
      await prefs.remove('current_fast_symptoms');

      await _notificationService.cancelFastingNotifications();

      final resetGoal = _getGoalForPhase(FastingPhase.fasting, state.planIndex);

      emit(state.copyWith(
        phase: FastingPhase.stopped,
        startTime: null,
        elapsed: Duration.zero,
        isGoalReached: false,
        goalDuration: resetGoal,
      ));

      _liveActivityService.stopActivity();

    } catch (e) {
      debugPrint("FastingBloc Error in _onReset: $e");
    }
  }

  Future<void> _onChangePlan(
      ChangePlan event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fast_plan_index', event.planIndex);

    final newGoal = _getGoalForPhase(state.phase, event.planIndex);

    emit(state.copyWith(
      planIndex: event.planIndex,
      goalDuration: newGoal,
    ));
  }

  Future<void> _onSetCustomPlan(
      SetCustomPlan event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('fast_plan_index', FastingState.customPlanIndex);
    await prefs.setInt('custom_target_hours', event.targetHours);

    _customTargetHours = event.targetHours;
    final newGoal = _getGoalForPhase(state.phase, FastingState.customPlanIndex);

    emit(state.copyWith(
      planIndex: FastingState.customPlanIndex,
      goalDuration: newGoal,
    ));
  }

  void _onTick(TickTimer event, Emitter<FastingState> emit) {
    bool reached = event.elapsed >= state.goalDuration;
    emit(state.copyWith(elapsed: event.elapsed, isGoalReached: reached));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        final now = DateTime.now();
        final diff = now.difference(state.startTime!);
        final elapsed = diff.isNegative ? Duration.zero : diff;
        add(TickTimer(elapsed));
      }
    });
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    return super.close();
  }

  // 🔥 ОБНОВЛЕННЫЙ МЕТОД: Умеет считать окно еды даже для циркадного плана
  Duration _getGoalForPhase(FastingPhase phase, int planIdx) {
    if (planIdx == FastingState.customPlanIndex) {
      if (phase == FastingPhase.eating) {
        return Duration(hours: (24 - _customTargetHours).clamp(1, 23));
      } else {
        return Duration(hours: _customTargetHours);
      }
    } else if (planIdx == FastingState.circadianPlanIndex) {
      if (phase == FastingPhase.eating) {
        // Окно еды для циркадного (упрощенно = 24 часа минус время заката-рассвета)
        final eatingMinutes = (24 * 60) - _circadianDuration.inMinutes;
        return Duration(minutes: eatingMinutes.clamp(60, 23 * 60));
      } else {
        return _circadianDuration;
      }
    }

    return phase == FastingPhase.eating
        ? _plans[planIdx].eatingDuration
        : _plans[planIdx].fastingDuration;
  }
}