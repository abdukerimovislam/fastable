import 'package:fastable/utils/logger.dart';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';

// --- СЕРВИСЫ ---
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/services/live_activity_services.dart';
import 'package:fastable/services/pro_service.dart';

// --- ЭКРАНЫ ---
import 'package:fastable/screens/splash_screen.dart';

Future<void> main() async {
  // 1. Обязательная инициализация движка Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 🔥 ИСПРАВЛЕНИЕ: Инициализация данных локали ДО отрисовки UI (предотвращает крэш LocaleDataException)
  await initializeDateFormatting();

  // 2. 🔥 Фиксируем портретную ориентацию (чтобы не ломать верстку)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. 🔥 Настраиваем стиль статус-бара (прозрачный для Edge-to-Edge)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Прозрачный статус бар
      statusBarIconBrightness:
          Brightness.light, // Белые иконки (для темной темы)
      systemNavigationBarColor: Colors.black, // Черная полоска навигации снизу
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 4. 🔥 Инициализация Firebase (ДО внедрения зависимостей)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 5. 🔥 Инициализация Remote Config (Безопасная загрузка ключей)
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(
          seconds: 10,
        ), // Безопасный таймаут для самого пакета
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );

    // Устанавливаем дефолтное значение (если нет интернета)
    await remoteConfig.setDefaults(const {
      "ai_api_key": "default_value_if_offline",
    });

    // Ограничиваем ожидание сети ровно 2 секундами.
    // Если интернет очень медленный, мы просто перейдем к запуску UI с дефолтными значениями.
    remoteConfig.fetchAndActivate().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        appLog(
          "⚠️ Remote Config fetch timeout. App proceeding with defaults.",
        );
        return false;
      },
    ).then((_) => appLog("✅ Remote Config ready"))
     .catchError((e) {
      appLog("⚠️ Remote Config fetch failed: $e");
    });
  } catch (e) {
    appLog("⚠️ Remote Config setup failed: $e");
  }

  // 6. Внедрение зависимостей (GetIt)
  await configureDependencies();

  // 7. Инициализация подписок единым путем через сервис
  getIt<ProService>().init().catchError((e) {
    appLog("RevenueCat Init Error: $e");
  });

  // 8. Инициализация рекламы (фоном)
  MobileAds.instance.initialize();

  // 9. Инициализация уведомлений и live activities
  getIt<NotificationService>().init().catchError((e) {
    appLog("Notification Init Error: $e");
  });
  getIt<LiveActivityService>().init().catchError((e) {
    appLog("Live Activity Init Error: $e");
  });

  // 10. Авто-вход (Анонимный)
  final auth = getIt<AuthService>();
  if (auth.currentUser == null) {
    appLog("🚀 Attempting anonymous sign-in...");
    // Убрали 'await'. Теперь авторизация идет в фоне.
    // Это моментально разблокирует запуск runApp и предотвратит ANR.
    auth.signInAnonymously().catchError((e) {
      appLog("❌ Auth Error during background sign-in: $e");
      return null;
    });
  }

  // 12. 🔥 Crashlytics: Перехватываем ошибки Flutter UI layer
  // В debug отключаем отправку, чтобы не засорять дашборд
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  // 13. 🔥 Crashlytics: Перехватываем асинхронные/нативные ошибки через PlatformDispatcher
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. Настройки и Подписка (Базовые)
        BlocProvider(create: (_) => getIt<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (_) => getIt<ProBloc>()..add(CheckProStatus())),

        // 2. Основной функционал (Трекеры)
        BlocProvider(
          create: (_) => getIt<FastingBloc>()..add(CheckFastingState()),
        ),
        BlocProvider(create: (_) => getIt<WaterBloc>()..add(LoadWaterData())),
        BlocProvider(create: (_) => getIt<WeightBloc>()..add(LoadWeightData())),

        // 3. Данные и Статистика
        BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(SubscribeHistory()),
        ),
        BlocProvider(create: (_) => getIt<StatsBloc>()..add(LoadStats())),
        BlocProvider(create: (_) => OnboardingProfileCubit()..load()),
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
