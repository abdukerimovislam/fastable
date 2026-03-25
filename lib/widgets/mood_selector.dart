import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_record.dart'; // Убедись, что тут есть enum FastingMood
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

class MoodSelector extends StatelessWidget {
  final FastingMood? selectedMood;
  final Function(FastingMood) onSelect;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: FastingMood.values.map((mood) {
        final isSelected = selectedMood == mood;
        final color = _getMoodColor(mood);

        return GestureDetector(
          onTap: () {
            getIt<HapticService>().selectionClick();
            onSelect(mood);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack, // Пружинистая анимация
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMoodLabel(mood),
                  style: TextStyle(
                    color: isSelected ? color : Colors.white54,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMoodEmoji(FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible: return "😫";
      case FastingMood.bad: return "😕";
      case FastingMood.neutral: return "😐";
      case FastingMood.good: return "🙂";
      case FastingMood.great: return "🤩";
    }
  }

  String _getMoodLabel(FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible: return "Terrible";
      case FastingMood.bad: return "Bad";
      case FastingMood.neutral: return "Okay";
      case FastingMood.good: return "Good";
      case FastingMood.great: return "Great";
    }
  }

  Color _getMoodColor(FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible: return Colors.redAccent;
      case FastingMood.bad: return Colors.orangeAccent;
      case FastingMood.neutral: return Colors.blueAccent;
      case FastingMood.good: return Colors.greenAccent;
      case FastingMood.great: return Colors.purpleAccent;
    }
  }
}