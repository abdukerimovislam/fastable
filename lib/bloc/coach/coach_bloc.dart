import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/services/ai_service.dart';

// --- EVENTS ---
abstract class CoachEvent extends Equatable {
  const CoachEvent();
  @override
  List<Object> get props => [];
}

// 1. ИЗМЕНЕНИЕ: Событие теперь принимает локализованное приветствие
class InitCoach extends CoachEvent {
  final String greeting;
  final String profileContext;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activity;
  const InitCoach({
    required this.greeting,
    required this.profileContext,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activity,
  });

  @override
  List<Object> get props => [
    greeting,
    profileContext,
    weight,
    height,
    age,
    gender,
    activity,
  ];
}

class SendCoachMessage extends CoachEvent {
  final String text;
  final String errorFallbackText;
  const SendCoachMessage(this.text, this.errorFallbackText);

  @override
  List<Object> get props => [text, errorFallbackText];
}

// --- STATE ---
class CoachMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const CoachMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  @override
  List<Object> get props => [text, isUser, timestamp];
}

class CoachState extends Equatable {
  final List<CoachMessage> messages;
  final bool isLoading;
  // Добавим поле ошибки, чтобы UI мог показать снекбар или сообщение
  final String? errorMessage;

  const CoachState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CoachState copyWith({
    List<CoachMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoachState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // null сбросит ошибку
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
}

// --- BLOC ---
@injectable
class CoachBloc extends Bloc<CoachEvent, CoachState> {
  final AiService _aiService;

  CoachBloc(this._aiService) : super(const CoachState()) {
    on<InitCoach>(_onInit);
    on<SendCoachMessage>(_onSendMessage);
  }

  Future<void> _onInit(InitCoach event, Emitter<CoachState> emit) async {
    // 1. Инициализируем чат актуальными данными из реактивного state
    _aiService.startChat(
      weight: event.weight,
      height: event.height,
      age: event.age,
      gender: event.gender,
      activity: event.activity,
      greeting: event.greeting,
      profileContext: event.profileContext,
    );

    // 2. Добавляем приветствие в список сообщений
    final welcomeMsg = CoachMessage(
      text: event.greeting,
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(messages: [welcomeMsg]));
  }

  Future<void> _onSendMessage(
    SendCoachMessage event,
    Emitter<CoachState> emit,
  ) async {
    // Добавляем сообщение юзера
    final userMsg = CoachMessage(
      text: event.text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final newHistory = List<CoachMessage>.from(state.messages)..add(userMsg);

    emit(
      state.copyWith(messages: newHistory, isLoading: true, errorMessage: null),
    );

    try {
      // Отправляем в AI
      final responseText = await _aiService.sendMessage(event.text);

      // Добавляем ответ AI
      final aiMsg = CoachMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      final finalHistory = List<CoachMessage>.from(newHistory)..add(aiMsg);

      emit(state.copyWith(messages: finalHistory, isLoading: false));
    } catch (e) {
      final errorMsg = CoachMessage(
        text: event.errorFallbackText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final errorHistory = List<CoachMessage>.from(newHistory)..add(errorMsg);
      emit(state.copyWith(messages: errorHistory, isLoading: false));
    }
  }
}
