import 'package:flutter/material.dart';
import 'package:fastable/models/fasting_record.dart'; // Убедись, что тут есть enum FastingMood
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppLayout.sectionGap(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth =
            MediaQuery.sizeOf(context).width -
            (AppLayout.edgePadding(context) * 2);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final itemWidth = ((availableWidth - (spacing * 4)) / 5)
            .clamp(54.0, 76.0)
            .toDouble();

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: FastingMood.values.map((mood) {
            final isSelected = selectedMood == mood;
            final color = _getMoodColor(mood);

            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                onTap: () {
                  getIt<HapticService>().selectionClick();
                  onSelect(mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? color.withValues(alpha: 0.82)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.28),
                          blurRadius: 18,
                          spreadRadius: 0,
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.22 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMoodLabel(l10n, mood),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white60,
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getMoodEmoji(FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible:
        return "😫";
      case FastingMood.bad:
        return "😕";
      case FastingMood.neutral:
        return "😐";
      case FastingMood.good:
        return "🙂";
      case FastingMood.great:
        return "🤩";
    }
  }

  String _getMoodLabel(AppLocalizations l10n, FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible:
        return l10n.moodTerrible;
      case FastingMood.bad:
        return l10n.moodBad;
      case FastingMood.neutral:
        return l10n.moodOkay;
      case FastingMood.good:
        return l10n.moodGood;
      case FastingMood.great:
        return l10n.moodGreat;
    }
  }

  Color _getMoodColor(FastingMood mood) {
    switch (mood) {
      case FastingMood.terrible:
        return Colors.redAccent;
      case FastingMood.bad:
        return Colors.orangeAccent;
      case FastingMood.neutral:
        return Colors.blueAccent;
      case FastingMood.good:
        return Colors.greenAccent;
      case FastingMood.great:
        return Colors.purpleAccent;
    }
  }
}
