import 'package:fastable/utils/logger.dart';
import 'dart:ui';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';

@lazySingleton
class AiService {
  // 🔥 ИСПРАВЛЕНИЕ 1: Безопасный nullable вместо опасного late final
  GenerativeModel? _model;
  ChatSession? _chat;

  static const String _remoteConfigKey = 'ai_api_key';
  static const String _modelName = 'gemini-2.5-flash';

  AiService() {
    _initModel();
  }

  void _initModel() {
    final apiKey = FirebaseRemoteConfig.instance.getString(_remoteConfigKey);

    if (apiKey.isNotEmpty && apiKey != 'default_value_if_offline') {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 800,
        ),
      );
      appLog('✅ AI Service initialized with Remote Config key.');
    } else {
      appLog(
        '⚠️ AI Service Warning: Key not found in Remote Config. AI disabled.',
      );
    }
  }

  bool _isModelReady() => _model != null;

  /// --- ЧАТ (AI COACH) ---
  void startChat({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activity,
    required String greeting,
    required String profileContext,
  }) {
    if (!_isModelReady()) return;

    final systemPrompt = Content.text('''
      You are "Fasty", a professional Intermittent Fasting & Keto Diet Coach.
      USER PROFILE: Weight: $weight kg, Height: $height cm, Age: $age, Gender: $gender, Activity: $activity
      ONBOARDING CONTEXT: $profileContext
      GUIDELINES:
      1. Keep answers concise (max 3-4 sentences).
      2. Be motivating and friendly. Use emojis: 🥑🔥💧.
      3. Never give medical advice.
      4. Language: Detect and answer in the user's language.
    ''');

    try {
      _chat = _model!.startChat(
        history: [
          systemPrompt,
          Content.model([TextPart(greeting)]),
        ],
      );
    } catch (e) {
      appLog('❌ Error starting chat: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    final l10n = await _loadAppLocalizations();

    if (!_isModelReady()) {
      _initModel();
      if (!_isModelReady()) {
        return l10n.aiUpdatingConfig;
      }
    }

    // 🔥 ИСПРАВЛЕНИЕ 2: Запрещаем слать сообщения от "dummy" юзера.
    if (_chat == null) {
      return l10n.aiSessionExpired;
    }

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final text = response.text;
      return (text == null || text.isEmpty) ? l10n.aiEmptyResponse : text;
    } catch (e) {
      appLog('❌ AI Connection Error: $e');
      return l10n.aiConnectionError;
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

    final historyString = historyData
        .map((e) => "${e['day']}: ${e['hours']}h (Mood: ${e['mood']})")
        .join(", ");
    final trend = (startWeight - currentWeight) > 0 ? "Lost" : "Stable/Gained";

    final prompt =
        '''
      Act as a Fasting Coach. Analyze: [$historyString]. Weight trend: $trend.
      Generate ONE insightful, actionable sentence (max 25 words) in $languageCode.
      Look for patterns: Weekend slip-ups, Mood correlation, Consistency streak.
      Use emojis.
    ''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? fallbackText;
    } catch (e) {
      return fallbackText;
    }
  }

  Future<AppLocalizations> _loadAppLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale_code') ?? 'en';
    return lookupAppLocalizations(Locale(languageCode));
  }
}
