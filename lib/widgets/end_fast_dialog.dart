import 'package:flutter/material.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mood_selector.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/l10n/app_localizations.dart'; // Не забудь про локализацию

class EndFastDialog extends StatefulWidget {
  final Duration duration;
  const EndFastDialog({super.key, required this.duration});

  @override
  State<EndFastDialog> createState() => _EndFastDialogState();
}

class _EndFastDialogState extends State<EndFastDialog> {
  FastingMood _selectedMood = FastingMood.good; // Дефолтное настроение

  @override
  Widget build(BuildContext context) {
    // Форматируем время (например: 16h 20m)
    final hours = widget.duration.inHours;
    final minutes = widget.duration.inMinutes.remainder(60);
    final timeString = "${hours}h ${minutes}m";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C), // Темный фон или используй тему
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Полоска для свайпа
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)
            ),
          ),

          const Text(
              "You did it! 🎉",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            "Total fasting time: $timeString",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 32),

          // Выбор настроения
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("How do you feel?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
          MoodSelector(
            selectedMood: _selectedMood,
            onSelect: (mood) => setState(() => _selectedMood = mood),
          ),

          const SizedBox(height: 32),

          // Кнопка сохранения
          GlassCard(
            onTap: () {
              // Возвращаем выбранное настроение
              Navigator.pop(context, _selectedMood);
            },
            color: Colors.greenAccent.withOpacity(0.2),
            child: const Center(
              child: Text("Save & Eat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 16),
          // Кнопка отмены (если случайно нажал)
          TextButton(
            onPressed: () => Navigator.pop(context, null), // null = отмена
            child: const Text("Cancel, keep fasting", style: TextStyle(color: Colors.white54)),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}