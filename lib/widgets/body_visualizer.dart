import 'package:flutter/material.dart';

class BodyVisualizer extends StatefulWidget {
  final double weight; // кг
  final double height; // см
  final Color phaseColor;
  final bool isFasting;

  const BodyVisualizer({
    super.key,
    required this.weight,
    required this.height,
    required this.phaseColor,
    required this.isFasting,
  });

  @override
  State<BodyVisualizer> createState() => _BodyVisualizerState();
}

class _BodyVisualizerState extends State<BodyVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Дыхание медленнее и спокойнее
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Расчет ИМТ
    double heightM = widget.height / 100.0;
    if (heightM <= 0) heightM = 1.75;
    final double bmi = widget.weight / (heightM * heightM);

    // 2. Фактор полноты
    // Диапазон BMI: 18.0 (худой) ... 32.0 (полный).
    final double fatFactor = ((bmi - 18.0) / (32.0 - 18.0)).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SlimBodyPainter(
            fatFactor: fatFactor,
            color: widget.phaseColor,
            breath: _controller.value,
            isFasting: widget.isFasting,
          ),
          child: const SizedBox(width: 200, height: 350),
        );
      },
    );
  }
}

class _SlimBodyPainter extends CustomPainter {
  final double fatFactor;
  final Color color;
  final double breath;
  final bool isFasting;

  _SlimBodyPainter({
    required this.fatFactor,
    required this.color,
    required this.breath,
    required this.isFasting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ИСПРАВЛЕНО: переименовал 'paint' в 'fillPaint'
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    // Градиент заливки
    final Rect rect = Offset.zero & size;
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.5),
      ],
    ).createShader(rect);

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    // --- ПАРАМЕТРЫ ФИГУРЫ (Slim Fit) ---

    // Голова
    final double headRadius = w * 0.13;
    final double headCenterY = h * 0.11;

    // Плечи (шире головы, но не огромные)
    final double shoulderWidth = (w * 0.28) + (fatFactor * w * 0.08);

    // Талия (самое узкое место)
    final double waistWidth = (w * 0.14) + (fatFactor * w * 0.18) + (breath * w * 0.01);

    // Бедра (чуть шире талии)
    final double hipWidth = (w * 0.17) + (fatFactor * w * 0.16);

    // Руки (тонкие)
    final double armThick = w * 0.065 + (fatFactor * w * 0.03);

    // Ноги (стройные)
    final double legThick = w * 0.08 + (fatFactor * w * 0.05);

    // Просвет между ногами (Thigh gap)
    final double legGap = (w * 0.04 * (1.5 - fatFactor)).clamp(0.01, w * 0.08);

    // Угол рук (немного отведены)
    final double armSpread = w * 0.12;

    final Path path = Path();

    // 1. ГОЛОВА
    path.addOval(Rect.fromCircle(center: Offset(cx, headCenterY), radius: headRadius));

    // 2. ТУЛОВИЩЕ (ЛЕВАЯ СТОРОНА)
    // Шея
    path.moveTo(cx - headRadius * 0.5, headCenterY + headRadius * 0.8);

    // Плечо
    path.quadraticBezierTo(
        cx - shoulderWidth * 0.8, headCenterY + headRadius,
        cx - shoulderWidth, headCenterY + headRadius * 1.8 // Плечевой сустав
    );

    // Рука левая (внешняя)
    path.lineTo(cx - shoulderWidth - armSpread, h * 0.52); // Кисть

    // Кисть (закругление)
    path.quadraticBezierTo(
        cx - shoulderWidth - armSpread, h * 0.56,
        cx - shoulderWidth - armSpread + armThick, h * 0.52 // Внутренняя часть кисти
    );

    // Рука левая (внутренняя -> подмышка)
    path.lineTo(cx - shoulderWidth + armThick * 0.8, h * 0.32); // Подмышка

    // Бок (Талия и Бедро)
    path.cubicTo(
        cx - waistWidth, h * 0.40, // Изгиб к талии
        cx - waistWidth, h * 0.55, // Талия
        cx - hipWidth, h * 0.65    // Бедро
    );

    // Нога левая (Внешняя)
    path.lineTo(cx - hipWidth + (legThick * 0.2), h * 0.93); // Щиколотка

    // Стопа
    path.quadraticBezierTo(
        cx - hipWidth, h * 0.98,
        cx - hipWidth + legThick, h * 0.93 // Пятка
    );

    // Нога левая (Внутренняя -> Пах)
    path.lineTo(cx - legGap, h * 0.68); // Пах

    // ---------------- ЗЕРКАЛИМ ПРАВУЮ СТОРОНУ ----------------

    // Пах (закругление)
    path.quadraticBezierTo(cx, h * 0.66, cx + legGap, h * 0.68);

    // Нога правая (Внутренняя)
    path.lineTo(cx + hipWidth - legThick, h * 0.93);

    // Стопа правая
    path.quadraticBezierTo(
        cx + hipWidth, h * 0.98,
        cx + hipWidth - (legThick * 0.2), h * 0.93
    );

    // Нога правая (Внешняя -> Бедро)
    path.lineTo(cx + hipWidth, h * 0.65);

    // Бок правый
    path.cubicTo(
        cx + waistWidth, h * 0.55,
        cx + waistWidth, h * 0.40,
        cx + shoulderWidth - armThick * 0.8, h * 0.32 // Подмышка
    );

    // Рука правая (Внутренняя)
    path.lineTo(cx + shoulderWidth + armSpread - armThick, h * 0.52);

    // Кисть правая
    path.quadraticBezierTo(
        cx + shoulderWidth + armSpread, h * 0.56,
        cx + shoulderWidth + armSpread, h * 0.52
    );

    // Рука правая (Внешняя -> Плечо)
    path.lineTo(cx + shoulderWidth, headCenterY + headRadius * 1.8);

    // Плечо к шее
    path.quadraticBezierTo(
        cx + shoulderWidth * 0.8, headCenterY + headRadius,
        cx + headRadius * 0.5, headCenterY + headRadius * 0.8
    );

    path.close();

    // --- ОТРИСОВКА ---

    // 1. АУРА (Свечение)
    if (isFasting) {
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withOpacity(0.3 * (0.6 + breath * 0.4))
        ..strokeWidth = 25
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
      );

      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      );
    }

    // 2. ТЕЛО
    // Теперь переменная fillPaint существует
    canvas.drawPath(path, fillPaint);

    // 3. СЕРДЦЕ / ЯДРО
    if (isFasting) {
      final Offset coreCenter = Offset(cx, h * 0.35);

      // Мягкое свечение в груди
      canvas.drawCircle(coreCenter, w * 0.12, Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
      );

      // Точка энергии
      canvas.drawCircle(coreCenter, 4 + (breath * 3), Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SlimBodyPainter oldDelegate) {
    return oldDelegate.breath != breath ||
        oldDelegate.fatFactor != fatFactor ||
        oldDelegate.color != color;
  }
}