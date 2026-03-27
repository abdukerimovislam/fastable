import 'package:injectable/injectable.dart';
import 'package:fastable/models/achievement.dart';
import 'package:fastable/models/fasting_record.dart';

@lazySingleton
class AchievementService {

  List<Achievement> getUnlockedAchievements(List<FastingRecord> records) {
    if (records.isEmpty) return [];

    int totalFasts = records.length;
    int totalSeconds = 0;
    for (var r in records) totalSeconds += r.duration.inSeconds;
    int totalHours = (totalSeconds / 3600).floor();

    int currentStreak = _calculateStreak(records);

    // Проверяем все возможные достижения
    return Achievement.all.where((ach) {
      return ach.condition(totalFasts, totalHours, currentStreak);
    }).toList();
  }

  // Вспомогательный метод для форматирования
  String _dateToStr(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // 🔥 ИСПРАВЛЕНИЕ: Безопасный подсчет стрика для ачивок
  int _calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;

    final Set<String> activeDays = {};

    for (var r in records) {
      DateTime current = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      final endDay = DateTime(r.endTime.year, r.endTime.month, r.endTime.day);

      while (!current.isAfter(endDay)) {
        activeDays.add(_dateToStr(current));
        current = DateTime(current.year, current.month, current.day + 1); // Без багов времени
      }
    }

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    String todayStr = _dateToStr(checkDate);
    String yesterdayStr = _dateToStr(DateTime(checkDate.year, checkDate.month, checkDate.day - 1));

    if (!activeDays.contains(todayStr) && !activeDays.contains(yesterdayStr)) {
      return 0;
    }

    if (!activeDays.contains(todayStr)) {
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    while (activeDays.contains(_dateToStr(checkDate))) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    return streak;
  }
}