import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';

class BodyVisualizer extends StatefulWidget {
  final double weight; // кг
  final double height; // см
  final Color phaseColor;
  final bool isFasting;

  // 🔥 ПРИНИМАЕМ ЗАМЕРЫ ИЗ BLoC
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;

  // 🔥 КОЛЛБЭКИ ДЛЯ НАЖАТИЯ (чтобы открыть рулетку)
  final VoidCallback? onChestTap;
  final VoidCallback? onWaistTap;
  final VoidCallback? onHipsTap;

  const BodyVisualizer({
    super.key,
    required this.weight,
    required this.height,
    required this.phaseColor,
    required this.isFasting,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.onChestTap,
    this.onWaistTap,
    this.onHipsTap,
  });

  @override
  State<BodyVisualizer> createState() => _BodyVisualizerState();
}

class _BodyVisualizerState extends State<BodyVisualizer>
    with SingleTickerProviderStateMixin {
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
    final l10n = AppLocalizations.of(context)!;
    double heightM = widget.height / 100.0;
    if (heightM <= 0) heightM = 1.75;
    final double bmi = widget.weight / (heightM * heightM);

    final double fatFactor = ((bmi - 18.0) / (32.0 - 18.0)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Занимаем всю доступную ширину, чтобы расставить плашки
        final double maxWidth = constraints.maxWidth;
        const double maxHeight = 350.0; // Фиксированная высота холста
        const double bodyWidth = 200.0; // Ширина самого человечка

        return SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Позволяет плашкам вылезать за края
            children: [
              // 1. САМ ЧЕЛОВЕЧЕК (По центру)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SlimBodyPainter(
                      fatFactor: fatFactor,
                      color: widget.phaseColor,
                      breath: _controller.value,
                      isFasting: widget.isFasting,
                    ),
                    child: const SizedBox(width: bodyWidth, height: maxHeight),
                  );
                },
              ),

              // 2. ПЛАШКИ С ЗАМЕРАМИ

              // ГРУДЬ (Chest) - Слева, указывает на уровень груди (Y ≈ 30% высоты)
              Positioned(
                left: 10, // Отступ от левого края карточки
                top: maxHeight * 0.25,
                child: _MeasurementBadge(
                  label: l10n.bodyMeasureChest,
                  value: widget.chestCm,
                  isLeft: true,
                  color: widget.phaseColor,
                  onTap: widget.onChestTap,
                ),
              ),

              // ТАЛИЯ (Waist) - Справа, указывает на узкое место (Y ≈ 45% высоты)
              Positioned(
                right: 10, // Отступ от правого края
                top: maxHeight * 0.42,
                child: _MeasurementBadge(
                  label: l10n.bodyMeasureWaist,
                  value: widget.waistCm,
                  isLeft: false,
                  color: widget.phaseColor,
                  onTap: widget.onWaistTap,
                ),
              ),

              // БЕДРА (Hips) - Слева, указывает на самую широкую часть (Y ≈ 60% высоты)
              Positioned(
                left: 10,
                top: maxHeight * 0.58,
                child: _MeasurementBadge(
                  label: l10n.bodyMeasureHips,
                  value: widget.hipsCm,
                  isLeft: true,
                  color: widget.phaseColor,
                  onTap: widget.onHipsTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🔥 КРАСИВАЯ СТЕКЛЯННАЯ ПЛАШКА С ЛИНИЕЙ-УКАЗАТЕЛЕМ
class _MeasurementBadge extends StatelessWidget {
  final String label;
  final double? value;
  final bool isLeft; // Указывает, с какой стороны от тела находится плашка
  final Color color;
  final VoidCallback? onTap;

  const _MeasurementBadge({
    required this.label,
    required this.value,
    required this.isLeft,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final l10n = AppLocalizations.of(context)!;
    final displayValue = hasValue
        ? "${value!.toStringAsFixed(1)} ${l10n.unitCm}"
        : "+ ${l10n.bodyMeasureAdd}";
    final textColor = hasValue ? Colors.white : color.withValues(alpha: 0.8);

    // Сама стеклянная кнопка
    Widget badge = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue
              ? Colors.white.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasValue
                ? Colors.white.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            if (hasValue)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              displayValue,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    // Линия-указатель
    Widget line = Container(
      width: 25,
      height: 1,
      color: hasValue
          ? Colors.white.withValues(alpha: 0.3)
          : color.withValues(alpha: 0.3),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isLeft
          ? [badge, line]
          : [line, badge], // Если слева - линия смотрит вправо
    );
  }
}

// --- НИЖЕ СТАРЫЙ КОД ХУДОЖНИКА (БЕЗ ИЗМЕНЕНИЙ) ---

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
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    final Rect rect = Offset.zero & size;
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.5)],
    ).createShader(rect);

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    final double headRadius = w * 0.13;
    final double headCenterY = h * 0.11;
    final double shoulderWidth = (w * 0.28) + (fatFactor * w * 0.08);
    final double waistWidth =
        (w * 0.14) + (fatFactor * w * 0.18) + (breath * w * 0.01);
    final double hipWidth = (w * 0.17) + (fatFactor * w * 0.16);
    final double armThick = w * 0.065 + (fatFactor * w * 0.03);
    final double legThick = w * 0.08 + (fatFactor * w * 0.05);
    final double legGap = (w * 0.04 * (1.5 - fatFactor)).clamp(0.01, w * 0.08);
    final double armSpread = w * 0.12;

    final Path path = Path();

    path.addOval(
      Rect.fromCircle(center: Offset(cx, headCenterY), radius: headRadius),
    );
    path.moveTo(cx - headRadius * 0.5, headCenterY + headRadius * 0.8);
    path.quadraticBezierTo(
      cx - shoulderWidth * 0.8,
      headCenterY + headRadius,
      cx - shoulderWidth,
      headCenterY + headRadius * 1.8,
    );
    path.lineTo(cx - shoulderWidth - armSpread, h * 0.52);
    path.quadraticBezierTo(
      cx - shoulderWidth - armSpread,
      h * 0.56,
      cx - shoulderWidth - armSpread + armThick,
      h * 0.52,
    );
    path.lineTo(cx - shoulderWidth + armThick * 0.8, h * 0.32);
    path.cubicTo(
      cx - waistWidth,
      h * 0.40,
      cx - waistWidth,
      h * 0.55,
      cx - hipWidth,
      h * 0.65,
    );
    path.lineTo(cx - hipWidth + (legThick * 0.2), h * 0.93);
    path.quadraticBezierTo(
      cx - hipWidth,
      h * 0.98,
      cx - hipWidth + legThick,
      h * 0.93,
    );
    path.lineTo(cx - legGap, h * 0.68);
    path.quadraticBezierTo(cx, h * 0.66, cx + legGap, h * 0.68);
    path.lineTo(cx + hipWidth - legThick, h * 0.93);
    path.quadraticBezierTo(
      cx + hipWidth,
      h * 0.98,
      cx + hipWidth - (legThick * 0.2),
      h * 0.93,
    );
    path.lineTo(cx + hipWidth, h * 0.65);
    path.cubicTo(
      cx + waistWidth,
      h * 0.55,
      cx + waistWidth,
      h * 0.40,
      cx + shoulderWidth - armThick * 0.8,
      h * 0.32,
    );
    path.lineTo(cx + shoulderWidth + armSpread - armThick, h * 0.52);
    path.quadraticBezierTo(
      cx + shoulderWidth + armSpread,
      h * 0.56,
      cx + shoulderWidth + armSpread,
      h * 0.52,
    );
    path.lineTo(cx + shoulderWidth, headCenterY + headRadius * 1.8);
    path.quadraticBezierTo(
      cx + shoulderWidth * 0.8,
      headCenterY + headRadius,
      cx + headRadius * 0.5,
      headCenterY + headRadius * 0.8,
    );
    path.close();

    if (isFasting) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: 0.3 * (0.6 + breath * 0.4))
          ..strokeWidth = 25
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
      );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 1.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    canvas.drawPath(path, fillPaint);

    if (isFasting) {
      final Offset coreCenter = Offset(cx, h * 0.35);
      canvas.drawCircle(
        coreCenter,
        w * 0.12,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
      canvas.drawCircle(
        coreCenter,
        4 + (breath * 3),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
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
