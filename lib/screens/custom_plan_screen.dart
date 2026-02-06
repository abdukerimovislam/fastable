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
    final isPro = context.select((ProBloc bloc) => bloc.state.status == ProStatus.proActive);

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false, // Нейтральный фон для настроек
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      l10n.lblCustomPlan, // "Custom Plan" (убедитесь, что добавили в arb)
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (!isPro) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          "PRO",
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    ]
                  ],
                ),
              ),

              const Spacer(),

              // --- VISUALIZER (Круговая диаграмма) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      width: 220,
                      child: CustomPaint(
                        painter: _PlanPainter(fastingHours: _fastingHours),
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
                                "${l10n.lblFasting} : ${l10n.lblEating}", // "Fasting : Eating"
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- CONTROLS (Слайдер) ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.lblAdjustDuration, // "Adjust Duration"
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfo(l10n.lblFasting, "${_fastingHours.toInt()}h", Colors.blueAccent),
                          _buildInfo(l10n.lblEating, "${eatingHours.toInt()}h", Colors.greenAccent),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          trackHeight: 8,
                          overlayColor: Colors.blueAccent.withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        ),
                        child: Slider(
                          value: _fastingHours,
                          min: 12,
                          max: 48, // Позволяем до 48 часов
                          divisions: 36, // Шаг 1 час
                          onChanged: (val) {
                            getIt<HapticService>().selectionClick();
                            setState(() => _fastingHours = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          l10n.lblSlideToAdjust, // "Slide to adjust hours"
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- ACTION BUTTON (Start or Unlock) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: GestureDetector(
                  onTap: () => _onActionButtonPressed(context, isPro),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      // Если Pro: Синий градиент. Если нет: Золотой градиент.
                      gradient: isPro
                          ? const LinearGradient(colors: [Colors.blueAccent, Color(0xFF43C6AC)])
                          : const LinearGradient(colors: [Color(0xFFF2994A), Color(0xFFF2C94C)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isPro ? Colors.blueAccent.withOpacity(0.4) : Colors.orangeAccent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isPro) ...[
                          const Icon(Icons.lock_outline, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          isPro ? l10n.btnStartCustomPlan : l10n.btnUnlockFeature, // "Start" vs "Unlock"
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
    final strokeWidth = 16.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
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