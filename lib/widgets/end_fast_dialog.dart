import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mood_selector.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/premium_bottom_sheet_scaffold.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final sectionGap = AppLayout.sectionGap(context);
    final cardPadding = AppLayout.cardPadding(context);
    final hours = widget.duration.inHours;
    final minutes = widget.duration.inMinutes.remainder(60);
    final timeString = l10n.durationHoursMinutesShort(hours, minutes);

    return PremiumBottomSheetScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.greenAccent.withValues(alpha: 0.28),
                        Colors.tealAccent.withValues(alpha: 0.18),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.endFastCongrats,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.endFastTotalTime(timeString),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sectionGap + 2),
          GlassCard(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.endFastHowFeel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.journalSymptomsTitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: sectionGap + 4),
                MoodSelector(
                  selectedMood: _selectedMood,
                  onSelect: (mood) => setState(() => _selectedMood = mood),
                ),
              ],
            ),
          ),
          SizedBox(height: sectionGap + 2),
          GlassCard(
            onTap: () => Navigator.pop(context, _selectedMood),
            color: Colors.greenAccent.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Center(
              child: Text(
                l10n.endFastSaveEat,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              l10n.endFastKeepFasting,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
