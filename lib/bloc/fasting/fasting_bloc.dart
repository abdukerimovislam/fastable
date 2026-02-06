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

  // Храним текущее кастомное значение (в часах), если оно выбрано
  int _customTargetHours = 14;

  FastingBloc(
      this._notificationService, this._hapticService, this._historyRepository)
      : super(const FastingState()) {
    on<CheckFastingState>(_onCheckState);
    on<StartFasting>(_onStartFasting);
    on<EndFasting>(_onEndFasting);
    on<EndEatingWindow>(_onEndEatingWindow);
    on<TickTimer>(_onTick);
    on<ChangePlan>(_onChangePlan);
    on<SetCustomPlan>(_onSetCustomPlan); // 🔥 Обработка кастомного плана
    on<ResetFasting>(_onReset);
  }

  Future<void> _onCheckState(
      CheckFastingState event, Emitter<FastingState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Читаем индекс плана. Если -1 -> Custom. Иначе -> Preset.
      int planIdx = prefs.getInt('fast_plan_index') ?? 0;

      // Читаем сохраненное кастомное время (если было)
      _customTargetHours = prefs.getInt('custom_target_hours') ?? 14;

      // Если индекс выходит за рамки и не равен -1, сбрасываем на 0
      if (planIdx != FastingState.customPlanIndex && (planIdx < 0 || planIdx >= _plans.length)) {
        planIdx = 0;
      }

      String stateStr = prefs.getString('app_state') ?? 'stopped';
      FastingPhase phase = FastingPhase.values.firstWhere(
              (e) => e.name == stateStr,
          orElse: () => FastingPhase.stopped);

      String? startStr = prefs.getString('cycle_start_time');
      DateTime? startTime =
      startStr != null ? DateTime.tryParse(startStr) : null;

      // Определяем цель на основе фазы и плана
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
      } else {
        // Если таймер остановлен, показываем цель для голодания
        final fastingGoal = planIdx == FastingState.customPlanIndex
            ? Duration(hours: _customTargetHours)
            : _plans[planIdx].fastingDuration;

        emit(state.copyWith(
          phase: FastingPhase.stopped,
          planIndex: planIdx,
          goalDuration: fastingGoal,
        ));
      }
    } catch (e) {
      debugPrint("FastingBloc Error in _onCheckState: $e");
      emit(const FastingState());
    }
  }

  Future<void> _onStartFasting(
      StartFasting event, Emitter<FastingState> emit) async {
    try {
      _hapticService.mediumImpact();

      final startDate = event.startTime ?? DateTime.now();

      // Цель берем текущую из стейта (она уже правильная: пресет или кастом)
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

      // Переход к окну еды
      // Если план кастомный, окно еды рассчитываем как (24 - часы голода)
      final eatGoal = state.planIndex == FastingState.customPlanIndex
          ? Duration(hours: (24 - _customTargetHours).clamp(1, 23)) // Минимум 1 час еды
          : _plans[state.planIndex].eatingDuration;

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

      await _notificationService.cancelFastingNotifications();

      // При сбросе возвращаем цель голодания (пресет или кастом)
      final resetGoal = state.planIndex == FastingState.customPlanIndex
          ? Duration(hours: _customTargetHours)
          : _plans[state.planIndex].fastingDuration;

      emit(state.copyWith(
        phase: FastingPhase.stopped,
        startTime: null,
        elapsed: Duration.zero,
        isGoalReached: false,
        goalDuration: resetGoal,
      ));
    } catch (e) {
      debugPrint("FastingBloc Error in _onReset: $e");
    }
  }

  Future<void> _onChangePlan(
      ChangePlan event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fast_plan_index', event.planIndex);

    // Если меняем план во время таймера, обновляем цель
    // Если таймер остановлен, тоже обновляем, чтобы UI показал новое время
    Duration newGoal;

    if (state.phase == FastingPhase.eating) {
      newGoal = _plans[event.planIndex].eatingDuration;
    } else {
      newGoal = _plans[event.planIndex].fastingDuration;
    }

    emit(state.copyWith(
      planIndex: event.planIndex,
      goalDuration: newGoal,
    ));
  }

  // 🔥 ОБРАБОТКА КАСТОМНОГО ПЛАНА
  Future<void> _onSetCustomPlan(
      SetCustomPlan event, Emitter<FastingState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем -1 как индекс плана (означает Custom)
    await prefs.setInt('fast_plan_index', FastingState.customPlanIndex);
    // Сохраняем само значение часов
    await prefs.setInt('custom_target_hours', event.targetHours);

    _customTargetHours = event.targetHours;

    final newGoal = Duration(hours: event.targetHours);

    // Если мы в фазе голодания или стоп, обновляем цель
    // Если мы едим, пересчитываем окно еды (24 - цель)
    if (state.phase == FastingPhase.eating) {
      final eatGoal = Duration(hours: (24 - event.targetHours).clamp(1, 23));
      emit(state.copyWith(
        planIndex: FastingState.customPlanIndex,
        goalDuration: eatGoal,
      ));
    } else {
      emit(state.copyWith(
        planIndex: FastingState.customPlanIndex,
        goalDuration: newGoal,
      ));
    }
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
    _ticker?.cancel();
    return super.close();
  }

  // Вспомогательный метод для определения цели при старте/проверке
  Duration _getGoalForPhase(FastingPhase phase, int planIdx) {
    // Если план кастомный (-1)
    if (planIdx == FastingState.customPlanIndex) {
      if (phase == FastingPhase.eating) {
        return Duration(hours: (24 - _customTargetHours).clamp(1, 23));
      } else {
        return Duration(hours: _customTargetHours);
      }
    }

    // Если план стандартный
    return phase == FastingPhase.eating
        ? _plans[planIdx].eatingDuration
        : _plans[planIdx].fastingDuration;
  }
}