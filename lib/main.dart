import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

import 'package:fastable/bloc/pro/pro_bloc.dart'; // <--- НОВЫЙ БЛОК
import 'package:fastable/bloc/pro/pro_event.dart';

// --- СЕРВИСЫ ---
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/auth_service.dart';

// --- ЭКРАНЫ ---
import 'package:fastable/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();

  // Инициализация уведомлений
  await getIt<NotificationService>().init();

  // Авто-вход
  final auth = getIt<AuthService>();
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint("Auth Error: $e");
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
        // Settings & Pro
        BlocProvider(create: (_) => getIt<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(create: (_) => getIt<ProBloc>()..add(CheckProStatus())), // Проверяем подписку

        // Core Features
        BlocProvider(create: (_) => getIt<FastingBloc>()..add(CheckFastingState())),
        BlocProvider(create: (_) => getIt<WaterBloc>()..add(LoadWaterData())),
        BlocProvider(create: (_) => getIt<WeightBloc>()..add(LoadWeightData())),

        // Data
        BlocProvider(create: (_) => getIt<HistoryBloc>()..add(SubscribeHistory())),
        BlocProvider(create: (_) => getIt<StatsBloc>()..add(LoadStats())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Fastable',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,

            locale: settingsState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}