import 'package:firebase_remote_config/firebase_remote_config.dart'; // 🔥 Импорт
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

@lazySingleton
class AiService {
  late final GenerativeModel _model;
  ChatSession? _chat;

  // Имя параметра в Firebase Console
  static const String _remoteConfigKey = 'ai_api_key';

  static const String _modelName = 'gemini-2.5-flash';

  AiService() {
    _initModel();
  }

  void _initModel() {
    // 1. 🔥 Берем ключ из Remote Config (который скачался в main.dart)
    final apiKey = FirebaseRemoteConfig.instance.getString(_remoteConfigKey);

    // Проверка: если ключа нет или он дефолтный
    if (apiKey.isNotEmpty && apiKey != 'default_value_if_offline') {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 800,
        ),
      );
      debugPrint('✅ AI Service initialized with Remote Config key.');
    } else {
      debugPrint('⚠️ AI Service Warning: Key not found in Remote Config. AI will be disabled.');
    }
  }

  /// --- ЧАТ (AI COACH) ---
  void startChat({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activity,
    required String greeting,
  }) {
    // Проверяем, инициализирована ли модель
    if (!_isModelReady()) return;

    final systemPrompt = Content.text('''
      You are "Fasty", a professional Intermittent Fasting & Keto Diet Coach.
      USER PROFILE: Weight: $weight kg, Height: $height cm, Age: $age, Gender: $gender, Activity: $activity
      GUIDELINES:
      1. Keep answers concise (max 3-4 sentences).
      2. Be motivating and friendly. Use emojis: 🥑🔥💧.
      3. Never give medical advice.
      4. Language: Detect and answer in the user's language.
    ''');

    try {
      _chat = _model.startChat(history: [
        systemPrompt,
        Content.model([TextPart(greeting)]),
      ]);
    } catch (e) {
      debugPrint('❌ Error starting chat: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    // 🔥 Если модель не готова (ключ не пришел), пробуем инициализировать снова
    if (!_isModelReady()) {
      _initModel(); // Попытка переинициализации (вдруг конфиг долетел)
      if (!_isModelReady()) {
        return "AI is updating configuration. Please check internet and restart app.";
      }
    }

    if (_chat == null) {
      startChat(
        weight: 70, height: 170, age: 25,
        gender: 'User', activity: 'Moderate',
        greeting: 'Hello',
      );
    }

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final text = response.text;
      return (text == null || text.isEmpty) ? "I'm thinking... (Empty response)" : text;
    } catch (e) {
      debugPrint('❌ AI Connection Error: $e');
      return "Connection error. Please try again later.";
    }
  }

  /// --- ИНСАЙТЫ ---
  Future<String> generatePersonalizedInsight({
    required List<Map<String, dynamic>> historyData,
    required double currentWeight,
    required double startWeight,
    required String userName,
    required String languageCode,
    required String fallbackText,
  }) async {
    if (!_isModelReady()) return fallbackText;

    final historyString = historyData.map((e) => "${e['day']}: ${e['hours']}h (Mood: ${e['mood']})").join(", ");
    final trend = (startWeight - currentWeight) > 0 ? "Lost" : "Stable/Gained";

    final prompt = '''
      Act as a Fasting Coach. Analyze: [$historyString]. Weight trend: $trend.
      Generate ONE insightful, actionable sentence (max 25 words) in $languageCode.
      Look for patterns: Weekend slip-ups, Mood correlation, Consistency streak.
      Use emojis.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? fallbackText;
    } catch (e) {
      return fallbackText;
    }
  }

  // Вспомогательный метод проверки
  bool _isModelReady() {
    try {
      // Пытаемся обратиться к переменной. Если она не инициализирована, выбросит ошибку
      _model;
      return true;
    } catch (e) {
      return false;
    }
  }
}