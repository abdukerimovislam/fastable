import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/app_theme.dart';
import 'package:fastable/l10n/app_localizations.dart';

import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

class ProCorrelationChart extends StatefulWidget {
  const ProCorrelationChart({super.key});

  @override
  State<ProCorrelationChart> createState() => _ProCorrelationChartState();
}

class _ProCorrelationChartState extends State<ProCorrelationChart> {
  // Выбранный период: 7 (1W), 30 (1M), 90 (3M)
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ЗАГОЛОВОК И ПЕРЕКЛЮЧАТЕЛЬ ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.chartFastingVsWeight,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTimeframeSelector(l10n),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chartTrackMetabolic,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 30),

          // --- ГРАФИК ---
          _buildChart(context, l10n),

          const SizedBox(height: 24),

          // --- УМНЫЙ ИНСАЙТ (AI INSIGHT) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.premiumGold.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.premiumGold.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_circle_rounded,
                  color: AppTheme.premiumGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chartSmartInsight.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.premiumGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDynamicInsight(l10n),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ВИДЖЕТ: ПЕРЕКЛЮЧАТЕЛЬ ВРЕМЕНИ ---
  Widget _buildTimeframeSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTimeButton(l10n.chart1W, 7),
          _buildTimeButton(l10n.chart1M, 30),
          _buildTimeButton(l10n.chart3M, 90),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String title, int days) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          getIt<HapticService>().selectionClick();
          setState(() => _selectedDays = days);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.heroSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- ВИДЖЕТ: ГРАФИК ---
  Widget _buildChart(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, historyState) {
        return BlocBuilder<WeightBloc, WeightState>(
          builder: (context, weightState) {
            // ГЕНЕРАЦИЯ ДАННЫХ ДЛЯ ВЫБРАННОГО ПЕРИОДА
            final now = DateTime.now();
            final dates = List.generate(
              _selectedDays,
                  (i) => now.subtract(Duration(days: _selectedDays - 1 - i)),
            );

            List<FlSpot> fastingSpots = [];
            List<FlSpot> weightSpots = [];

            for (int i = 0; i < dates.length; i++) {
              final date = dates[i];

              // Ищем голодания
              final recordsForDay = historyState.records.where(
                    (r) =>
                r.startTime.year == date.year &&
                    r.startTime.month == date.month &&
                    r.startTime.day == date.day,
              );

              double fastingHours = 0.0;
              if (recordsForDay.isNotEmpty) {
                fastingHours = recordsForDay
                    .map((r) => r.duration.inMinutes / 60.0)
                    .reduce((a, b) => a > b ? a : b);
              }

              // 🔥 ИСПРАВЛЕНИЕ: Оптимизированный поиск веса без sort()
              double weightOfDay = weightState.currentWeight;
              final weightEntriesForDay = weightState.history.where(
                    (w) =>
                w.date.year == date.year &&
                    w.date.month == date.month &&
                    w.date.day == date.day,
              );

              if (weightEntriesForDay.isNotEmpty) {
                weightOfDay = weightEntriesForDay.last.weight;
              } else {
                // Если за этот день записи нет, берем самую свежую ПЕРЕД этой датой
                final pastWeights = weightState.history.where((w) => w.date.isBefore(date));
                if (pastWeights.isNotEmpty) {
                  // reduce находит элемент с самой поздней датой за один проход O(N) вместо сортировки O(N log N)
                  weightOfDay = pastWeights.reduce((a, b) => a.date.isAfter(b.date) ? a : b).weight;
                }
              }

              fastingSpots.add(FlSpot(i.toDouble(), fastingHours));
              weightSpots.add(FlSpot(i.toDouble(), weightOfDay));
            }

            // 🔥 ИСПРАВЛЕНИЕ: Целевой вес (Безопасная динамическая цель: -5% от текущего веса)
            double targetWeight = weightState.currentWeight * 0.95;

            return Column(
              children: [
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      // ПУНКТИРНАЯ ЛИНИЯ ЦЕЛИ (Target Weight)
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: targetWeight,
                            color: AppTheme.heroPrimary.withValues(alpha: 0.5),
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(
                                right: 5,
                                bottom: 5,
                              ),
                              style: TextStyle(
                                color: AppTheme.heroPrimary.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              labelResolver: (line) =>
                                  l10n.chartGoal("${line.y.toStringAsFixed(1)}${l10n.unitKg}"),
                            ),
                          ),
                        ],
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            l10n.chartHours,
                            style: const TextStyle(
                              color: AppTheme.heroSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(
                              "${value.toInt()}${l10n.unitHoursShort}",
                              style: TextStyle(
                                color: AppTheme.heroSecondary.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          axisNameWidget: Text(
                            l10n.chartWeight,
                            style: const TextStyle(
                              color: AppTheme.heroPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                color: AppTheme.heroPrimary.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: _selectedDays > 7
                                ? (_selectedDays / 5).ceilToDouble()
                                : 1, // Динамический интервал для осей
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < dates.length) {
                                final date = dates[value.toInt()];
                                final format = _selectedDays == 7
                                    ? DateFormat('E')
                                    : DateFormat('d MMM');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    format.format(date),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        // Линия Часов Голодания
                        LineChartBarData(
                          spots: fastingSpots,
                          isCurved: true,
                          color: AppTheme.heroSecondary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.heroSecondary.withValues(alpha: 0.15),
                          ),
                        ),
                        // Линия Веса
                        LineChartBarData(
                          spots: weightSpots,
                          isCurved: true,
                          color: AppTheme.heroPrimary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: _selectedDays == 7,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: AppTheme.heroPrimary,
                                  strokeWidth: 2,
                                  strokeColor: AppTheme.premiumSurface,
                                ),
                          ),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Легенда
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(AppTheme.heroSecondary, l10n.chartLegendFasting),
                    const SizedBox(width: 24),
                    _buildLegendItem(AppTheme.heroPrimary, l10n.chartLegendWeight),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getDynamicInsight(AppLocalizations l10n) {
    if (_selectedDays == 7) {
      return l10n.chartInsight1W;
    } else if (_selectedDays == 30) {
      return l10n.chartInsight1M;
    } else {
      return l10n.chartInsight3M;
    }
  }
}