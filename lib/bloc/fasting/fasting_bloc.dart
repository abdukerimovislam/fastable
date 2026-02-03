import 'dart:async';
import 'dart:ui'; // 1. Added for PlatformDispatcher
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart'; // 2. Added for lookupAppLocalizations

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

  FastingBloc(this._notificationService, this._hapticService, this._historyRepository)
      : super(const FastingState()) {
    on<CheckFastingState>(_onCheckState);
    on<StartFasting>(_onStartFasting);
    on<EndFasting>(_onEndFasting);
    on<EndEatingWindow>(_onEndEatingWindow);
    on<TickTimer>(_onTick);
    on<ChangePlan>(_onChangePlan);
    on<ResetFasting>(_onReset);
  }

  Future<void> _onCheckState(CheckFastingState event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    int planIdx = (prefs.getInt('fast_plan_index') ?? 0).clamp(0, _plans.length - 1);

    String stateStr = prefs.getString('app_state') ?? 'stopped';
    FastingPhase phase = FastingPhase.values.firstWhere((e) => e.name == stateStr, orElse: () => FastingPhase.stopped);

    String? startStr = prefs.getString('cycle_start_time');
    DateTime? startTime = startStr != null ? DateTime.tryParse(startStr) : null;

    if (phase != FastingPhase.stopped && startTime != null) {
      final now = DateTime.now();
      emit(state.copyWith(
        phase: phase,
        startTime: startTime,
        elapsed: now.difference(startTime),
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
  }

  Future<void> _onStartFasting(StartFasting event, Emitter<FastingState> emit) async {
    _hapticService.mediumImpact();

    // Use passed time or current time
    final startDate = event.startTime ?? DateTime.now();
    final goal = _plans[state.planIndex].fastingDuration;

    // Save state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_state', FastingPhase.fasting.name);
    await prefs.setString('cycle_start_time', startDate.toIso8601String());

    // --- UPDATED NOTIFICATION LOGIC ---
    // Get current locale to ensure notifications are in the correct language
    final locale = PlatformDispatcher.instance.locale;
    final l10n = await lookupAppLocalizations(locale);

    // Schedule all smart notifications (Stages, 50%, 1h left, Finish)
    await _notificationService.scheduleFastingNotifications(
      startTime: startDate,
      duration: goal,
      l10n: l10n,
    );
    // ----------------------------------

    emit(state.copyWith(
      phase: FastingPhase.fasting,
      startTime: startDate,
      elapsed: DateTime.now().difference(startDate),
      goalDuration: goal,
      isGoalReached: false,
    ));
    _startTicker();
  }

  Future<void> _onEndFasting(EndFasting event, Emitter<FastingState> emit) async {
    _ticker?.cancel();
    _hapticService.success();

    // Use passed time or current time
    final endDate = event.endTime ?? DateTime.now();

    // 1. Save record to history WITH MOOD
    if (state.startTime != null && state.phase == FastingPhase.fasting) {
      final record = FastingRecord(
        startTime: state.startTime!,
        endTime: endDate,
        duration: endDate.difference(state.startTime!),
        mood: event.mood,
      );
      await _historyRepository.addRecord(record);
    }

    // 2. Transition to Eating Window
    final eatGoal = _plans[state.planIndex].eatingDuration;

    // Save state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_state', FastingPhase.eating.name);
    await prefs.setString('cycle_start_time', endDate.toIso8601String());

    // --- UPDATED NOTIFICATION LOGIC ---
    // Get locale and schedule eating window notifications
    final locale = PlatformDispatcher.instance.locale;
    final l10n = await lookupAppLocalizations(locale);

    await _notificationService.scheduleEatingNotifications(
      startTime: endDate,
      duration: eatGoal,
      l10n: l10n,
    );
    // ----------------------------------

    emit(state.copyWith(
      phase: FastingPhase.eating,
      startTime: endDate,
      elapsed: DateTime.now().difference(endDate),
      goalDuration: eatGoal,
      isGoalReached: false,
    ));
    _startTicker();
  }

  Future<void> _onEndEatingWindow(EndEatingWindow event, Emitter<FastingState> emit) async {
    add(ResetFasting());
  }

  Future<void> _onReset(ResetFasting event, Emitter<FastingState> emit) async {
    _ticker?.cancel();
    _hapticService.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_state');
    await prefs.remove('cycle_start_time');

    // Cancel all fasting related notifications
    await _notificationService.cancelFastingNotifications();

    emit(state.copyWith(
      phase: FastingPhase.stopped,
      startTime: null,
      elapsed: Duration.zero,
      isGoalReached: false,
      goalDuration: _plans[state.planIndex].fastingDuration,
    ));
  }

  Future<void> _onChangePlan(ChangePlan event, Emitter<FastingState> emit) async {
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
    bool reached = event.elapsed >= state.goalDuration;
    if (state.phase == FastingPhase.eating && reached) {
      add(ResetFasting());
      return;
    }
    emit(state.copyWith(elapsed: event.elapsed, isGoalReached: reached));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        add(TickTimer(DateTime.now().difference(state.startTime!)));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Duration _getGoalForPhase(FastingPhase phase, int planIdx) {
    return phase == FastingPhase.eating ? _plans[planIdx].eatingDuration : _plans[planIdx].fastingDuration;
  }
}