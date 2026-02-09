import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🔥 Для настройки статус-бара и ориентации
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'; // 🔥 Импорт Remote Config
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/app_theme.dart';
import 'package:fastable/injection.dart';
import 'firebase_options.dart';

// --- БЛОКИ ---
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';

import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';

import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';

import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';

import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_event.dart';

import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';

// --- СЕРВИСЫ ---
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/auth_service.dart';

// --- ЭКРАНЫ ---
import 'package:fastable/screens/splash_screen.dart';

Future<void> main() async {
  // 1. Обязательная инициализация движка Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🔥 Фиксируем портретную ориентацию (чтобы не ломать верстку)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. 🔥 Настраиваем стиль статус-бара (прозрачный для Edge-to-Edge)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Прозрачный статус бар
    statusBarIconBrightness: Brightness.light, // Белые иконки (для темной темы)
    systemNavigationBarColor: Colors.black, // Черная полоска навигации снизу
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // 4. 🔥 Инициализация Firebase (ДО внедрения зависимостей)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. 🔥 Инициализация Remote Config (Безопасная загрузка ключей)
  // Это нужно сделать ДО configureDependencies, чтобы сервисы могли прочитать конфиг
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1), // Таймаут соединения
      minimumFetchInterval: const Duration(hours: 12), // В РЕЛИЗЕ: 12 часов (чтобы не превысить лимиты)
      // minimumFetchInterval: const Duration(minutes: 1), // ДЛЯ ТЕСТОВ: 1 минута
    ));

    // Устанавливаем дефолтное значение (если нет интернета)
    await remoteConfig.setDefaults(const {
      "ai_api_key": "default_value_if_offline",
    });

    // Скачиваем актуальные данные с сервера
    await remoteConfig.fetchAndActivate();
    debugPrint("✅ Remote Config fetched successfully");
  } catch (e) {
    debugPrint("⚠️ Remote Config fetch failed: $e");
    // Приложение продолжит работать, просто AI может быть недоступен
  }

  // 6. Внедрение зависимостей (GetIt)
  await configureDependencies();

  // 7. Инициализация рекламы (фоном)
  MobileAds.instance.initialize();

  // 8. Инициализация уведомлений
  try {
    await getIt<NotificationService>().init();
  } catch (e) {
    debugPrint("Notification Init Error: $e");
  }

  // 9. Авто-вход (Анонимный)
  final auth = getIt<AuthService>();
  if (auth.currentUser == null) {
    try {
      debugPrint("🚀 Attempting anonymous sign-in...");
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint("❌ Auth Error: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. Настройки и Подписка (Базовые)
        BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider(
          create: (_) => getIt<ProBloc>()..add(CheckProStatus()),
        ),

        // 2. Основной функционал (Трекеры)
        BlocProvider(
          create: (_) => getIt<FastingBloc>()..add(CheckFastingState()),
        ),
        BlocProvider(
          create: (_) => getIt<WaterBloc>()..add(LoadWaterData()),
        ),
        BlocProvider(
          create: (_) => getIt<WeightBloc>()..add(LoadWeightData()),
        ),

        // 3. Данные и Статистика
        BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(SubscribeHistory()),
        ),
        BlocProvider(
          create: (_) => getIt<StatsBloc>()..add(LoadStats()),
        ),
      ],
      // Слушаем настройки, чтобы менять тему и язык на лету
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Fastable', // Название приложения в "недавних"
            debugShowCheckedModeBanner: false, // Убираем ленточку DEBUG

            // --- ТЕМЫ ---
            theme: AppTheme.darkTheme, // Дефолтная (или светлая, если есть)
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode, // Переключение темы

            // --- ЛОКАЛИЗАЦИЯ ---
            locale: settingsState.locale, // Текущий язык из настроек
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // --- ГЛАВНЫЙ ЭКРАН ---
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}