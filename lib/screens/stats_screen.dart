import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_record.dart';

class StatsScreen extends StatefulWidget {
  final HistoryRepository? repository;

  const StatsScreen({super.key, this.repository});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final WeightRepository _weightRepository = WeightRepository();
  late final HistoryRepository _historyRepository = widget.repository ?? HistoryRepository();

  List<FlSpot> _weightSpots = [];
  double _minY = 0;
  double _maxY = 100;

  // Данные для BarChart (дни недели)
  List<BarChartGroupData> _fastingBarGroups = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);

    // 1. ЗАГРУЗКА ВЕСА
    final weights = await _weightRepository.getWeightHistory();
    List<FlSpot> spots = [];
    if (weights.isNotEmpty) {
      weights.sort((a, b) => a.date.compareTo(b.date));
      final recentWeights = weights.length > 10 ? weights.sublist(weights.length - 10) : weights;
      for (int i = 0; i < recentWeights.length; i++) {
        spots.add(FlSpot(i.toDouble(), recentWeights[i].weight));
      }
      double minW = recentWeights.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
      double maxW = recentWeights.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
      _minY = minW - 2;
      _maxY = maxW + 2;
    }

    // 2. ЗАГРУЗКА ИСТОРИИ ГОЛОДАНИЙ (ПОСЛЕДНИЕ 7 ДНЕЙ)
    final records = await _historyRepository.loadRecords();
    _fastingBarGroups = _generateBarGroups(records);

    if (mounted) {
      setState(() {
        _weightSpots = spots;
        _isLoading = false;
      });
    }
  }

  // Логика группировки данных по дням недели
  List<BarChartGroupData> _generateBarGroups(List<FastingRecord> records) {
    List<double> dailyHours = List.filled(7, 0.0); // Пн, Вт, Ср...
    DateTime now = DateTime.now();

    // Определяем начало недели (Понедельник) относительно сегодня
    // Но для графика удобнее показывать "Последние 7 дней" от сегодня назад

    // Простой вариант: График показывает Пн-Вс текущей недели
    int currentDayOfWeek = now.weekday; // 1 = Mon, 7 = Sun
    DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day); // Обнуляем время

    for (var record in records) {
      if (record.startTime.isAfter(startOfWeek)) {
        int dayIndex = record.startTime.weekday - 1; // 0..6
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyHours[dayIndex] += record.duration.inMinutes / 60.0;
        }
      }
    }

    List<BarChartGroupData> groups = [];
    for (int i = 0; i < 7; i++) {
      double hours = dailyHours[i];
      // Максимум столбика для визуализации - 24 часа, но если больше, он просто упрется
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: hours,
              color: hours >= 16 ? const Color(0xFFFF4E50) : const Color(0xFF43C6AC), // Красный если >= 16ч, иначе Зеленый
              width: 12,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 20, // Высота фона
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navStats,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),

              // --- ГРАФИК ВЕСА ---
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.weightJourney, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(_weightSpots.isEmpty ? l10n.chartEmpty : l10n.last7Days, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 200,
                      child: _weightSpots.length < 2
                          ? Center(child: Text(l10n.chartEmpty, style: const TextStyle(color: Colors.white54)))
                          : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minY: _minY,
                          maxY: _maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _weightSpots,
                              isCurved: true,
                              color: const Color(0xFFF9D423),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFFFF4E50),
                                );
                              }),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF9D423).withOpacity(0.3),
                                    const Color(0xFFF9D423).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- ГРАФИК ГОЛОДАНИЯ (ИСПРАВЛЕННЫЙ) ---
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.fastingStats, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = ['M','T','W','T','F','S','S'];
                                  if (val.toInt() >= 0 && val.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(days[val.toInt()], style: const TextStyle(color: Colors.white70)),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          barGroups: _fastingBarGroups,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}