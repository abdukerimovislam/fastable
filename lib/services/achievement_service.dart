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

  // 🔥 ИСПРАВЛЕНИЕ: Интеллектуальный подсчет стрика для длинных голоданий
  // Логика на 100% синхронизирована с HistoryRepository
  int _calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;

    final Set<DateTime> activeDays = {};

    // Собираем ВСЕ дни, затронутые голоданием (включая промежуточные дни)
    for (var r in records) {
      DateTime current = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      final endDay = DateTime(r.endTime.year, r.endTime.month, r.endTime.day);

      while (!current.isAfter(endDay)) {
        activeDays.add(current);
        current = current.add(const Duration(days: 1));
      }
    }

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // Если нет записи ни за сегодня, ни за вчера — стрик разорван
    if (!activeDays.contains(checkDate) && !activeDays.contains(checkDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    // Если сегодня записи нет, но есть вчера — начинаем отсчет со вчерашнего дня
    if (!activeDays.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (activeDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}