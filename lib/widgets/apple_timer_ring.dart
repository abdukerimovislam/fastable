import 'dart:math';
import 'package:flutter/material.dart';

class AppleTimerRing extends StatelessWidget {
  final double percent;
  final Color activeColor;
  final Widget child;
  final double strokeWidth; // Новая настройка
  final bool isOpen; // Для режима "Спидометр"

  const AppleTimerRing({
    super.key,
    required this.percent,
    required this.activeColor,
    required this.child,
    this.strokeWidth = 20.0, // По умолчанию тоньше (было 30)
    this.isOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RingPainter(
          percent: percent,
          activeColor: activeColor,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade200,
          strokeWidth: strokeWidth,
          isOpen: isOpen,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;
  final bool isOpen;

  _RingPainter({
    required this.percent,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.isOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - (strokeWidth / 2);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Логика углов
    double startAngle = -pi / 2; // Сверху
    double totalSweep = 2 * pi; // Полный круг

    if (isOpen) {
      startAngle = 135 * (pi / 180); // Начинаем слева снизу
      totalSweep =
          270 * (pi / 180); // Заканчиваем справа снизу (оставляем низ открытым)
    }

    // 1. Рисуем фон
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // 2. Рисуем прогресс
    final currentSweep = totalSweep * percent;

    // Тень под прогрессом (для объема)
    if (percent > 0.01) {
      final shadowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawArc(
        Rect.fromCircle(center: center.translate(0, 4), radius: radius),
        startAngle,
        currentSweep,
        false,
        shadowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      progressPaint,
    );

    // 3. Рисуем Knob (наконечник)
    if (percent > 0.01) {
      final endAngle = startAngle + currentSweep;
      final knobX = center.dx + radius * cos(endAngle);
      final knobY = center.dy + radius * sin(endAngle);

      canvas.drawCircle(
        Offset(knobX, knobY),
        strokeWidth / 2, // Такой же диаметр как ширина линии
        Paint()..color = activeColor,
      );

      // Блик на наконечнике (белая точка)
      canvas.drawCircle(
        Offset(knobX, knobY),
        strokeWidth / 6,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
