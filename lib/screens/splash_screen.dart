import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ИМПОРТЫ
import 'package:fastable/home_page.dart';
import 'package:fastable/screens/login_screen.dart';
import 'package:fastable/screens/permissions_screen.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/widgets/mesh_background.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    _checkFlow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFlow() async {
    // 1. Ждем анимацию (минимум 2 сек)
    final minWait = Future.delayed(const Duration(seconds: 2));

    // 2. Ждем готовности Firebase Auth (если это анонимный вход при старте)
    // Если юзера нет, пробуем подождать 1-2 сек, вдруг main.dart еще создает его
    if (AuthService().currentUser == null) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final prefs = await SharedPreferences.getInstance();

    await minWait; // Гарантируем, что анимация прошла

    final bool isFirstRun = prefs.getBool(kFirstRunKey) ?? true;
    final user = AuthService().currentUser;

    if (!mounted) return;

    if (isFirstRun) {
      // Первый запуск -> Экран разрешений
      _navigate(const PermissionsScreen());
    } else {
      // Не первый запуск.
      // Если юзер есть (даже аноним) -> Главная.
      // Если юзера нет совсем (вышел из аккаунта) -> Логин.
      if (user != null) {
        _navigate(const HomePage());
      } else {
        _navigate(const LoginScreen());
      }
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
                        BoxShadow(color: Colors.orangeAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.bolt_rounded, size: 70, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text("FASTABLE", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 6, fontFamily: 'SF Pro Display')),
                    const SizedBox(height: 8),
                    Text("Master Your Metabolism", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, letterSpacing: 1.2)),
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