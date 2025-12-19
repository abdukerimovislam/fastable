import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_stage.dart';
import 'package:fastable/l10n/app_localizations.dart';

class FastingStageWidget extends StatelessWidget {
  final Duration elapsedDuration;

  const FastingStageWidget({
    super.key,
    required this.elapsedDuration,
  });

  // Вспомогательная функция для получения переведенного текста по ключу
  String _getTranslatedText(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "stageAnabolicTitle":
        return l10n.stageAnabolicTitle;
      case "stageAnabolicDesc":
        return l10n.stageAnabolicDesc;
      case "stageCatabolicTitle":
        return l10n.stageCatabolicTitle;
      case "stageCatabolicDesc":
        return l10n.stageCatabolicDesc;
      case "stageKetosisTitle":
        return l10n.stageKetosisTitle;
      case "stageKetosisDesc":
        return l10n.stageKetosisDesc;
      case "stageAutophagyTitle":
        return l10n.stageAutophagyTitle;
      case "stageAutophagyDesc":
        return l10n.stageAutophagyDesc;
      case "stagePeakAutophagyTitle":
        return l10n.stagePeakAutophagyTitle;
      case "stagePeakAutophagyDesc":
        return l10n.stagePeakAutophagyDesc;
      default:
        return "Loading...";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 1. Определяем текущую и следующую стадии
    final int elapsedHours = elapsedDuration.inHours;
    final FastingStage currentStage = FastingStage.getStageForHours(elapsedHours);
    final FastingStage? nextStage = FastingStage.getNextStage(currentStage);

    // 2. Рассчитываем прогресс до следующей стадии
    double progressPercent = 0.0;
    String nextStageText = "";

    if (nextStage != null) {
      final int stageStartHour = currentStage.startHour;
      final int stageEndHour = nextStage.startHour;
      final int stageTotalHours = stageEndHour - stageStartHour;

      // Используем миллисекунды для плавной анимации
      final double elapsedInStageMs = (elapsedDuration.inMilliseconds -
          Duration(hours: stageStartHour).inMilliseconds)
          .toDouble();

      final double stageTotalMs =
      Duration(hours: stageTotalHours).inMilliseconds.toDouble();

      progressPercent = (elapsedInStageMs / stageTotalMs).clamp(0.0, 1.0);

      nextStageText = "${l10n.nextStage}: ${_getTranslatedText(context, nextStage.titleKey)}";
    } else {
      // Это последняя стадия
      progressPercent = 1.0;
      nextStageText = ""; // Следующей стадии нет
    }

    final String title = _getTranslatedText(context, currentStage.titleKey);
    final String desc = _getTranslatedText(context, currentStage.descKey);

    return Card(
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation,
      shadowColor: theme.cardTheme.shadowColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ЗАГОЛОВОК (ИКОНКА + НАЗВАНИЕ) ---
            // AnimatedSwitcher будет плавно менять контент
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Row(
                // Ключ 'key' здесь КРАЙНЕ ВАЖЕН.
                // Он говорит AnimatedSwitcher, что контент изменился.
                key: ValueKey<String>(title),
                children: [
                  Icon(currentStage.icon, color: currentStage.color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- ОПИСАНИЕ ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                desc,
                key: ValueKey<String>(desc),
                style: TextStyle(
                  fontSize: 15,
                  color: theme.hintColor,
                  height: 1.4,
                ),
              ),
            ),

            // --- ПРОГРЕСС-БАР (если есть следующая стадия) ---
            if (nextStage != null) ...[
              const SizedBox(height: 20),
              // Текст "Далее: Аутофагия"
              Text(
                nextStageText,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Сам прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  color: currentStage.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}