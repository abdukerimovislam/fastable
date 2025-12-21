import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- НУЖЕН ДЛЯ ПРОВЕРКИ ПЕРВОГО ЗАПУСКА
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
import 'package:fastable/screens/permissions_screen.dart'; // <-- ЭКРАН РАЗРЕШЕНИЙ
import 'package:fastable/home_page.dart'; // <-- ГЛАВНЫЙ ЭКРАН (проверьте путь, если он в screens/)
// import 'package:fastable/screens/splash_screen.dart'; // Можно временно убрать или использовать как заставку

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

  // --- НОВЫЕ ОБНОВЛЕНИЯ (AUTH & ONBOARDING) ---

  // 4. Авто-вход для Гостя (Анонимно)
  // Это создает UID в Firebase, чтобы данные сохранялись сразу
  if (AuthService().currentUser == null) {
    await AuthService().signInAnonymously();
  }

  // 5. Проверка: Первый ли это запуск?
  final prefs = await SharedPreferences.getInstance();
  // Если ключа нет (первый раз), вернет true
  final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  // Запускаем приложение и передаем флаг isFirstRun
  runApp(MyApp(isFirstRun: isFirstRun));
}

class MyApp extends StatelessWidget {
  final bool isFirstRun; // Поле для хранения статуса

  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    // Слушаем изменения языка
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService().localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Fastable',
          debugShowCheckedModeBanner: false, // Убираем ленточку DEBUG

          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // --- ЯЗЫКОВЫЕ НАСТРОЙКИ ---
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // --------------------------

          // --- ЛОГИКА НАВИГАЦИИ ---
          // Если это первый запуск -> показываем Onboarding (PermissionsScreen)
          // Если уже пользовались -> сразу на Главную (HomePage)
          home: isFirstRun ? const PermissionsScreen() : const HomePage(),
        );
      },
    );
  }
}