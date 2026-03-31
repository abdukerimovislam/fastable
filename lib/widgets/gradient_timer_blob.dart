import 'dart:math';
import 'package:flutter/material.dart';

class GradientTimerBlob extends StatefulWidget {
  final double percent;
  final bool isFasting;
  final List<Color>? colors;
  final Widget child;

  const GradientTimerBlob({
    super.key,
    required this.percent,
    required this.isFasting,
    this.colors,
    required this.child,
  });

  @override
  State<GradientTimerBlob> createState() => _GradientTimerBlobState();
}

// 🔥 ИСПРАВЛЕНИЕ: Используем TickerProviderStateMixin для нескольких контроллеров
class _GradientTimerBlobState extends State<GradientTimerBlob>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // 1. Контроллер "Дыхания" (Ритм покоя: 2.5с вдох, 2.5с выдох)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Плавная кривая для эффекта легких/сердца
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    // 2. Контроллер бесконечного вращения градиента (10 секунд на оборот)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Не реверсируем, пусть крутится всегда вперед!
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> displayColors =
        widget.colors ??
            (widget.isFasting
                ? [
              const Color(0xFFFF4E50), // Red Orange
              const Color(0xFFF9D423), // Warm Yellow
            ]
                : [
              const Color(0xFF43C6AC), // Teal
              const Color(0xFFF8FFAE), // Lime
            ]);

    // Оборачиваем весь виджет в плавное пульсирующее "дыхание"
    return ScaleTransition(
      scale: _breatheAnimation,
      child: AnimatedBuilder(
        // Слушаем сразу два контроллера
        animation: Listenable.merge([_breatheController, _rotateController]),
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Внешнее "дышащее" свечение (Glow)
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Вращающийся градиент
                  gradient: SweepGradient(
                    colors: [
                      displayColors.first.withValues(alpha: 0.15),
                      displayColors.last.withValues(alpha: 0.15),
                      displayColors.first.withValues(alpha: 0.15),
                    ],
                    transform: GradientRotation(_rotateController.value * 2 * pi),
                  ),
                  boxShadow: [
                    // Тень тоже "дышит", меняя радиус и прозрачность вместе с контроллером
                    BoxShadow(
                      color: displayColors.first.withValues(
                          alpha: 0.15 + (_breatheController.value * 0.1)
                      ),
                      blurRadius: 30 + (_breatheController.value * 15),
                      spreadRadius: 2 + (_breatheController.value * 5),
                    ),
                  ],
                ),
              ),

              // 2. Основной круг прогресса
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _GradientArcPainter(
                    percent: widget.percent,
                    colors: displayColors,
                    strokeWidth: 16,
                  ),
                  child: Center(
                    // 3. Внутренний островок (Центр)
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                        // 🔥 ДОБАВЛЕНО: Глубокая внутренняя тень для эффекта левитации 3D
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: -5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1.5,
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
      ),
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

    // Фон (пустой трек)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Градиентная кисть для заполненной части
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

    canvas.drawArc(rect, -pi / 2, 2 * pi * drawPercent, false, paint);

    // Светящаяся точка (Knob) на конце прогресса
    if (percent > 0.01) {
      final endAngle = -pi / 2 + (2 * pi * percent);
      final knobX = center.dx + radius * cos(endAngle);
      final knobY = center.dy + radius * sin(endAngle);

      canvas.drawCircle(Offset(knobX, knobY), 5, Paint()..color = Colors.white);

      canvas.drawCircle(
        Offset(knobX, knobY),
        10,
        Paint()
          ..color = colors.last.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}