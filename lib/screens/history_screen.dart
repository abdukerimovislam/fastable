import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// DI & Bloc
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_event.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/services/haptic_service.dart';

// Models
import 'package:fastable/models/fasting_record.dart';

// Widgets
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _getDateHeader(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "Today";
    if (checkDate == yesterday) return "Yesterday";
    return DateFormat('MMMM d').format(date);
  }

  // --- НОВОЕ: Хелпер для смайликов ---
  String _getMoodEmoji(FastingMood? mood) {
    switch (mood) {
      case FastingMood.terrible:
        return "😫";
      case FastingMood.bad:
        return "😐";
      case FastingMood.neutral:
        return "🙂";
      case FastingMood.good:
        return "😁";
      case FastingMood.great:
        return "🔥";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();

    return BlocProvider(
      create: (context) =>
      getIt<HistoryBloc>()
        ..add(SubscribeHistory()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  l10n.navHistory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // СТАТИСТИКА И ГРАФИК
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMiniStat(state.records.length.toString(),
                                  "Total Fasts", Colors.blueAccent),
                              _buildMiniStat(
                                  "${state.totalFastingTime.inHours}h",
                                  "Total Time", Colors.greenAccent),
                              _buildMiniStat(
                                  "${state.averageDuration.inHours}h",
                                  "Avg. Time", Colors.orangeAccent),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // WEEKLY CHART
                          SizedBox(
                            height: 80,
                            child: BarChart(
                              _buildWeeklyChartData(state.records),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state.status == HistoryStatus.loading) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors
                              .white24));
                    }

                    if (state.records.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 64,
                                color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text("No history yet", style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: state.records.length,
                      itemBuilder: (context, index) {
                        final record = state.records[index];
                        final String header = _getDateHeader(
                            record.endTime, l10n);
                        final bool showHeader = index == 0 ||
                            _getDateHeader(
                                state.records[index - 1].endTime, l10n) !=
                                header;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8, 20, 0, 10),
                                child: Text(header.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2)),
                              ),
                            _buildHistoryItem(context, record, haptic),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CHART HELPERS ---

  BarChartData _buildWeeklyChartData(List<FastingRecord> records) {
    // 1. Calculate last 7 days data
    Map<int, double> last7Days = {};
    for (int i = 0; i < 7; i++)
      last7Days[i] = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var record in records) {
      final recordDate = DateTime(
          record.endTime.year, record.endTime.month, record.endTime.day);
      final diff = today
          .difference(recordDate)
          .inDays;

      if (diff < 7 && diff >= 0) {
        // 6 is today (rightmost), 0 is 6 days ago
        int index = 6 - diff;
        last7Days[index] =
            (last7Days[index] ?? 0) + record.duration.inMinutes / 60.0;
      }
    }

    // 2. Build BarGroups
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      double value = last7Days[i] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: value >= 16 ? const Color(0xFF43C6AC) : Colors.white
                  .withOpacity(0.3),
              width: 8,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 24, // Max hours per day
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      maxY: 24,
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
      barTouchData: BarTouchData(enabled: false),
    );
  }

  Widget _buildMiniStat(String val, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(val, style: TextStyle(
            color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
            color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, FastingRecord record,
      HapticService haptic) {
    final duration = record.duration;
    final timeFormat = DateFormat('HH:mm');
    // Считаем успешным, если больше 16 часов (или твоя логика)
    final bool isSuccess = duration.inHours >= 16;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(record.startTime.toIso8601String()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24)
          ),
          child: const Icon(
              Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
        ),
        onDismissed: (_) {
          haptic.mediumImpact();
          context.read<HistoryBloc>().add(DeleteRecordEvent(record));
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 1. ИКОНКА СЛЕВА (Молния)
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle
                ),
                child: Icon(
                    Icons.bolt_rounded,
                    color: isSuccess ? Colors.orangeAccent : Colors.blueAccent,
                    size: 26
                ),
              ),

              const SizedBox(width: 16),

              // 2. ИНФОРМАЦИЯ (ВРЕМЯ)
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${duration.inHours}h ${duration.inMinutes % 60}m",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      const SizedBox(height: 4),
                      Text(
                          "${timeFormat.format(record.startTime)} — ${timeFormat
                              .format(record.endTime)}",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13
                          )
                      ),
                    ]
                ),
              ),

              // 3. СМАЙЛИК ИЛИ ЗВЕЗДА (СПРАВА)
              // Если есть настроение — показываем его крупно
              if (record.mood != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1))
                  ),
                  child: Text(
                      _getMoodEmoji(record.mood),
                      style: const TextStyle(fontSize: 24)
                  ),
                )
              // Если настроения нет (старая запись), но цель выполнена — показываем звезду
              else
                if (isSuccess)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.stars_rounded, color: Colors.amberAccent,
                        size: 28),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}