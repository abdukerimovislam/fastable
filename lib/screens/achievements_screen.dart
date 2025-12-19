import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/achievement.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/services/achievement_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AchievementsScreen extends StatefulWidget {
  final HistoryRepository repository;

  const AchievementsScreen({super.key, required this.repository});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _unlocked = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final records = await widget.repository.loadRecords();
    final unlockedList = _achievementService.getUnlockedAchievements(records);

    if (mounted) {
      setState(() {
        _unlocked = unlockedList;
        _isLoading = false;
      });
    }
  }

  // --- ИСПРАВЛЕННАЯ ЛОГИКА ПЕРЕВОДОВ ---
  // Мы берем ID достижения и возвращаем строго переменную из l10n

  String _getLocalizedTitle(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'first_fast':
        return l10n.achFirstFastTitle;
      case 'streak_3':
        return l10n.achStreak3Title;
      case 'streak_7':
        return l10n.achStreak7Title;
      case 'total_10':
        return l10n.achTotal10Title;
      case 'total_100_hours':
        return l10n.achTotalHours100Title;
      default:
        return "Unknown Achievement"; // На случай, если ID не найден
    }
  }

  String _getLocalizedDesc(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'first_fast':
        return l10n.achFirstFastDesc;
      case 'streak_3':
        return l10n.achStreak3Desc;
      case 'streak_7':
        return l10n.achStreak7Desc;
      case 'total_10':
        return l10n.achTotal10Desc;
      case 'total_100_hours':
        return l10n.achTotalHours100Desc;
      default:
        return "";
    }
  }
  // ---------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAchievements),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: Achievement.all.length,
          itemBuilder: (context, index) {
            final ach = Achievement.all[index];
            final isUnlocked = _unlocked.any((u) => u.id == ach.id);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildAchievementRow(context, ach, isUnlocked),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementRow(BuildContext context, Achievement ach, bool isUnlocked) {
    final theme = Theme.of(context);

    // Получаем переведенные строки здесь
    final title = _getLocalizedTitle(context, ach.id);
    final desc = _getLocalizedDesc(context, ach.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked
            ? Border.all(color: ach.color.withOpacity(0.3), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: isUnlocked
            ? [
          BoxShadow(
            color: ach.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Можно добавить диалог с деталями при клике
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 1. ИКОНКА
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked
                        ? LinearGradient(
                      colors: [
                        ach.color,
                        ach.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [
                        theme.disabledColor.withOpacity(0.1),
                        theme.disabledColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Icon(
                    ach.icon,
                    color: isUnlocked ? Colors.white : theme.disabledColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                // 2. ТЕКСТ (ПЕРЕВЕДЕННЫЙ)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, // Используем переменную title
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc, // Используем переменную desc
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnlocked ? theme.hintColor : theme.disabledColor.withOpacity(0.5),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 3. СТАТУС
                if (isUnlocked)
                  Icon(Icons.check_circle, color: ach.color, size: 24)
                else
                  Icon(Icons.lock_outline, color: theme.disabledColor.withOpacity(0.3), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}