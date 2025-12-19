import 'package:flutter/material.dart'; // Нам нужен Material для IconData и Color

class FastingStage {
  final int startHour;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color color;

  const FastingStage({
    required this.startHour,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.color,
  });

  // Теперь мы определим список всех наших стадий
  // Он будет жить прямо в этой модели для легкого доступа
  static final List<FastingStage> allStages = [
    const FastingStage(
      startHour: 0,
      titleKey: "stageAnabolicTitle",
      descKey: "stageAnabolicDesc",
      icon: Icons.restaurant,
      color: Colors.blueAccent,
    ),
    const FastingStage(
      startHour: 4,
      titleKey: "stageCatabolicTitle",
      descKey: "stageCatabolicDesc",
      icon: Icons.directions_run,
      color: Colors.green,
    ),
    const FastingStage(
      startHour: 12,
      titleKey: "stageKetosisTitle",
      descKey: "stageKetosisDesc",
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    const FastingStage(
      startHour: 16,
      titleKey: "stageAutophagyTitle",
      descKey: "stageAutophagyDesc",
      icon: Icons.recycling,
      color: Colors.purpleAccent,
    ),
    const FastingStage(
      startHour: 24,
      titleKey: "stagePeakAutophagyTitle",
      descKey: "stagePeakAutophagyDesc",
      icon: Icons.star,
      color: Colors.redAccent,
    ),
  ];

  // Вспомогательная функция, которая находит текущую стадию
  // на основе прошедших часов.
  static FastingStage getStageForHours(int hours) {
    // Идем по списку в обратном порядке, чтобы найти
    // первую стадию, час начала которой меньше или равен прошедшим часам.
    for (var i = allStages.length - 1; i >= 0; i--) {
      if (hours >= allStages[i].startHour) {
        return allStages[i];
      }
    }
    // По умолчанию возвращаем первую стадию
    return allStages[0];
  }

  // Находит следующую стадию
  static FastingStage? getNextStage(FastingStage currentStage) {
    final currentIndex = allStages.indexOf(currentStage);
    if (currentIndex < allStages.length - 1) {
      return allStages[currentIndex + 1];
    }
    // Если это последняя стадия, следующей нет
    return null;
  }
}