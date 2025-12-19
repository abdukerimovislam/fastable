import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/auth_service.dart'; // Возможно, у вас есть этот импорт
import 'package:fastable/screens/splash_screen.dart';
import 'package:fastable/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fastable/services/locale_service.dart'; // <-- НОВЫЙ ИМПОРТ
import 'package:google_mobile_ads/google_mobile_ads.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Инициализация Рекламы (ОБЯЗАТЕЛЬНО!)
  await MobileAds.instance.initialize(); // <-- ЭТОЙ СТРОКИ НЕ ХВАТАЛО

  // 3. Инициализация сервисов
  await NotificationService().init();
  await LocaleService().loadLocale();

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
          title: 'Fastable', // Обновленное название

          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // --- ЯЗЫКОВЫЕ НАСТРОЙКИ ---
          locale: locale, // <-- ПРИНУДИТЕЛЬНО УСТАНАВЛИВАЕМ ЯЗЫК
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // --------------------------

          home: const SplashScreen(),
        );
      },
    );
  }
}