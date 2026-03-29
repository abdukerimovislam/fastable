import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart'; // Для форматирования дней недели
import 'package:fastable/services/ai_service.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/weight_repository.dart';

// --- EVENTS ---
abstract class InsightEvent extends Equatable {
  const InsightEvent();
  @override
  List<Object> get props => [];
}

class FetchDailyInsight extends InsightEvent {
  final String fallbackText;
  final String notEnoughDataText;
  final String languageCode;

  const FetchDailyInsight({
    required this.fallbackText,
    required this.notEnoughDataText,
    required this.languageCode,
  });

  @override
  List<Object> get props => [fallbackText, notEnoughDataText, languageCode];
}

// --- STATE ---
abstract class InsightState extends Equatable {
  const InsightState();
  @override
  List<Object> get props => [];
}

class InsightInitial extends InsightState {}

class InsightLoading extends InsightState {}

class InsightLoaded extends InsightState {
  final String text;
  const InsightLoaded(this.text);
  @override
  List<Object> get props => [text];
}

class InsightError extends InsightState {
  final String message;
  const InsightError(this.message);
}

// --- BLOC ---
@injectable
class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final WeightRepository _weightRepository;

  InsightBloc(this._aiService, this._historyRepository, this._weightRepository)
    : super(InsightInitial()) {
    on<FetchDailyInsight>(_onFetch);
  }

  Future<void> _onFetch(
    FetchDailyInsight event,
    Emitter<InsightState> emit,
  ) async {
    // ⚠️ ВАЖНО: Мы убрали проверку (state is InsightLoaded),
    // чтобы при добавлении новых записей инсайт обновлялся сразу,
    // а не висел старый "Мало данных".

    emit(InsightLoading());

    try {
      // 1. ПОЛУЧЕНИЕ ИСТОРИИ ГОЛОДАНИЯ
      final allRecords = await _historyRepository.getAllRecords();

      // 🛑 ПРОВЕРКА: Если записей < 3, показываем сообщение и выходим.
      // API Gemini НЕ вызываем.
      if (allRecords.length < 3) {
        emit(InsightLoaded(event.notEnoughDataText));
        return;
      }

      // 2. ПОЛУЧЕНИЕ ВЕСА
      double currentWeight = 0.0;
      double startWeight = 0.0;

      try {
        final weightHistory = await _weightRepository.getWeightHistory();
        if (weightHistory.isNotEmpty) {
          // Твой репо сортирует от старых к новым:
          startWeight = weightHistory.first.weight; // Самая старая запись
          currentWeight = weightHistory.last.weight; // Самая свежая запись
        }
      } catch (e) {
        // Если ошибка веса, не ломаем блок, просто данные будут 0.0
        debugPrint("⚠️ InsightBloc: Ошибка получения веса: $e");
      }

      // 3. ПОДГОТОВКА ДАННЫХ ДЛЯ AI
      // Берем последние 7 записей
      final recentRecords = allRecords.take(7);

      final List<Map<String, dynamic>> historyData = recentRecords.map((
        record,
      ) {
        return {
          'day': DateFormat('E').format(record.endTime), // "Mon", "Tue"...
          'hours': record.duration.inHours,
          'mood': record.mood?.name ?? 'Neutral',
        };
      }).toList();

      // Разворачиваем для хронологического порядка (нужно для AI анализа трендов)
      final sortedHistory = historyData.reversed.toList();

      // 4. ЗАПРОС К AI
      final insightText = await _aiService.generatePersonalizedInsight(
        historyData: sortedHistory,
        currentWeight: currentWeight,
        startWeight: startWeight,
        userName: "Champion",
        languageCode: event.languageCode,
        fallbackText: event.fallbackText,
      );

      emit(InsightLoaded(insightText));
    } catch (e) {
      // При любой ошибке (сети, API) показываем fallback
      emit(InsightLoaded(event.fallbackText));
    }
  }
}
