import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_stage.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart'; // 🔥 ИСПОЛЬЗУЕМ НАШЕ СТЕКЛО!

class FastingStageWidget extends StatelessWidget {
  final Duration elapsedDuration;

  const FastingStageWidget({
    super.key,
    required this.elapsedDuration,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return "${h}h ${m}m";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Вычисляем точные часы в виде дроби (например, 2.5 часа)
    final double elapsedHours = elapsedDuration.inMinutes / 60.0;

    // Получаем текущую стадию из нашей новой модели!
    final FastingStage currentStage = FastingStage.getCurrentStage(elapsedHours);
    final int currentIndex = FastingStage.allStages.indexOf(currentStage);

    // Ищем следующую стадию
    final FastingStage? nextStage = (currentIndex + 1 < FastingStage.allStages.length)
        ? FastingStage.allStages[currentIndex + 1]
        : null;

    final double progressPercent = FastingStage.getStageProgress(elapsedHours);

    String timeLeftText = "";
    String nextStageTitle = "";

    if (nextStage != null && currentStage.endHour != null) {
      final timeUntilNext = Duration(hours: currentStage.endHour!) - elapsedDuration;
      if (!timeUntilNext.isNegative) {
        timeLeftText = _formatDuration(timeUntilNext);
      }
      nextStageTitle = nextStage.getTitle(l10n);
    }

    final String title = currentStage.getTitle(l10n);
    final String desc = currentStage.getDescription(l10n);
    final Color mainColor = currentStage.color;

    // 🔥 ИСПОЛЬЗУЕМ GLASS CARD
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. ИКОНКА С НЕОНОВЫМ СВЕЧЕНИЕМ ---
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: mainColor.withOpacity(0.8), width: 2),
            ),
            child: Icon(currentStage.icon, color: mainColor, size: 34),
          ),

          const SizedBox(height: 20),

          // --- 2. ЗАГОЛОВОК ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [Shadow(color: mainColor.withOpacity(0.6), blurRadius: 15)], // Текст тоже слегка светится!
            ),
          ),

          const SizedBox(height: 12),

          // --- 3. ОПИСАНИЕ ---
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.75),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 30),

          // --- 4. ПРОГРЕСС БАР ---
          if (nextStage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NEXT STAGE", // Можешь заменить на l10n.nextStage если есть
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextStageTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.timeLeft.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLeftText,
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 🔥 СВЕТЯЩИЙСЯ ГРАДИЕНТНЫЙ БАР
            Container(
              height: 10,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white.withOpacity(0.06), // Темная подложка
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [mainColor.withOpacity(0.3), mainColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: mainColor.withOpacity(0.8), blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // --- 5. ФИНАЛЬНАЯ СТАДИЯ ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text("Maximum Benefits Reached!", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}