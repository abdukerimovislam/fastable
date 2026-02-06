import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AiService {
  late final GenerativeModel _model;
  ChatSession? _chat;

  // 🔒 БЕЗОПАСНОСТЬ: Ключ берется из аргументов сборки (--dart-define)
  static const String _apiKey = String.fromEnvironment('GEMINI_KEY');

  AiService() {
    // Проверяем ключ. Если его нет, модель не инициализируем (обработаем в методах)
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7, // Чуть строже, чтобы аналитика была точной
          maxOutputTokens: 800,
        ),
      );
    } else {
      print('⚠️ WARNING: GEMINI_KEY is missing. Run with --dart-define=GEMINI_KEY=...');
    }
  }

  // --- ЧАТ (AI COACH) ---
  // Этот блок не менялся, он работает отлично для чата

  void startChat({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activity,
    required String greeting,
  }) {
    if (_apiKey.isEmpty) return;

    final systemPrompt = Content.text('''
      You are "Fasty", a professional Intermittent Fasting & Keto Diet Coach.
      
      USER PROFILE:
      - Weight: $weight kg, Height: $height cm
      - Age: $age, Gender: $gender, Activity: $activity
      
      GUIDELINES:
      1. Keep answers concise (max 3-4 sentences).
      2. Be motivating and friendly. Use emojis: 🥑🔥💧.
      3. For weight loss questions, refer to the user's current stats.
      4. MEDICAL DISCLAIMER: Never give medical advice. If asked about symptoms, strictly advise consulting a doctor.
      5. Language: Detect and answer in the user's language.
      6. Scope: Fasting, Keto, Hydration, Wellness only.
    ''');

    _chat = _model.startChat(history: [
      systemPrompt,
      Content.model([TextPart(greeting)]),
    ]);
  }

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      throw Exception('Missing API Key');
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
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response');
      }
      return response.text!;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // --- ГЛУБОКИЕ ИНСАЙТЫ (DASHBOARD) ---

  /// Генерирует аналитический инсайт на основе паттернов
  Future<String> generatePersonalizedInsight({
    required List<Map<String, dynamic>> historyData, // <--- Сложная структура (День, Часы, Муд)
    required double currentWeight,
    required double startWeight,
    required String userName,
    required String languageCode, // 'en', 'ru'
    required String fallbackText, // Локализованная заглушка
  }) async {
    // 1. Проверка ключа
    if (_apiKey.isEmpty) {
      print('AiService: Missing API Key for insights');
      return fallbackText;
    }

    // 2. Форматируем историю для промпта
    // Превращаем [{"day": "Mon", "hours": 16, "mood": "Good"}] в читаемый текст
    final historyString = historyData.map((e) {
      return "${e['day']}: ${e['hours']}h (Mood: ${e['mood']})";
    }).join(", ");

    final weightChange = startWeight - currentWeight;
    final trend = weightChange > 0 ? "Lost ${weightChange.toStringAsFixed(1)}kg" : "Stable/Gained";

    final dataContext = '''
      User History (Last 7 days): [$historyString]
      Current Weight: $currentWeight kg ($trend)
      Language: $languageCode
    ''';

    // 3. ПРОМПТ "DATA SCIENTIST"
    final prompt = '''
      Act as an advanced Data Scientist and Fasting Coach. Analyze the user data ($dataContext).
      Find a HIDDEN CORRELATION and generate ONE insightful, actionable sentence (max 25 words).

      Look for these specific patterns:
      1. [WEEKEND EFFECT] Do fasts get shorter on Fri/Sat/Sun? If yes, advise on social eating.
      2. [MOOD CONNECTION] Does "Bad/Terrible" mood correlate with short fasts? If yes, mention emotional triggers.
      3. [METABOLIC ADAPTATION] If fasts are exactly the same length every day but weight is stuck, suggest changing the schedule (e.g., "Shock your body with a 18h fast").
      4. [LATE EATER] If fasts are consistently short (<12h), gently ask if they eat too late.
      5. [WINNING STREAK] If consistency is perfect (>16h every day), calculate the streak and celebrate.

      Rules:
      - Be specific. Don't say "Drink water". Say "Your Saturday fasts are short; try prepping keto snacks."
      - Use emojis 📊🧠🥑.
      - Answer STRICTLY in language: $languageCode.
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? fallbackText;
    } catch (e) {
      print('AiService Error: $e');
      return fallbackText;
    }
  }
}