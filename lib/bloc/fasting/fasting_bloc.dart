import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // Для debugPrint
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

@injectable
class FastingBloc extends Bloc<FastingEvent, FastingState> {
  final NotificationService _notificationService;
  final HapticService _hapticService;
  final HistoryRepository _historyRepository;

  Timer? _ticker;
  final List<FastingPlan> _plans = FastingPlan.defaultPlans;

  FastingBloc(
      this._notificationService, this._hapticService, this._historyRepository)
      : super(const FastingState()) {
    on<CheckFastingState>(_onCheckState);
    on<StartFasting>(_onStartFasting);
    on<EndFasting>(_onEndFasting);
    on<EndEatingWindow>(_onEndEatingWindow);
    on<TickTimer>(_onTick);
    on<ChangePlan>(_onChangePlan);
    on<ResetFasting>(_onReset);
  }

  Future<void> _onCheckState(
      CheckFastingState event, Emitter<FastingState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int planIdx =
      (prefs.getInt('fast_plan_index') ?? 0).clamp(0, _plans.length - 1);

      String stateStr = prefs.getString('app_state') ?? 'stopped';
      FastingPhase phase = FastingPhase.values.firstWhere(
              (e) => e.name == stateStr,
          orElse: () => FastingPhase.stopped);

      String? startStr = prefs.getString('cycle_start_time');
      DateTime? startTime =
      startStr != null ? DateTime.tryParse(startStr) : null;

      if (phase != FastingPhase.stopped && startTime != null) {
        final now = DateTime.now();
        // Защита от отрицательного времени при старте
        final diff = now.difference(startTime);
        final elapsed = diff.isNegative ? Duration.zero : diff;

        emit(state.copyWith(
          phase: phase,
          startTime: startTime,
          elapsed: elapsed,
          planIndex: planIdx,
          goalDuration: _getGoalForPhase(phase, planIdx),
        ));
        _startTicker();
      } else {
        emit(state.copyWith(
          phase: FastingPhase.stopped,
          planIndex: planIdx,
          goalDuration: _plans[planIdx].fastingDuration,
        ));
      }
    } catch (e) {
      debugPrint("FastingBloc Error in _onCheckState: $e");
      // Fallback state
      emit(const FastingState());
    }
  }

  Future<void> _onStartFasting(
      StartFasting event, Emitter<FastingState> emit) async {
    try {
      _hapticService.mediumImpact();

      // Use passed time or current time
      final startDate = event.startTime ?? DateTime.now();
      final goal = _plans[state.planIndex].fastingDuration;

      // Save state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_state', FastingPhase.fasting.name);
      await prefs.setString('cycle_start_time', startDate.toIso8601String());

      // Notification Logic
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

      // Calculate initial elapsed (prevent negative)
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
    } catch (e) {
      debugPrint("FastingBloc Error in _onStartFasting: $e");
    }
  }

  Future<void> _onEndFasting(
      EndFasting event, Emitter<FastingState> emit) async {
    try {
      _ticker?.cancel();
      _hapticService.success();

      final endDate = event.endTime ?? DateTime.now();

      // 1. Save record to history WITH MOOD
      if (state.startTime != null && state.phase == FastingPhase.fasting) {
        try {
          final record = FastingRecord(
            startTime: state.startTime!,
            endTime: endDate,
            duration: endDate.difference(state.startTime!),
            mood: event.mood,
          );
          await _historyRepository.addRecord(record);
        } catch (e) {
          debugPrint("History Save Error: $e");
        }
      }

      // 2. Transition to Eating Window
      final eatGoal = _plans[state.planIndex].eatingDuration;

      // Save state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_state', FastingPhase.eating.name);
      await prefs.setString('cycle_start_time', endDate.toIso8601String());

      // Eating Notifications
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

      final now = DateTime.now();
      final diff = now.difference(endDate);
      final elapsed = diff.isNegative ? Duration.zero : diff;

      emit(state.copyWith(
        phase: FastingPhase.eating,
        startTime: endDate,
        elapsed: elapsed,
        goalDuration: eatGoal,
        isGoalReached: false,
      ));
      _startTicker();
    } catch (e) {
      debugPrint("FastingBloc Error in _onEndFasting: $e");
    }
  }

  // --- ИСПРАВЛЕНО: Теперь просто сбрасываем таймер в стоп ---
  Future<void> _onEndEatingWindow(
      EndEatingWindow event, Emitter<FastingState> emit) async {
    // Пользователь нажал "End Cycle" -> останавливаем всё.
    // Переходим в состояние "Ready to Fast".
    add(ResetFasting());
  }
  // -----------------------------------------------------------

  Future<void> _onReset(ResetFasting event, Emitter<FastingState> emit) async {
    try {
      _ticker?.cancel();
      _hapticService.mediumImpact();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_state');
      await prefs.remove('cycle_start_time');

      await _notificationService.cancelFastingNotifications();

      emit(state.copyWith(
        phase: FastingPhase.stopped,
        startTime: null,
        elapsed: Duration.zero,
        isGoalReached: false,
        goalDuration: _plans[state.planIndex].fastingDuration,
      ));
    } catch (e) {
      debugPrint("FastingBloc Error in _onReset: $e");
    }
  }

  Future<void> _onChangePlan(
      ChangePlan event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fast_plan_index', event.planIndex);

    Duration newGoal = state.phase == FastingPhase.eating
        ? _plans[event.planIndex].eatingDuration
        : _plans[event.planIndex].fastingDuration;

    emit(state.copyWith(
      planIndex: event.planIndex,
      goalDuration: newGoal,
    ));
  }

  void _onTick(TickTimer event, Emitter<FastingState> emit) {
    // Просто обновляем UI, не сбрасываем состояние
    bool reached = event.elapsed >= state.goalDuration;
    emit(state.copyWith(elapsed: event.elapsed, isGoalReached: reached));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        final now = DateTime.now();
        final diff = now.difference(state.startTime!);
        // Если время старта в будущем, elapsed = 0
        final elapsed = diff.isNegative ? Duration.zero : diff;
        add(TickTimer(elapsed));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Duration _getGoalForPhase(FastingPhase phase, int planIdx) {
    return phase == FastingPhase.eating
        ? _plans[planIdx].eatingDuration
        : _plans[planIdx].fastingDuration;
  }
}