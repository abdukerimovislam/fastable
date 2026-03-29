import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/models/drink_record.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

@injectable
class WaterBloc extends Bloc<WaterEvent, WaterState>
    with WidgetsBindingObserver {
  final WaterRepository _repository;
  final HealthService _healthService;

  WaterBloc(this._repository, this._healthService) : super(const WaterState()) {
    WidgetsBinding.instance.addObserver(this);

    on<LoadWaterData>(_onLoadData);
    on<AddDrink>(_onAddDrink);
    on<RemoveLastDrink>(_onRemoveLastDrink);
    on<UpdateWaterGoal>(_onUpdateGoal);
    on<ToggleAutoGoal>(_onToggleAutoGoal);
    on<UpdateRecommendedGoal>(_onUpdateRecommendedGoal);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      add(LoadWaterData());
    }
  }

  Future<void> _onLoadData(
    LoadWaterData event,
    Emitter<WaterState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      List<DrinkRecord> currentDrinks = [];

      if (lastDate != today) {
        await prefs.setString('water_last_date', today);
        await prefs.setString('today_drinks_json', '[]');
        await prefs.setDouble('health_water_last_liters', 0.0);
      } else {
        final String drinksJsonStr =
            prefs.getString('today_drinks_json') ?? '[]';
        // 🔥 ФИКС: Защита от битого JSON, если приложение крашнулось во время сохранения
        try {
          final List<dynamic> decodedList = jsonDecode(drinksJsonStr);
          currentDrinks = decodedList
              .map((item) => DrinkRecord.fromJson(item))
              .toList();
        } catch (_) {
          currentDrinks = [];
        }
      }

      if (currentDrinks.isEmpty) {
        currentDrinks = await _restoreTodayFromHistory(today, prefs);
      }

      int goal =
          prefs.getInt('water_goal_ml') ??
          ((prefs.getInt('water_goal') ?? 8) * 250);
      int recommended =
          prefs.getInt('water_recommended_ml') ??
          ((prefs.getInt('water_recommended') ?? 8) * 250);
      bool isAuto = prefs.getBool('water_is_auto') ?? true;

      emit(
        state.copyWith(
          status: WaterStatus.success,
          todayDrinks: currentDrinks,
          dailyGoal: goal,
          recommendedGoal: recommended,
          isAutoGoal: isAuto,
        ),
      );
    } catch (e) {
      debugPrint("WaterBloc Error in _onLoadData: $e");
      emit(state.copyWith(status: WaterStatus.failure));
    }
  }

  Future<void> _onAddDrink(AddDrink event, Emitter<WaterState> emit) async {
    try {
      final newDrink = DrinkRecord(
        time: DateTime.now(),
        volumeMl: event.volumeMl,
        type: event.type,
      );

      final updatedList = List<DrinkRecord>.from(state.todayDrinks)
        ..add(newDrink);
      emit(state.copyWith(todayDrinks: updatedList));

      if (event.type.breaksFast) {
        debugPrint(
          "⚠️ WARNING: User drank ${event.type.name}. This breaks the fast!",
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('water_last_date');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      if (lastDate != today) {
        await prefs.setString('water_last_date', today);
        await prefs.setString(
          'today_drinks_json',
          jsonEncode([newDrink.toJson()]),
        );
        emit(state.copyWith(todayDrinks: [newDrink]));
      } else {
        final jsonList = updatedList.map((d) => d.toJson()).toList();
        await prefs.setString('today_drinks_json', jsonEncode(jsonList));
      }

      final isHealthSyncEnabled = await HealthSyncPreferences.isEnabled(prefs);
      if (isHealthSyncEnabled && newDrink.effectiveHydration > 0) {
        double litersToAdd = newDrink.effectiveHydration / 1000.0;
        _healthService.writeWater(litersToAdd).then((success) async {
          if (success) {
            final lastHealthLiters =
                prefs.getDouble('health_water_last_liters') ?? 0.0;
            await prefs.setDouble(
              'health_water_last_liters',
              lastHealthLiters + litersToAdd,
            );
          }
        });
      }

      await _repository.saveEntry(DateTime.now(), _toCupCount(updatedList));
    } catch (e) {
      debugPrint("WaterBloc Error in _onAddDrink: $e");
    }
  }

  Future<void> _onRemoveLastDrink(
    RemoveLastDrink event,
    Emitter<WaterState> emit,
  ) async {
    try {
      if (state.todayDrinks.isEmpty) return;

      final updatedList = List<DrinkRecord>.from(state.todayDrinks)
        ..removeLast();
      emit(state.copyWith(todayDrinks: updatedList));

      final prefs = await SharedPreferences.getInstance();
      final jsonList = updatedList.map((d) => d.toJson()).toList();
      await prefs.setString('today_drinks_json', jsonEncode(jsonList));
      await _repository.saveEntry(DateTime.now(), _toCupCount(updatedList));

      // 🔥 Tech Debt: Undo does not remove records from Apple Health.
      // Needs HealthKit UUID mapping in the future.
    } catch (e) {
      debugPrint("WaterBloc Error in _onRemoveLastDrink: $e");
    }
  }

  Future<void> _onUpdateGoal(
    UpdateWaterGoal event,
    Emitter<WaterState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_goal_ml', event.newGoal);
      await prefs.setInt('water_goal', (event.newGoal / 250).round());
      await prefs.setBool('water_is_auto', false);

      emit(state.copyWith(dailyGoal: event.newGoal, isAutoGoal: false));
    } catch (e) {
      debugPrint("WaterBloc Error in _onUpdateGoal: $e");
    }
  }

  Future<void> _onToggleAutoGoal(
    ToggleAutoGoal event,
    Emitter<WaterState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('water_is_auto', event.isEnabled);

      int newGoal = state.dailyGoal;
      if (event.isEnabled) {
        newGoal = state.recommendedGoal;
        await prefs.setInt('water_goal_ml', newGoal);
        await prefs.setInt('water_goal', (newGoal / 250).round());
      }

      emit(state.copyWith(isAutoGoal: event.isEnabled, dailyGoal: newGoal));
    } catch (e) {
      debugPrint("WaterBloc Error in _onToggleAutoGoal: $e");
    }
  }

  Future<void> _onUpdateRecommendedGoal(
    UpdateRecommendedGoal event,
    Emitter<WaterState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_recommended_ml', event.cups);

      int currentGoal = state.dailyGoal;
      if (state.isAutoGoal) {
        currentGoal = event.cups;
        await prefs.setInt('water_goal_ml', currentGoal);
        await prefs.setInt('water_goal', (currentGoal / 250).round());
      }

      emit(state.copyWith(recommendedGoal: event.cups, dailyGoal: currentGoal));
    } catch (e) {
      debugPrint("WaterBloc Error in _onUpdateRecommendedGoal: $e");
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  int _toCupCount(List<DrinkRecord> drinks) {
    final totalVolumeMl = drinks.fold<int>(
      0,
      (sum, drink) => sum + drink.volumeMl,
    );
    return (totalVolumeMl / 250).round();
  }

  Future<List<DrinkRecord>> _restoreTodayFromHistory(
    String today,
    SharedPreferences prefs,
  ) async {
    try {
      await _repository.getHistory();
      final cups = await _repository.getWaterForDay(DateTime.now());
      if (cups <= 0) {
        return [];
      }

      final now = DateTime.now();
      final restored = List<DrinkRecord>.generate(
        cups,
        (index) => DrinkRecord(
          time: DateTime(now.year, now.month, now.day, 9, index),
          volumeMl: 250,
          type: DrinkType.allTypes.first,
        ),
      );

      await prefs.setString(
        'today_drinks_json',
        jsonEncode(restored.map((drink) => drink.toJson()).toList()),
      );
      await prefs.setString('water_last_date', today);
      return restored;
    } catch (e) {
      debugPrint("Water history restore error: $e");
      return [];
    }
  }
}
