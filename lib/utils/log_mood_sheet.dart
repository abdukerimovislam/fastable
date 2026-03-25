import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mood_selector.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

const List<Map<String, dynamic>> _symptoms = [
  {"icon": "⚡️", "label": "Energy"},
  {"icon": "🧠", "label": "Focus"},
  {"icon": "🤤", "label": "Hungry"},
  {"icon": "😫", "label": "Fatigue"},
  {"icon": "🤕", "label": "Headache"},
  {"icon": "🧊", "label": "Thirsty"},
];

Future<void> showLogMoodSheet(BuildContext context) async {
  // 🔥 1. ЗАГРУЖАЕМ ПРОШЛЫЕ ОТМЕТКИ ДЛЯ ТЕКУЩЕГО ГОЛОДАНИЯ
  final prefs = await SharedPreferences.getInstance();

  FastingMood? selectedMood;
  final savedMoodStr = prefs.getString('current_fast_mood');
  if (savedMoodStr != null) {
    try {
      selectedMood = FastingMood.values.firstWhere((e) => e.name == savedMoodStr);
    } catch (_) {}
  }

  List<String> selectedSymptoms = prefs.getStringList('current_fast_symptoms') ?? [];

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text("How are you feeling?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // 1. Выбор настроения
                    MoodSelector(
                      selectedMood: selectedMood,
                      onSelect: (mood) => setState(() => selectedMood = mood),
                    ),

                    const SizedBox(height: 30),
                    const Text("Symptoms & State", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    // 2. Выбор симптомов
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptoms.map((symptom) {
                        final isSelected = selectedSymptoms.contains(symptom["label"]);
                        return GestureDetector(
                          onTap: () {
                            getIt<HapticService>().lightImpact();
                            setState(() {
                              if (isSelected) {
                                selectedSymptoms.remove(symptom["label"]);
                              } else {
                                selectedSymptoms.add(symptom["label"]);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.purpleAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.purpleAccent : Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(symptom["icon"], style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(symptom["label"], style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    // 🔥 3. СОХРАНЕНИЕ В ПАМЯТЬ
                    GlassCard(
                      onTap: () async {
                        getIt<HapticService>().mediumImpact();

                        // Пишем в SharedPreferences
                        if (selectedMood != null) {
                          await prefs.setString('current_fast_mood', selectedMood!.name);
                        }
                        await prefs.setStringList('current_fast_symptoms', selectedSymptoms);

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text("Journal updated! 📝", style: TextStyle(color: Colors.white)), backgroundColor: Colors.purple.shade800),
                          );
                        }
                      },
                      color: Colors.purpleAccent.withOpacity(0.8),
                      child: const Center(child: Text("Save Log", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            );
          }
      );
    },
  );
}