import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fastable/l10n/app_localizations.dart';

class FastingTimerRing extends StatelessWidget {
  final double percentComplete;
  final String timeElapsed;
  final String timeRemaining;
  final String title;
  final int planChangeDirection;
  final Color progressColor;
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const FastingTimerRing({
    super.key,
    required this.percentComplete,
    required this.timeElapsed,
    required this.timeRemaining,
    required this.title,
    required this.planChangeDirection,
    this.progressColor = Colors.blueAccent,
    required this.backgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 16.0, // Чуть толще для премиальности
      percent: percentComplete,
      backgroundColor: backgroundColor.withOpacity(0.05), // Менее заметный фон кольца
      // 🔥 ГРАДИЕНТ ДЛЯ КОЛЬЦА
      linearGradient: LinearGradient(
        colors: [
          progressColor.withOpacity(0.4),
          progressColor,
          progressColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.7, 1.0],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 1000,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final bool isNewChild = (child.key == ValueKey<String>(title));
              final int direction = isNewChild ? planChangeDirection : -planChangeDirection;
              final slideAnimation = Tween<Offset>(
                begin: Offset(direction.toDouble(), 0.0),
                end: const Offset(0.0, 0.0),
              ).animate(animation);

              if (!isNewChild) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.0),
                    end: Offset(-direction.toDouble(), 0.0),
                  ).animate(animation),
                  child: child,
                );
              }
              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            },
            child: Text(
              title,
              key: ValueKey<String>(title),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: progressColor, // Цвет текста теперь совпадает с кольцом!
                shadows: [Shadow(color: progressColor.withOpacity(0.5), blurRadius: 10)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // ВРЕМЯ (Светящееся)
          Text(
            timeElapsed,
            style: TextStyle(
              fontSize: 42, // Крупнее
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
              shadows: [Shadow(color: Colors.white.withOpacity(0.2), blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 8),
          // ОСТАЛОСЬ ВРЕМЕНИ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${l10n.remaining}: $timeRemaining",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}