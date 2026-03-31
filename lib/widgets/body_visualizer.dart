import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';

class BodyVisualizer extends StatefulWidget {
  final double weight; // кг
  final double height; // см
  final Color phaseColor;
  final bool isFasting;

  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;

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

    // Логика визуального веса
    final double fatFactor = ((bmi - 18.0) / (32.0 - 18.0)).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. ШАПКА (ЗАГОЛОВОК И КНОПКА ВЫХОДА ВЕРНУЛАСЬ СЮДА) ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bodyMetricsTitle, // 🔥 Локализовано
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    l10n.bodyMetricsHint, // 🔥 Локализовано
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- 2. ЦЕНТРАЛЬНАЯ ЧАСТЬ (АВАТАР И ЗАМЕРЫ) ---
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              const double maxHeight = 380.0;
              const double bodyWidth = 200.0;

              return SizedBox(
                width: maxWidth,
                height: maxHeight,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // --- ТЕЛО (На заднем плане) ---
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

                    // --- УМНЫЕ КАРТОЧКИ (В шахматном порядке для баланса) ---

                    // ГРУДЬ (Chest) - Слева
                    Positioned(
                      left: 16,
                      top: maxHeight * 0.18,
                      child: _SmartMeasurementCard(
                        label: l10n.bodyMeasureChestTitle,
                        value: widget.chestCm,
                        isLeft: true,
                        color: widget.phaseColor,
                        onTap: widget.onChestTap,
                      ),
                    ),

                    // ТАЛИЯ (Waist) - Справа
                    Positioned(
                      right: 16,
                      top: maxHeight * 0.38,
                      child: _SmartMeasurementCard(
                        label: l10n.bodyMeasureWaistTitle,
                        value: widget.waistCm,
                        isLeft: false,
                        color: widget.phaseColor,
                        onTap: widget.onWaistTap,
                      ),
                    ),

                    // БЕДРА (Hips) - Слева
                    Positioned(
                      left: 16,
                      top: maxHeight * 0.58,
                      child: _SmartMeasurementCard(
                        label: l10n.bodyMeasureHipsTitle,
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
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// 🔥 ПРЕМИАЛЬНАЯ КАРТОЧКА ЗАМЕРА
class _SmartMeasurementCard extends StatelessWidget {
  final String label;
  final double? value;
  final bool isLeft;
  final Color color;
  final VoidCallback? onTap;

  const _SmartMeasurementCard({
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

    // Тексты (🔥 Локализовано)
    final String displayValue = hasValue ? value!.toStringAsFixed(1) : l10n.bodyMetricsAdd;
    final String unitOrAction = hasValue ? l10n.unitCm : l10n.bodyMetricsTapToSet;

    // Стилизация
    final Color accentColor = hasValue ? Colors.white : color.withValues(alpha: 0.9);
    final Color bgColor = hasValue
        ? Colors.white.withValues(alpha: 0.15)
        : color.withValues(alpha: 0.1);

    Widget card = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minWidth: 110),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasValue
                    ? Colors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.3),
              ),
              boxShadow: [
                if (hasValue)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasValue) ...[
                  Icon(Icons.straighten_rounded, color: Colors.white.withValues(alpha: 0.6), size: 16),
                  const SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          displayValue,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unitOrAction,
                          style: TextStyle(
                            color: accentColor.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Элегантная градиентная линия
    Widget connector = Container(
      width: 30,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? [accentColor.withValues(alpha: 0.5), Colors.transparent]
              : [Colors.transparent, accentColor.withValues(alpha: 0.5)],
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isLeft ? [card, connector] : [connector, card],
    );
  }
}

// ПРОКАЧАННЫЙ ХУДОЖНИК ТЕЛА (ДОБАВЛЕНЫ ТОЧКИ-ИНДИКАТОРЫ)
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
      colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.3)],
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

    path.addOval(Rect.fromCircle(center: Offset(cx, headCenterY), radius: headRadius));
    path.moveTo(cx - headRadius * 0.5, headCenterY + headRadius * 0.8);
    path.quadraticBezierTo(
      cx - shoulderWidth * 0.8, headCenterY + headRadius,
      cx - shoulderWidth, headCenterY + headRadius * 1.8,
    );
    path.lineTo(cx - shoulderWidth - armSpread, h * 0.52);
    path.quadraticBezierTo(
      cx - shoulderWidth - armSpread, h * 0.56,
      cx - shoulderWidth - armSpread + armThick, h * 0.52,
    );
    path.lineTo(cx - shoulderWidth + armThick * 0.8, h * 0.32);
    path.cubicTo(
      cx - waistWidth, h * 0.40,
      cx - waistWidth, h * 0.55,
      cx - hipWidth, h * 0.65,
    );
    path.lineTo(cx - hipWidth + (legThick * 0.2), h * 0.93);
    path.quadraticBezierTo(
      cx - hipWidth, h * 0.98,
      cx - hipWidth + legThick, h * 0.93,
    );
    path.lineTo(cx - legGap, h * 0.68);
    path.quadraticBezierTo(cx, h * 0.66, cx + legGap, h * 0.68);
    path.lineTo(cx + hipWidth - legThick, h * 0.93);
    path.quadraticBezierTo(
      cx + hipWidth, h * 0.98,
      cx + hipWidth - (legThick * 0.2), h * 0.93,
    );
    path.lineTo(cx + hipWidth, h * 0.65);
    path.cubicTo(
      cx + waistWidth, h * 0.55,
      cx + waistWidth, h * 0.40,
      cx + shoulderWidth - armThick * 0.8, h * 0.32,
    );
    path.lineTo(cx + shoulderWidth + armSpread - armThick, h * 0.52);
    path.quadraticBezierTo(
      cx + shoulderWidth + armSpread, h * 0.56,
      cx + shoulderWidth + armSpread, h * 0.52,
    );
    path.lineTo(cx + shoulderWidth, headCenterY + headRadius * 1.8);
    path.quadraticBezierTo(
      cx + shoulderWidth * 0.8, headCenterY + headRadius,
      cx + headRadius * 0.5, headCenterY + headRadius * 0.8,
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

    // ЦЕЛЕВЫЕ УЗЛЫ (Target Nodes) для замеров
    _drawGlowingNode(canvas, Offset(cx, h * 0.31), color, breath); // Грудь
    _drawGlowingNode(canvas, Offset(cx, h * 0.45), color, breath); // Талия
    _drawGlowingNode(canvas, Offset(cx, h * 0.60), color, breath); // Бедра
  }

  void _drawGlowingNode(Canvas canvas, Offset position, Color color, double breath) {
    canvas.drawCircle(
      position,
      8 + (breath * 2), // Пульсирует
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      position,
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _SlimBodyPainter oldDelegate) {
    return oldDelegate.breath != breath ||
        oldDelegate.fatFactor != fatFactor ||
        oldDelegate.color != color ||
        oldDelegate.isFasting != isFasting;
  }
}