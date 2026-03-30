import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/core/app_prefs_keys.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/services/auth_service.dart';

import 'package:fastable/screens/onboarding_screen.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _windController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _windController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _mainController.forward();
    _checkState();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _windController.dispose();
    super.dispose();
  }

  Future<void> _checkState() async {
    // 1. Запускаем таймер красивой анимации (минимум 3 секунды)
    final minSplashDuration = Future.delayed(
      const Duration(milliseconds: 3000),
    );

    // 2. 🔥 ИСПРАВЛЕНИЕ: Гарантируем, что юзер авторизован до входа в приложение
    final authService = getIt<AuthService>();
    if (authService.currentUser == null) {
      try {
        await authService.signInAnonymously();
      } catch (e) {
        debugPrint("Splash auth error: $e");
        // В случае критической ошибки сети мы все равно пустим юзера дальше,
        // Firebase Auth умеет кэшировать запросы при оффлайне.
      }
    }

    // 3. Ждем окончания анимации (если логин прошел быстрее 3 секунд)
    await minSplashDuration;

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool(AppPrefsKeys.onboardingComplete) ?? false;

    if (mounted) {
      if (seenOnboarding) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Получаем локализацию
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. ФОН
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1A2634), Color(0xFF000000)],
              ),
            ),
          ),

          // 2. ВЕТЕР
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _windController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WindPainter(animationValue: _windController.value),
                );
              },
            ),
          ),

          // 3. КОНТЕНТ
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ИКОНКА
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF00D2FF,
                            ).withValues(alpha: 0.25),
                            blurRadius: 100,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ТЕКСТ
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // 🔥 Название из локализации
                        Text(
                          l10n.appNameUpper,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 🔥 Слоган из локализации
                        Text(
                          l10n.splashSlogan,
                          style: TextStyle(
                            color: Colors.blueAccent.shade100.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 14,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Рисовальщик ветра
class WindPainter extends CustomPainter {
  final double animationValue;

  WindPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawWindLine(
      canvas,
      size,
      paint,
      yFactor: 0.25,
      speed: 0.5,
      opacity: 0.03,
      width: 2,
    );
    _drawWindLine(
      canvas,
      size,
      paint,
      yFactor: 0.45,
      speed: 0.8,
      opacity: 0.05,
      width: 1.5,
    );
    _drawWindLine(
      canvas,
      size,
      paint,
      yFactor: 0.60,
      speed: 0.6,
      opacity: 0.04,
      width: 3,
    );
    _drawWindLine(
      canvas,
      size,
      paint,
      yFactor: 0.85,
      speed: 1.0,
      opacity: 0.02,
      width: 2,
    );
  }

  void _drawWindLine(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double yFactor,
    required double speed,
    required double opacity,
    required double width,
  }) {
    paint.color = Colors.cyanAccent.withValues(alpha: opacity);
    paint.strokeWidth = width;

    final path = Path();
    final double xOffset = size.width * 2 * animationValue * speed;
    double startX = -size.width + (xOffset % (size.width * 2));
    final double baseY = size.height * yFactor;

    path.moveTo(startX, baseY);

    for (double i = 0; i < size.width * 1.5; i += 20) {
      path.lineTo(startX + i, baseY + 15 * math.sin((startX + i) * 0.015));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WindPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
