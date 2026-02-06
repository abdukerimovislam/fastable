import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/roulette_picker.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

Future<DateTime?> showTimePickerSheet({
  required BuildContext context,
  required String title,
  DateTime? initialTime,
}) {
  final now = DateTime.now();
  // По умолчанию берем текущее время
  DateTime selected = initialTime ?? now;

  // Определяем начальные индексы
  // 0 = Вчера, 1 = Сегодня
  int dayIndex = selected.day == now.day ? 1 : 0;
  int hour = selected.hour;
  int minute = selected.minute;

  final days = ["Yesterday", "Today"];
  final hours = List.generate(24, (i) => i);
  final minutes = List.generate(60, (i) => i);

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 450,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // --- 3 КОЛОНКИ: ДЕНЬ | ЧАСЫ | МИНУТЫ ---
              Expanded(
                child: Row(
                  children: [
                    // ДЕНЬ
                    Expanded(
                      flex: 3,
                      child: RoulettePicker<String>(
                        items: days,
                        initialIndex: dayIndex,
                        textMapper: (val) => val,
                        onSelectedItemChanged: (idx) => dayIndex = idx,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ЧАСЫ
                    Expanded(
                      flex: 2,
                      child: RoulettePicker<int>(
                        items: hours,
                        initialIndex: hour,
                        textMapper: (h) => h.toString().padLeft(2, '0'),
                        onSelectedItemChanged: (val) => hour = hours[val],
                      ),
                    ),
                    const Text(":", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    // МИНУТЫ
                    Expanded(
                      flex: 2,
                      child: RoulettePicker<int>(
                        items: minutes,
                        initialIndex: minute,
                        textMapper: (m) => m.toString().padLeft(2, '0'),
                        onSelectedItemChanged: (val) => minute = minutes[val],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              GlassCard(
                onTap: () {
                  getIt<HapticService>().mediumImpact();
                  // Собираем DateTime
                  final dateBase = DateTime.now().subtract(Duration(days: dayIndex == 0 ? 1 : 0));
                  final finalTime = DateTime(dateBase.year, dateBase.month, dateBase.day, hour, minute);

                  Navigator.pop(ctx, finalTime);
                },
                color: Colors.blueAccent.withOpacity(0.8),
                child: const Center(child: Text("Confirm Time", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      );
    },
  );
}