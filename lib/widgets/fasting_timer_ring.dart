import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fastable/l10n/app_localizations.dart'; // <-- НУЖЕН ЭТОТ ИМПОРТ

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
    // Получаем l10n для хардкодной строки "Remaining:"
    final l10n = AppLocalizations.of(context)!;

    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 15.0,
      percent: percentComplete,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
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
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            timeElapsed,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            // --- ИСПРАВЛЕНИЕ ЗДЕСЬ ---
            "${l10n.remaining}: $timeRemaining", // Используем l10n.remaining
            // ---
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}