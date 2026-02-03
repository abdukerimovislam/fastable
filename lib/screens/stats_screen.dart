import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_event.dart';
import 'package:fastable/bloc/stats/stats_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/repositories/history_repository.dart';

class StatsScreen extends StatelessWidget {
  final HistoryRepository repository;

  const StatsScreen({super.key, required this.repository});

  Color _getRateColor(double rate) {
    if (rate >= 80) return Colors.greenAccent;
    if (rate >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<StatsBloc>()..add(LoadStats()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              if (state.status == StatsStatus.loading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              // Вычисляем успех для текста
              final successCount = (state.totalFasts * (state.successRate / 100)).round();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.navStats,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // 1. SUCCESS RATE CARD
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 80, width: 80,
                            child: Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 80, height: 80,
                                    child: CircularProgressIndicator(
                                      value: state.successRate / 100,
                                      backgroundColor: Colors.white10,
                                      color: _getRateColor(state.successRate),
                                      strokeWidth: 8,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${state.successRate.toInt()}%",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.statsSuccessRate,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.totalFasts > 0
                                      ? l10n.statsSuccessDesc(successCount, state.totalFasts)
                                      : "Start your first fast!", // Фолбэк, если ключа нет
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. ГРАФИК
                    Text(
                      "History Trend", // Этот ключ пока оставим хардкодом (нет в arb)
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      height: 200,
                      padding: const EdgeInsets.fromLTRB(16, 24, 24, 0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: state.maxChartValue,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              // FIX: Исправлено имя параметра для новой версии fl_chart
                              tooltipBgColor: const Color(0xFF1E1E1E),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  "${rod.toY.toStringAsFixed(1)} h",
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final now = DateTime.now();
                                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                                  final dayName = DateFormat.E().format(date)[0];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(dayName, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: state.weeklyChartData.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: e.value >= 16 ? const Color(0xFF43C6AC) : Colors.blueAccent.withOpacity(0.7),
                                  width: 12,
                                  borderRadius: BorderRadius.circular(4),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: state.maxChartValue,
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. СЕТКА СТАТИСТИКИ
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(l10n.statsTotalFasts, "${state.totalFasts}", Icons.check_circle_outline, Colors.blueAccent)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard(l10n.statsTotalHours, state.totalHours.toStringAsFixed(1), Icons.access_time, Colors.purpleAccent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(l10n.statsAverage, "${state.averageDuration.toStringAsFixed(1)} h", Icons.functions, Colors.orangeAccent)),
                        const SizedBox(width: 12),
                        // Используем fastingStatsCurrentStreak вместо currentStreak
                        Expanded(child: _buildStatCard(l10n.fastingStatsCurrentStreak, "${state.currentStreak}", Icons.local_fire_department, Colors.redAccent)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Pro Banner
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Detailed Analysis & Trends available in Pro", style: TextStyle(color: Colors.white70, fontSize: 13))),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                      ]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }
}