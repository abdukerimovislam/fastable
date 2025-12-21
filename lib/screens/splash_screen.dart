import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ИМПОРТЫ ---
// Убедитесь, что файлы лежат в папке lib/screens/
import 'package:fastable/home_page.dart';
import 'package:fastable/screens/login_screen.dart';
import 'package:fastable/screens/permissions_screen.dart'; // <-- Используем экран разрешений как Онбординг
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/widgets/mesh_background.dart';

// Ключ для проверки первого запуска
const String kFirstRunKey = 'is_first_run';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация логотипа
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Запуск проверки логики
    _checkFlow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFlow() async {
    // Ждем 2 секунды для красоты заставки
    final minWait = Future.delayed(const Duration(seconds: 2));
    final prefsFuture = SharedPreferences.getInstance();

    final List<dynamic> results = await Future.wait([minWait, prefsFuture]);
    final SharedPreferences prefs = results[1] as SharedPreferences;

    // Логика
    final bool isFirstRun = prefs.getBool(kFirstRunKey) ?? true;
    final user = AuthService().currentUser;

    if (!mounted) return;

    if (isFirstRun) {
      // 1. ПЕРВЫЙ ЗАПУСК -> Экран Разрешений
      _navigate(const PermissionsScreen());
    } else if (user == null) {
      // 2. НЕ ЗАЛОГИНЕН (редкий кейс, если анонимный вход не сработал) -> Логин
      _navigate(const LoginScreen());
    } else {
      // 3. ВСЕ ОК -> Главная
      _navigate(const HomePage());
    }
  }

  void _navigate(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      isFasting: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Текст
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      "FASTABLE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Master Your Metabolism",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}