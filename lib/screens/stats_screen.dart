import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

class StatsScreen extends StatefulWidget {
  final HistoryRepository repository;

  const StatsScreen({super.key, required this.repository});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<FastingRecord> _records = [];

  // Инсайты
  String _insightText = "Analyzing data...";
  bool _isPositiveTrend = false;

  // Статистика для карточек
  double _successRate = 0;
  Duration _longestFast = Duration.zero;
  int _totalFasts = 0;

  // Данные для графика (7 дней)
  List<double> _weeklyFastingHours = List.filled(7, 0.0);
  final double _targetHours = 16.0; // Цель для расчета успеха

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await widget.repository.loadRecords();

    if (mounted) {
      setState(() {
        _records = records;
        _calculateStats(records);
        _prepareWeeklyData(records);
      });
    }
  }

  void _calculateStats(List<FastingRecord> records) {
    if (records.isEmpty) {
      _insightText = "Complete your first fast to see stats!";
      return;
    }

    _totalFasts = records.length;

    // 1. Расчет Success Rate (процент голоданий >= 16 часов)
    int successCount = records.where((r) => r.duration.inHours >= 16).length;
    _successRate = _totalFasts > 0 ? (successCount / _totalFasts) * 100 : 0;

    // 2. Расчет Longest Fast (Рекорд)
    if (records.isNotEmpty) {
      // Находим макс. длительность
      _longestFast = records.map((r) => r.duration).reduce((a, b) => a > b ? a : b);
    }

    // 3. Инсайт (Сравнение с прошлой неделей)
    final now = DateTime.now();
    final startThisWeek = now.subtract(Duration(days: now.weekday - 1)); // Понедельник
    final startLastWeek = startThisWeek.subtract(const Duration(days: 7));

    double thisWeekSum = 0;
    int thisWeekCount = 0;
    double lastWeekSum = 0;
    int lastWeekCount = 0;

    for (var r in records) {
      final hours = r.duration.inHours + (r.duration.inMinutes.remainder(60) / 60);
      if (r.endTime.isAfter(startThisWeek)) {
        thisWeekSum += hours;
        thisWeekCount++;
      } else if (r.endTime.isAfter(startLastWeek) && r.endTime.isBefore(startThisWeek)) {
        lastWeekSum += hours;
        lastWeekCount++;
      }
    }

    double avgThis = thisWeekCount > 0 ? thisWeekSum / thisWeekCount : 0;
    double avgLast = lastWeekCount > 0 ? lastWeekSum / lastWeekCount : 0;

    if (thisWeekCount == 0) {
      _insightText = "Start fasting this week to get insights.";
      _isPositiveTrend = false;
    } else if (avgThis >= avgLast) {
      double diff = avgThis - avgLast;
      _insightText = avgLast == 0
          ? "Great start! Avg duration: ${avgThis.toStringAsFixed(1)}h"
          : "Trending up! +${diff.toStringAsFixed(1)}h vs last week 🚀";
      _isPositiveTrend = true;
    } else {
      double diff = avgLast - avgThis;
      _insightText = "Avg duration down by ${diff.toStringAsFixed(1)}h. You got this!";
      _isPositiveTrend = false;
    }
  }

  void _prepareWeeklyData(List<FastingRecord> records) {
    final now = DateTime.now();
    List<double> tempWeek = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dailyRecords = records.where((r) =>
      r.endTime.year == date.year &&
          r.endTime.month == date.month &&
          r.endTime.day == date.day
      );

      double totalHours = 0;
      for (var r in dailyRecords) {
        totalHours += r.duration.inHours + (r.duration.inMinutes.remainder(60) / 60);
      }
      tempWeek[i] = totalHours;
    }
    _weeklyFastingHours = tempWeek;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 4),
                  child: Text(
                    l10n.navStats,
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),

                // 1. INSIGHT CARD
                GlassCard(
                  color: _isPositiveTrend
                      ? const Color(0xFF00FA9A).withOpacity(0.1)
                      : Colors.white.withOpacity(0.08),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isPositiveTrend ? const Color(0xFF00FA9A).withOpacity(0.2) : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPositiveTrend ? Icons.trending_up : Icons.tips_and_updates,
                          color: _isPositiveTrend ? const Color(0xFF00FA9A) : Colors.white70,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Performance Insight",
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _insightText,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. CHART
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text("Last 7 Days", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 220,
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF1E1E1E),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                "${rod.toY.toStringAsFixed(1)}h",
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final dayIndex = 6 - value.toInt();
                                final date = DateTime.now().subtract(Duration(days: dayIndex));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat.E().format(date)[0],
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 12, // Линии каждые 12 часов
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        barGroups: _weeklyFastingHours.asMap().entries.map((e) {
                          final index = e.key;
                          final value = e.value;
                          final isTargetMet = value >= _targetHours;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                color: isTargetMet ? Colors.amber : Colors.white24,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 24,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. НОВЫЕ ПЛИТКИ (Success Rate & Longest Fast)
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        title: "Success Rate",
                        value: "${_successRate.toInt()}%",
                        icon: Icons.check_circle_outline,
                        color: Colors.greenAccent,
                        subText: "Target: 16h",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStatCard(
                        title: "Longest Fast",
                        value: "${_longestFast.inHours}h ${_longestFast.inMinutes.remainder(60)}m",
                        icon: Icons.emoji_events_outlined,
                        color: Colors.amberAccent,
                        subText: "Personal Best",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subText,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              if (subText != null)
              // Маленький бейдж справа сверху (опционально)
                Container()
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
          if (subText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subText, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
            ),
        ],
      ),
    );
  }
}