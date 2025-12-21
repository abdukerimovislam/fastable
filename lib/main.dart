import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fastable/app_theme.dart';
import 'firebase_options.dart';

// --- ЛОКАЛИЗАЦИЯ И СЕРВИСЫ ---
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/services/locale_service.dart';

// --- ЭКРАНЫ ---
import 'package:fastable/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Инициализация Рекламы
  await MobileAds.instance.initialize();

  // 3. Инициализация сервисов
  await NotificationService().init();
  await LocaleService().loadLocale();

  // 4. Авто-вход для Гостя (Анонимно) - чтобы создался UID в базе
  if (AuthService().currentUser == null) {
    try {
      await AuthService().signInAnonymously();
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
    // Слушаем изменения языка
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService().localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Fastable',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // --- ЯЗЫКОВЫЕ НАСТРОЙКИ ---
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // --- ГЛАВНАЯ ТОЧКА ВХОДА ---
          // SplashScreen сам проверит, первый ли это запуск
          home: const SplashScreen(),
        );
      },
    );
  }
}