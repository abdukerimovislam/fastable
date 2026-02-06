import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fastable/widgets/roulette_picker.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

// Универсальная функция для вызова рулетки
Future<T?> showRouletteSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T initialItem,
  required String Function(T) textMapper,
  required Function(T) onSave,
}) {
  T selectedItem = initialItem;
  int initialIndex = items.indexOf(initialItem);
  if (initialIndex == -1) initialIndex = 0;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 450,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              // Полоска свайпа
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2)
                  )
              ),
              const SizedBox(height: 24),

              // Заголовок
              Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
              ),

              const SizedBox(height: 20),

              // --- НАША РУЛЕТКА ---
              Expanded(
                child: RoulettePicker<T>(
                  items: items,
                  initialIndex: initialIndex,
                  textMapper: textMapper,
                  onSelectedItemChanged: (index) {
                    selectedItem = items[index];
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Кнопка Сохранить
              GlassCard(
                onTap: () {
                  getIt<HapticService>().mediumImpact();
                  onSave(selectedItem);
                  Navigator.pop(ctx);
                },
                color: Colors.blueAccent.withOpacity(0.8),
                child: const Center(
                    child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    )
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}