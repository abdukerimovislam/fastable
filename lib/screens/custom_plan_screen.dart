import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

// 🔥 ИМПОРТ ПЭЙВОЛА (Убедитесь, что ProBloc внедрен в main.dart)
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/ui/app_layout.dart';

class CustomPlanScreen extends StatefulWidget {
  const CustomPlanScreen({super.key});

  @override
  State<CustomPlanScreen> createState() => _CustomPlanScreenState();
}

class _CustomPlanScreenState extends State<CustomPlanScreen> {
  double _fastingHours = 16;

  void _onActionButtonPressed(BuildContext context, bool isPro) {
    getIt<HapticService>().mediumImpact();

    if (isPro) {
      // ✅ Если PRO: Сохраняем результат и выходим (возвращаем часы)
      Navigator.pop(context, _fastingHours.toInt());
    } else {
      // 🔒 Если НЕ PRO: Открываем экран продажи
      _showPaywall(context);
    }
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eatingHours = 24 - _fastingHours;

    // 🔥 СЛУШАЕМ СТАТУС ПОДПИСКИ ЧЕРЕЗ BLOC
    // Если ProBloc не используется глобально, можно заменить на другую проверку
    final isPro = context.select(
      (ProBloc bloc) => bloc.state.status == ProStatus.proActive,
    );
    final edgePadding = AppLayout.edgePadding(context);
    final cardPadding = AppLayout.cardPadding(context);
    final sectionGap = AppLayout.sectionGap(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: edgePadding,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.lblCustomPlan,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isPro) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: const Text(
                              "PRO",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: edgePadding),
                    child: GlassCard(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildStatusPill(
                                l10n.lblFasting,
                                "${_fastingHours.toInt()}h",
                                Colors.blueAccent,
                              ),
                              _buildStatusPill(
                                l10n.lblEating,
                                "${eatingHours.toInt()}h",
                                Colors.greenAccent,
                              ),
                            ],
                          ),
                          SizedBox(height: sectionGap + 10),
                          SizedBox(
                            height: 220,
                            width: 220,
                            child: CustomPaint(
                              painter: _PlanPainter(
                                fastingHours: _fastingHours,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${_fastingHours.toInt()}:${eatingHours.toInt()}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${l10n.lblFasting} : ${l10n.lblEating}",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.all(edgePadding),
                    child: GlassCard(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.lblAdjustDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo(
                                l10n.lblFasting,
                                "${_fastingHours.toInt()}h",
                                Colors.blueAccent,
                              ),
                              _buildInfo(
                                l10n.lblEating,
                                "${eatingHours.toInt()}h",
                                Colors.greenAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blueAccent,
                              inactiveTrackColor: Colors.white10,
                              thumbColor: Colors.white,
                              trackHeight: 8,
                              overlayColor: Colors.blueAccent.withValues(
                                alpha: 0.2,
                              ),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                            ),
                            child: Slider(
                              value: _fastingHours,
                              min: 12,
                              max: 48,
                              divisions: 36,
                              onChanged: (val) {
                                getIt<HapticService>().selectionClick();
                                setState(() => _fastingHours = val);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              l10n.lblSlideToAdjust,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      edgePadding,
                      0,
                      edgePadding,
                      18,
                    ),
                    child: GestureDetector(
                      onTap: () => _onActionButtonPressed(context, isPro),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: isPro
                              ? const LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Color(0xFF43C6AC),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFF2994A),
                                    Color(0xFFF2C94C),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isPro
                                  ? Colors.blueAccent.withValues(alpha: 0.4)
                                  : Colors.orangeAccent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isPro) ...[
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              isPro
                                  ? l10n.btnStartCustomPlan
                                  : l10n.btnUnlockFeature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PlanPainter extends CustomPainter {
  final double fastingHours;
  _PlanPainter({required this.fastingHours});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 16.0;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fastingPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Рисуем фон (кольцо)
    canvas.drawCircle(center, radius, bgPaint);

    // Рисуем дугу голодания
    // 24 часа = 360 градусов (2 * pi)
    final sweepAngle = (fastingHours / 24) * 2 * 3.14159;

    // Начало сверху (-pi / 2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      fastingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlanPainter oldDelegate) {
    return oldDelegate.fastingHours != fastingHours;
  }
}
