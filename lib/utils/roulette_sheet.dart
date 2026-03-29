import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/roulette_picker.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/widgets/premium_bottom_sheet_scaffold.dart';

// Универсальная функция для вызова рулетки
Future<T?> showRouletteSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T initialItem,
  required String Function(T) textMapper,
  required Function(T) onSave,
}) {
  final l10n = AppLocalizations.of(context)!;
  T selectedItem = initialItem;
  int initialIndex = items.indexOf(initialItem);
  if (initialIndex == -1) initialIndex = 0;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final cardPadding = AppLayout.cardPadding(context);

          return PremiumBottomSheetScaffold(
            maxHeightFactor: 0.78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textMapper(selectedItem),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.all(cardPadding),
                  child: SizedBox(
                    height: 250,
                    child: RoulettePicker<T>(
                      items: items,
                      initialIndex: initialIndex,
                      textMapper: textMapper,
                      onSelectedItemChanged: (index) {
                        setState(() => selectedItem = items[index]);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () {
                    getIt<HapticService>().mediumImpact();
                    onSave(selectedItem);
                    Navigator.pop(ctx, selectedItem);
                  },
                  color: Colors.blueAccent.withValues(alpha: 0.18),
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
