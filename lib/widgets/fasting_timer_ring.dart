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
    final clampedPercent = percentComplete.clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 160.0,            // немного увеличенный радиус
      lineWidth: 20.0,          // толщина активного кольца
      backgroundWidth: 8.0,     // тонкое кольцо для фона
      percent: clampedPercent,
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 1200,
      startAngle: -90,          // начинаем сверху по часовой стрелке
      circularStrokeCap: CircularStrokeCap.round,
      // полу‑прозрачный фон, связанный с цветом прогресса
      backgroundColor: backgroundColor.withOpacity(0.08),
      // плавная ease‑out анимация
      curve: Curves.easeOutCubic,
      // градиент от светлого к насыщенному цвету прогресса
      linearGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          progressColor.withOpacity(0.2),
          progressColor.withOpacity(0.6),
          progressColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      // содержимое в центре кольца
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final isNewChild = (child.key == ValueKey<String>(title));
              final direction = isNewChild ? planChangeDirection : -planChangeDirection;
              final slideAnimation = Tween<Offset>(
                begin: Offset(direction.toDouble(), 0.0),
                end: Offset.zero,
              ).animate(animation);

              if (!isNewChild) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: Offset(-direction.toDouble(), 0.0),
                  ).animate(animation),
                  child: child,
                );
              }
              return SlideTransition(position: slideAnimation, child: child);
            },
            child: Text(
              title,
              key: ValueKey<String>(title),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: progressColor,
                shadows: [
                  Shadow(
                    color: progressColor.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          // Время (белое свечение)
          Text(
            timeElapsed,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: primaryTextColor.withOpacity(0.15),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Осталось времени
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
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