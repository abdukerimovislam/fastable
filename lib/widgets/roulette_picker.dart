import 'package:flutter/material.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

class RoulettePicker<T> extends StatelessWidget {
  final List<T> items;
  final int initialIndex;
  final Function(int) onSelectedItemChanged;
  final String Function(T) textMapper;
  final double itemHeight;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;

  const RoulettePicker({
    super.key,
    required this.items,
    required this.onSelectedItemChanged,
    this.initialIndex = 0,
    required this.textMapper,
    this.itemHeight = 50.0,
    this.textStyle,
    this.selectedTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Центральная линза (выделение)
        Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ),

        // Скролл
        ListWheelScrollView.useDelegate(
          controller: FixedExtentScrollController(initialItem: initialIndex),
          itemExtent: itemHeight,
          perspective: 0.003,
          diameterRatio: 1.2, // Чуть плотнее барабан
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            getIt<HapticService>().selectionClick();
            onSelectedItemChanged(index);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, index) {
              return Center(
                child: Text(
                  textMapper(items[index]),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ).merge(textStyle),
                ),
              );
            },
          ),
        ),

        // Градиенты (fade to transparent)
        Positioned.fill(
          child: IgnorePointer(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                          const Color(0xFF1E1E1E).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: itemHeight),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                          const Color(0xFF1E1E1E).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
