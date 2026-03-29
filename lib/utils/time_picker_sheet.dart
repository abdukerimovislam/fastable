import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/roulette_picker.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/widgets/premium_bottom_sheet_scaffold.dart';

Future<DateTime?> showTimePickerSheet({
  required BuildContext context,
  required String title,
  DateTime? initialTime,
}) {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  DateTime selected = initialTime ?? now;
  int dayIndex = selected.day == now.day ? 1 : 0;
  int hour = selected.hour;
  int minute = selected.minute;

  final days = [l10n.lblYesterday, l10n.lblToday];
  final hours = List.generate(24, (i) => i);
  final minutes = List.generate(60, (i) => i);

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final cardPadding = AppLayout.cardPadding(context);
          final selectedLabel =
              '${days[dayIndex]} · ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

          return PremiumBottomSheetScaffold(
            maxHeightFactor: 0.82,
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
                        selectedLabel,
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: RoulettePicker<String>(
                            items: days,
                            initialIndex: dayIndex,
                            textMapper: (val) => val,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelectedItemChanged: (idx) {
                              setState(() => dayIndex = idx);
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: RoulettePicker<int>(
                            items: hours,
                            initialIndex: hour,
                            textMapper: (h) => h.toString().padLeft(2, '0'),
                            onSelectedItemChanged: (index) {
                              setState(() => hour = hours[index]);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            ':',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: RoulettePicker<int>(
                            items: minutes,
                            initialIndex: minute,
                            textMapper: (m) => m.toString().padLeft(2, '0'),
                            onSelectedItemChanged: (index) {
                              setState(() => minute = minutes[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  onTap: () {
                    getIt<HapticService>().mediumImpact();
                    final dateBase = DateTime.now().subtract(
                      Duration(days: dayIndex == 0 ? 1 : 0),
                    );
                    final finalTime = DateTime(
                      dateBase.year,
                      dateBase.month,
                      dateBase.day,
                      hour,
                      minute,
                    );

                    Navigator.pop(ctx, finalTime);
                  },
                  color: Colors.blueAccent.withValues(alpha: 0.18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Center(
                    child: Text(
                      l10n.confirmTime,
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
