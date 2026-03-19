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

  // 🔥 ИСПРАВЛЕНИЕ: Логика на 100% идентична HistoryRepository.calculateStreak()
  int _calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // Сортируем копию от новых к старым (на всякий случай)
    var sorted = List<FastingRecord>.from(records);
    sorted.sort((a, b) => b.endTime.compareTo(a.endTime));

    final lastEnd = sorted.first.endTime;
    final lastEndDate = DateTime(lastEnd.year, lastEnd.month, lastEnd.day);

    if (lastEndDate.isBefore(checkDate.subtract(const Duration(days: 1)))) {
      return 0; // Стрик мертв
    }

    checkDate = lastEndDate;
    final uniqueDays = sorted.map((r) {
      final d = r.endTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    while (uniqueDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }
}