import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  const InitCoach(this.greeting);

  @override
  List<Object> get props => [greeting];
}

class SendCoachMessage extends CoachEvent {
  final String text;
  const SendCoachMessage(this.text);

  @override
  List<Object> get props => [text];
}

// --- STATE ---
class CoachMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const CoachMessage({required this.text, required this.isUser, required this.timestamp});
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
    // 1. Загружаем данные пользователя
    final prefs = await SharedPreferences.getInstance();
    final weight = prefs.getDouble('user_weight') ?? 70.0;
    final height = prefs.getDouble('user_height') ?? 170.0;
    final age = prefs.getInt('user_age') ?? 25;
    final genderIdx = prefs.getInt('user_gender') ?? 0;
    final gender = genderIdx == 0 ? "Male" : "Female";
    final activity = prefs.getString('user_activity') ?? 'Moderate';

    // 2. Инициализируем чат, передавая локализованное приветствие
    _aiService.startChat(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activity: activity,
      greeting: event.greeting, // <--- ИСПОЛЬЗУЕМ ТЕКСТ ИЗ EVENT
    );

    // 3. Добавляем приветствие в список сообщений
    final welcomeMsg = CoachMessage(
      text: event.greeting, // <--- ИСПОЛЬЗУЕМ ТЕКСТ ИЗ EVENT
      isUser: false,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(messages: [welcomeMsg]));
  }

  Future<void> _onSendMessage(SendCoachMessage event, Emitter<CoachState> emit) async {
    // Добавляем сообщение юзера
    final userMsg = CoachMessage(text: event.text, isUser: true, timestamp: DateTime.now());
    final newHistory = List<CoachMessage>.from(state.messages)..add(userMsg);

    emit(state.copyWith(messages: newHistory, isLoading: true, errorMessage: null));

    try {
      // Отправляем в AI
      final responseText = await _aiService.sendMessage(event.text);

      // Добавляем ответ AI
      final aiMsg = CoachMessage(text: responseText, isUser: false, timestamp: DateTime.now());
      final finalHistory = List<CoachMessage>.from(newHistory)..add(aiMsg);

      emit(state.copyWith(messages: finalHistory, isLoading: false));
    } catch (e) {
      // Если сервис вернул ошибку (например, нет ключа или интернета)
      // Мы добавляем системное сообщение об ошибке в чат или в state
      final errorMsg = CoachMessage(
        text: "Connection Error. Please check your internet.", // Тут можно оставить английский или прокидывать код ошибки
        isUser: false,
        timestamp: DateTime.now(),
      );

      final errorHistory = List<CoachMessage>.from(newHistory)..add(errorMsg);
      emit(state.copyWith(messages: errorHistory, isLoading: false));
    }
  }
}