import 'package:fastable/models/achievement.dart';
import 'package:fastable/models/fasting_record.dart';

class AchievementService {

  List<Achievement> getUnlockedAchievements(List<FastingRecord> records) {
    if (records.isEmpty) return [];

    int totalFasts = records.length;
    int totalSeconds = 0;
    for (var r in records) totalSeconds += r.duration.inSeconds;
    int totalHours = (totalSeconds / 3600).floor();
    int currentStreak = _calculateStreak(records);

    // Фильтруем список всех достижений
    return Achievement.all.where((ach) {
      return ach.condition(totalFasts, totalHours, currentStreak);
    }).toList();
  }

  int _calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;
    var sorted = List<FastingRecord>.from(records);
    sorted.sort((a, b) => b.endTime.compareTo(a.endTime));

    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime lastFastDate = DateTime(
        sorted.first.endTime.year, sorted.first.endTime.month, sorted.first.endTime.day);

    int streak = 0;
    if (_isSameDay(lastFastDate, todayDate) ||
        _isSameDay(lastFastDate, todayDate.subtract(const Duration(days: 1)))) {
      streak = 1;
      DateTime checkDate = lastFastDate.subtract(const Duration(days: 1));

      for (int i = 1; i < sorted.length; i++) {
        DateTime currentFastDate = DateTime(
            sorted[i].endTime.year, sorted[i].endTime.month, sorted[i].endTime.day);

        if (_isSameDay(currentFastDate, checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (!_isSameDay(currentFastDate, lastFastDate)) { // Игнорируем дубликаты за один день
          if (currentFastDate.isBefore(checkDate)) break;
        }
      }
    }
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}