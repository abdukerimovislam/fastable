import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';

enum FastingZone {
  sugarRises, // 0 - 2 ч
  sugarDrops, // 2 - 8 ч
  fatBurning, // 8 - 14 ч
  ketosis, // 14 - 16 ч
  autophagy, // 16 - 24 ч
  growthHormone, // 24+ ч
}

class FastingStage {
  final FastingZone zone;
  final int startHour;
  final int? endHour; // null значит бесконечность (24+ часов)
  final Color color;
  final IconData icon;

  const FastingStage({
    required this.zone,
    required this.startHour,
    this.endHour,
    required this.color,
    required this.icon,
  });

  // Получить название фазы из локализации
  String getTitle(AppLocalizations l10n) {
    switch (zone) {
      case FastingZone.sugarRises:
        return l10n.zoneSugarRises;
      case FastingZone.sugarDrops:
        return l10n.zoneSugarDrops;
      case FastingZone.fatBurning:
        return l10n.zoneFatBurning;
      case FastingZone.ketosis:
        return l10n.zoneKetosis;
      case FastingZone.autophagy:
        return l10n.zoneAutophagy;
      case FastingZone.growthHormone:
        return l10n.zoneGrowthHormone;
    }
  }

  // Получить описание фазы
  String getDescription(AppLocalizations l10n) {
    switch (zone) {
      case FastingZone.sugarRises:
        return l10n.zoneSugarRisesDesc;
      case FastingZone.sugarDrops:
        return l10n.zoneSugarDropsDesc;
      case FastingZone.fatBurning:
        return l10n.zoneFatBurningDesc;
      case FastingZone.ketosis:
        return l10n.zoneKetosisDesc;
      case FastingZone.autophagy:
        return l10n.zoneAutophagyDesc;
      case FastingZone.growthHormone:
        return l10n.zoneGrowthHormoneDesc;
    }
  }

  // Рассчитать текущую стадию на основе прошедших часов
  static FastingStage getCurrentStage(double elapsedHours) {
    if (elapsedHours < 2) return allStages[0];
    if (elapsedHours < 8) return allStages[1];
    if (elapsedHours < 14) return allStages[2];
    if (elapsedHours < 16) return allStages[3];
    if (elapsedHours < 24) return allStages[4];
    return allStages[5];
  }

  // Рассчитать прогресс ВНУТРИ текущей стадии (от 0.0 до 1.0)
  static double getStageProgress(double elapsedHours) {
    final stage = getCurrentStage(elapsedHours);
    if (stage.endHour == null) {
      return 1.0; // Для последней стадии всегда 100% или можно сделать бесконечный рост
    }

    final stageDuration = stage.endHour! - stage.startHour;
    final hoursInCurrentStage = elapsedHours - stage.startHour;
    return (hoursInCurrentStage / stageDuration).clamp(0.0, 1.0);
  }

  // Все стадии
  static const List<FastingStage> allStages = [
    FastingStage(
      zone: FastingZone.sugarRises,
      startHour: 0,
      endHour: 2,
      color: Color(0xFF64B5F6), // Голубой
      icon: Icons.restaurant,
    ),
    FastingStage(
      zone: FastingZone.sugarDrops,
      startHour: 2,
      endHour: 8,
      color: Color(0xFF4DD0E1), // Светло-синий
      icon: Icons.water_drop,
    ),
    FastingStage(
      zone: FastingZone.fatBurning,
      startHour: 8,
      endHour: 14,
      color: Color(0xFFFFB74D), // Оранжевый
      icon: Icons.local_fire_department,
    ),
    FastingStage(
      zone: FastingZone.ketosis,
      startHour: 14,
      endHour: 16,
      color: Color(0xFFE57373), // Красно-оранжевый
      icon: Icons.psychology,
    ),
    FastingStage(
      zone: FastingZone.autophagy,
      startHour: 16,
      endHour: 24,
      color: Color(0xFFBA68C8), // Пурпурный
      icon: Icons.autorenew,
    ),
    FastingStage(
      zone: FastingZone.growthHormone,
      startHour: 24,
      endHour: null,
      color: Color(0xFFFFD54F), // Золотой
      icon: Icons.fitness_center,
    ),
  ];
}
