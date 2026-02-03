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

  int _calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;

    // Создаем копию и сортируем
    var sorted = List<FastingRecord>.from(records);
    sorted.sort((a, b) => b.endTime.compareTo(a.endTime)); // От новых к старым

    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    // Дата последнего голодания (без времени)
    DateTime lastFastDate = DateTime(
        sorted.first.endTime.year, sorted.first.endTime.month, sorted.first.endTime.day);

    int streak = 0;

    // Если последнее голодание было сегодня или вчера — стрик жив
    if (lastFastDate.isAtSameMomentAs(todayDate) ||
        lastFastDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
      streak = 1;
      DateTime checkDate = lastFastDate.subtract(const Duration(days: 1));

      for (int i = 1; i < sorted.length; i++) {
        DateTime currentFastDate = DateTime(
            sorted[i].endTime.year, sorted[i].endTime.month, sorted[i].endTime.day);

        if (currentFastDate.isAtSameMomentAs(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (currentFastDate.isBefore(checkDate)) {
          // Разрыв в днях — стрик прерван
          break;
        }
        // Если дата та же (несколько голоданий в день), просто идем дальше
      }
    }
    return streak;
  }
}