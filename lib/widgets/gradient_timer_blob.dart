import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class GradientTimerBlob extends StatefulWidget {
  final double percent;
  final bool isFasting;
  final List<Color>? colors; // 🔥 ДОБАВЛЕНО: Теперь он может принимать цвета!
  final Widget child;

  const GradientTimerBlob({
    super.key,
    required this.percent,
    required this.isFasting,
    this.colors, // 🔥 ДОБАВЛЕНО
    required this.child,
  });

  @override
  State<GradientTimerBlob> createState() => _GradientTimerBlobState();
}

class _GradientTimerBlobState extends State<GradientTimerBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Если цвета передали извне (из FastingTimerCard) — берем их.
    // Если нет — используем дефолтные градиенты.
    final List<Color> displayColors = widget.colors ?? (widget.isFasting
        ? [
      const Color(0xFFFF4E50), // Red Orange
      const Color(0xFFF9D423), // Warm Yellow
    ]
        : [
      const Color(0xFF43C6AC), // Teal
      const Color(0xFFF8FFAE), // Lime
    ]);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Внешнее свечение (Glow)
            Container(
              width: 240 + (_controller.value * 8),
              height: 240 + (_controller.value * 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    displayColors.first.withOpacity(0.15),
                    displayColors.last.withOpacity(0.15),
                    displayColors.first.withOpacity(0.15),
                  ],
                  transform: GradientRotation(_controller.value * 2 * pi),
                ),
                boxShadow: [
                  BoxShadow(
                    color: displayColors.first.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),

            // 2. Основной круг
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _GradientArcPainter(
                  percent: widget.percent,
                  colors: displayColors, // Передаем нужные цвета художнику
                  strokeWidth: 16,
                ),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Center(child: widget.child),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final double percent;
  final List<Color> colors;
  final double strokeWidth;

  _GradientArcPainter({
    required this.percent,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Фон (трек)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Градиентная кисть
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      tileMode: TileMode.repeated,
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final drawPercent = percent < 0.001 ? 0.001 : percent;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * drawPercent,
      false,
      paint,
    );

    // Свечение на конце (Knob)
    if (percent > 0.01) {
      final endAngle = -pi / 2 + (2 * pi * percent);
      final knobX = center.dx + radius * cos(endAngle);
      final knobY = center.dy + radius * sin(endAngle);

      canvas.drawCircle(Offset(knobX, knobY), 5, Paint()..color = Colors.white);

      canvas.drawCircle(
          Offset(knobX, knobY),
          10,
          Paint()..color = colors.last.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}