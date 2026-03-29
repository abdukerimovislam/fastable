import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mood_selector.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/utils/fasting_symptoms.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/premium_bottom_sheet_scaffold.dart';

Future<void> showLogMoodSheet(BuildContext parentContext) async {
  // 🔥 1. ЗАГРУЖАЕМ ПРОШЛЫЕ ОТМЕТКИ ДЛЯ ТЕКУЩЕГО ГОЛОДАНИЯ
  final prefs = await SharedPreferences.getInstance();

  FastingMood? selectedMood;
  final savedMoodStr = prefs.getString('current_fast_mood');
  if (savedMoodStr != null) {
    try {
      selectedMood = FastingMood.values.firstWhere(
        (e) => e.name == savedMoodStr,
      );
    } catch (_) {}
  }

  List<String> selectedSymptoms = FastingSymptoms.normalizeStoredValues(
    prefs.getStringList('current_fast_symptoms') ?? const <String>[],
  );

  if (!parentContext.mounted) return;
  final l10n = AppLocalizations.of(parentContext)!;

  await showModalBottomSheet(
    context: parentContext,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final sectionGap = AppLayout.sectionGap(context);
          final cardPadding = AppLayout.cardPadding(context);

          return PremiumBottomSheetScaffold(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: EdgeInsets.all(cardPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purpleAccent.withValues(alpha: 0.24),
                              Colors.blueAccent.withValues(alpha: 0.18),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.endFastHowFeel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.journalSymptomsTitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.64),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      MoodSelector(
                        selectedMood: selectedMood,
                        onSelect: (mood) => setState(() => selectedMood = mood),
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
                        l10n.journalSymptomsTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedSymptoms.length}/${FastingSymptoms.options.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: FastingSymptoms.options.map((symptom) {
                          final isSelected = selectedSymptoms.contains(
                            symptom.id,
                          );
                          return GestureDetector(
                            onTap: () {
                              getIt<HapticService>().lightImpact();
                              setState(() {
                                if (isSelected) {
                                  selectedSymptoms.remove(symptom.id);
                                } else {
                                  selectedSymptoms.add(symptom.id);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.purpleAccent.withValues(
                                        alpha: 0.24,
                                      )
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purpleAccent.withValues(
                                          alpha: 0.8,
                                        )
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.purpleAccent.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: -4,
                                      offset: const Offset(0, 10),
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    symptom.icon,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    FastingSymptoms.labelFor(l10n, symptom.id),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sectionGap + 4),
                GlassCard(
                  onTap: () async {
                    getIt<HapticService>().mediumImpact();

                    if (selectedMood != null) {
                      await prefs.setString(
                        'current_fast_mood',
                        selectedMood!.name,
                      );
                    }
                    await prefs.setStringList(
                      'current_fast_symptoms',
                      selectedSymptoms,
                    );

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.journalUpdated,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.purple.shade800,
                        ),
                      );
                    }
                  },
                  color: Colors.purpleAccent.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Center(
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
