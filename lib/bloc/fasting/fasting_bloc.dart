import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/models/fasting_plan.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/haptic_service.dart';
// Импортируй репозиторий истории, если он нужен для сохранения
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/models/fasting_record.dart';

@injectable
class FastingBloc extends Bloc<FastingEvent, FastingState> {
  final NotificationService _notificationService;
  final HapticService _hapticService;
  final HistoryRepository _historyRepository; // Добавляем репозиторий

  Timer? _ticker;

  // Планы (можно вынести в отдельный конфиг)
  final List<FastingPlan> _plans = [
    FastingPlan(fastingDuration: const Duration(hours: 16), eatingDuration: const Duration(hours: 8), translationKey: "fastingPlan16_8"),
    FastingPlan(fastingDuration: const Duration(hours: 18), eatingDuration: const Duration(hours: 6), translationKey: "fastingPlan18_6"),
    FastingPlan(fastingDuration: const Duration(hours: 20), eatingDuration: const Duration(hours: 4), translationKey: "fastingPlan20_4"),
    FastingPlan(fastingDuration: const Duration(hours: 24), eatingDuration: const Duration(hours: 24), translationKey: "fastingPlanEatStopEat"),
  ];

  FastingBloc(
      this._notificationService,
      this._hapticService,
      this._historyRepository, // Inject repository
      ) : super(const FastingState()) {

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

    // Восстанавливаем план
    int planIdx = prefs.getInt('fast_plan_index') ?? 0;
    if (planIdx >= _plans.length) planIdx = 0;

    // Восстанавливаем состояние
    String stateStr = prefs.getString('app_state') ?? 'stopped';
    FastingPhase phase = FastingPhase.values.firstWhere(
            (e) => e.name == stateStr,
        orElse: () => FastingPhase.stopped
    );

    DateTime? startTime;
    String? startStr = prefs.getString('cycle_start_time');
    if (startStr != null) startTime = DateTime.tryParse(startStr);

    Duration goal = _getGoalForPhase(phase, planIdx);

    if (phase != FastingPhase.stopped && startTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(startTime);

      emit(state.copyWith(
        phase: phase,
        startTime: startTime,
        elapsed: elapsed,
        planIndex: planIdx,
        goalDuration: goal,
      ));

      _startTicker();
    } else {
      emit(state.copyWith(
          phase: FastingPhase.stopped,
          planIndex: planIdx,
          goalDuration: _plans[planIdx].fastingDuration
      ));
    }
  }

  Future<void> _onStartFasting(StartFasting event, Emitter<FastingState> emit) async {
    await _hapticService.mediumImpact();

    final now = DateTime.now();
    final goal = _plans[state.planIndex].fastingDuration;

    // Сохраняем
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('app_state', FastingPhase.fasting.name);
    prefs.setString('cycle_start_time', now.toIso8601String());

    // Уведомления
    final finishTime = now.add(goal);
    // Используем простой метод, который мы починили
    _notificationService.scheduleFastCompletion(finishTime, "Fasting Goal Reached!");
    _notificationService.scheduleWaterReminder(); // Простое напоминание

    emit(state.copyWith(
      phase: FastingPhase.fasting,
      startTime: now,
      elapsed: Duration.zero,
      goalDuration: goal,
      isGoalReached: false,
    ));

    _startTicker();
  }

  Future<void> _onEndFasting(EndFasting event, Emitter<FastingState> emit) async {
    _ticker?.cancel();
    await _hapticService.success();

    // Сохраняем в историю, если это не просто отмена, а завершение
    if (state.startTime != null) {
      final record = FastingRecord(
        startTime: state.startTime!,
        endTime: DateTime.now(),
        duration: state.elapsed,
      );
      // Запускаем сохранение (fire and forget или await)
      try {
        await _historyRepository.addRecord(record);
      } catch (e) {
        print("Error saving history: $e");
      }
    }

    // Автоматически переходим к Еде
    add(EndEatingWindow()); // Wait, naming is tricky here.
    // Usually "End Fasting" -> "Start Eating".
    // Let's implement _startEating logic directly here or via event.
    // Логика из HomePage: _startEating() вызывается после сохранения

    // Запускаем окно еды
    final now = DateTime.now();
    final eatGoal = _plans[state.planIndex].eatingDuration;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('app_state', FastingPhase.eating.name);
    prefs.setString('cycle_start_time', now.toIso8601String());

    // Уведомление о конце еды
    _notificationService.scheduleEatingCompletion(now.add(eatGoal));

    emit(state.copyWith(
      phase: FastingPhase.eating,
      startTime: now,
      elapsed: Duration.zero,
      goalDuration: eatGoal,
      isGoalReached: false,
    ));

    _startTicker();
  }

  Future<void> _onEndEatingWindow(EndEatingWindow event, Emitter<FastingState> emit) async {
    // Это событие "Начать новый цикл голодания" (Stop Eating -> Start Fasting?)
    // Или просто Stop?
    // В HomePage логика была: _performReset (Stop)
    // Давай сделаем Reset
    add(ResetFasting());
  }

  Future<void> _onReset(ResetFasting event, Emitter<FastingState> emit) async {
    _ticker?.cancel();
    await _hapticService.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('app_state');
    prefs.remove('cycle_start_time');

    await _notificationService.cancelAllNotifications();

    emit(state.copyWith(
      phase: FastingPhase.stopped,
      startTime: null, // Force reset
      elapsed: Duration.zero,
      isGoalReached: false,
      goalDuration: _plans[state.planIndex].fastingDuration, // Вернуть длительность плана
    ));
  }

  Future<void> _onTick(TickTimer event, Emitter<FastingState> emit) async {
    // Проверка достижения цели
    bool reached = event.elapsed >= state.goalDuration;

    // Если мы в режиме еды и время вышло -> можно авто-сбросить или ждать действий
    // В оригинале было: if (eating && diff >= eatDuration) _performReset();
    if (state.phase == FastingPhase.eating && reached) {
      add(ResetFasting());
      return;
    }

    emit(state.copyWith(
      elapsed: event.elapsed,
      isGoalReached: reached,
    ));
  }

  Future<void> _onChangePlan(ChangePlan event, Emitter<FastingState> emit) async {
    if (event.planIndex < 0 || event.planIndex >= _plans.length) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('fast_plan_index', event.planIndex);

    Duration newGoal;
    // Если мы уже в процессе, меняем ли мы цель на лету?
    // Обычно да, если это фаза голодания.
    if (state.phase == FastingPhase.fasting) {
      newGoal = _plans[event.planIndex].fastingDuration;
    } else if (state.phase == FastingPhase.eating) {
      newGoal = _plans[event.planIndex].eatingDuration;
    } else {
      newGoal = _plans[event.planIndex].fastingDuration;
    }

    emit(state.copyWith(
      planIndex: event.planIndex,
      goalDuration: newGoal,
    ));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        final elapsed = DateTime.now().difference(state.startTime!);
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
    if (phase == FastingPhase.eating) {
      return _plans[planIdx].eatingDuration;
    }
    return _plans[planIdx].fastingDuration;
  }
}