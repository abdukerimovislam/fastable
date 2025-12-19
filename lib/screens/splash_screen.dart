import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/screens/login_screen.dart';
import 'package:fastable/screens/onboarding_screen.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/widgets/mesh_background.dart';

// --- ИСПРАВЛЕНИЕ: Добавляем константу ---
const String kOnboardingCompleteKey = 'onboarding_complete';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkFlow();
  }

  Future<void> _checkFlow() async {
    // Имитация загрузки для красоты (1.5 сек)
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingDone = prefs.getBool(kOnboardingCompleteKey) ?? false;
    final user = AuthService().currentUser;

    if (!mounted) return;

    if (!onboardingDone) {
      // Если онбординг не пройден -> Идем на Онбординг
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else if (user == null) {
      // Если онбординг пройден, но не залогинен -> Логин
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      // Всё ок -> Главная
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      isFasting: true, // Теплый фон при запуске
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип (Иконка)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: Colors.orangeAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                    ]
                ),
                child: const Icon(Icons.bolt_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              // Название
              const Text(
                "FASTABLE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}