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
        return GestureDetector(
          onTap: () {
            getIt<HapticService>().selectionClick();
            onSelect(mood);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.amber, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Text(
              _getMoodEmoji(mood),
              style: TextStyle(
                fontSize: isSelected ? 32 : 24,
              ),
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
}