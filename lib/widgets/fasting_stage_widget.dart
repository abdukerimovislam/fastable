import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_stage.dart';
import 'package:fastable/l10n/app_localizations.dart';

class FastingStageWidget extends StatelessWidget {
  final Duration elapsedDuration;

  const FastingStageWidget({
    super.key,
    required this.elapsedDuration,
  });

  // Получение переведенных строк по ключу из модели
  String _getTranslatedText(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "stageAnabolicTitle": return l10n.stageAnabolicTitle;
      case "stageAnabolicDesc": return l10n.stageAnabolicDesc;
      case "stageCatabolicTitle": return l10n.stageCatabolicTitle;
      case "stageCatabolicDesc": return l10n.stageCatabolicDesc;
      case "stageKetosisTitle": return l10n.stageKetosisTitle;
      case "stageKetosisDesc": return l10n.stageKetosisDesc;
      case "stageAutophagyTitle": return l10n.stageAutophagyTitle;
      case "stageAutophagyDesc": return l10n.stageAutophagyDesc;
      case "stagePeakAutophagyTitle": return l10n.stagePeakAutophagyTitle;
      case "stagePeakAutophagyDesc": return l10n.stagePeakAutophagyDesc;
      default: return key;
    }
  }

  // Форматирование времени (например, "2h 15m")
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return "${h}h ${m}m";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 1. Расчет текущей и следующей стадии
    final int elapsedHours = elapsedDuration.inHours;
    final FastingStage currentStage = FastingStage.getStageForHours(elapsedHours);
    final FastingStage? nextStage = FastingStage.getNextStage(currentStage);

    double progressPercent = 0.0;
    String timeLeftText = "";
    String nextStageTitle = "";

    if (nextStage != null) {
      final int stageStartHour = currentStage.startHour;
      final int stageEndHour = nextStage.startHour;
      final int stageTotalHours = stageEndHour - stageStartHour;

      final double elapsedInStageMs = (elapsedDuration.inMilliseconds - Duration(hours: stageStartHour).inMilliseconds).toDouble();
      final double stageTotalMs = Duration(hours: stageTotalHours).inMilliseconds.toDouble();

      // Вычисляем процент завершения текущей стадии
      progressPercent = (elapsedInStageMs / stageTotalMs).clamp(0.0, 1.0);

      // Вычисляем время до следующей стадии
      final timeUntilNext = Duration(hours: stageEndHour) - elapsedDuration;
      if (!timeUntilNext.isNegative) {
        timeLeftText = _formatDuration(timeUntilNext);
      }
      nextStageTitle = _getTranslatedText(context, nextStage.titleKey);
    } else {
      // Если стадий больше нет (максимум)
      progressPercent = 1.0;
    }

    final String title = _getTranslatedText(context, currentStage.titleKey);
    final String desc = _getTranslatedText(context, currentStage.descKey);
    final Color mainColor = currentStage.color;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Глубокий черный фон
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. ИКОНКА С НЕОНОВЫМ СВЕЧЕНИЕМ ---
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mainColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: mainColor.withOpacity(0.5), width: 2),
            ),
            child: Icon(currentStage.icon, color: mainColor, size: 36),
          ),

          const SizedBox(height: 20),

          // --- 2. ЗАГОЛОВОК ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 16),

          // --- 3. ОПИСАНИЕ (Стеклянная подложка) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
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
                      l10n.nextStage.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
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
                      l10n.timeLeft, // Локализованный текст "LEFT" / "ОСТАЛОСЬ"
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeLeftText,
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()], // Моноширинные цифры
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Градиентный прогресс-бар
            Container(
              height: 12,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor.withOpacity(0.6), mainColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
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
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(l10n.maxBenefits, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}