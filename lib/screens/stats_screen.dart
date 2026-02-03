import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Core & DI
import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';

// BLoC
import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_event.dart';
import 'package:fastable/bloc/stats/stats_state.dart';

// UI Components
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/screens/pro_screen.dart';

class StatsScreen extends StatelessWidget {
  final HistoryRepository repository;

  const StatsScreen({super.key, required this.repository});

  Color _getRateColor(double rate) {
    if (rate >= 80) return const Color(0xFF43C6AC); // Изумрудный
    if (rate >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();

    return BlocProvider(
      create: (_) => getIt<StatsBloc>()..add(LoadStats()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<StatsBloc, StatsState>(
            builder: (context, state) {
              if (state.status == StatsStatus.loading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white24));
              }

              final successCount = (state.totalFasts * (state.successRate / 100)).round();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.navStats,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // 1. КАРТОЧКА УСПЕХА (БОЛЬШАЯ)
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          _buildCircularIndicator(state.successRate),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.statsSuccessRate,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  state.totalFasts > 0
                                      ? l10n.statsSuccessDesc(successCount, state.totalFasts)
                                      : "Start your journey today!",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2. ГРАФИК АКТИВНОСТИ
                    const Text(
                      "7-DAY ACTIVITY",
                      style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      height: 240,
                      padding: const EdgeInsets.fromLTRB(10, 24, 16, 8),
                      child: BarChart(
                        _mainBarData(state),
                        swapAnimationDuration: const Duration(milliseconds: 400),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. СЕТКА СТАТИСТИКИ (2x2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildMetricCard(l10n.statsTotalFasts, "${state.totalFasts}", Icons.check_circle_rounded, Colors.blueAccent),
                        _buildMetricCard(l10n.statsTotalHours, "${state.totalHours.toInt()}h", Icons.timer_rounded, Colors.purpleAccent),
                        _buildMetricCard(l10n.statsAverage, "${state.averageDuration.toStringAsFixed(1)}h", Icons.analytics_rounded, Colors.orangeAccent),
                        _buildMetricCard(l10n.fastingStatsCurrentStreak, "${state.currentStreak}d", Icons.local_fire_department_rounded, Colors.redAccent),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 4. PRO BANNER (Стейкхолдер для удержания)
                    _buildProBanner(context, haptic),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(double rate) {
    return SizedBox(
      height: 84, width: 84,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 84, height: 84,
              child: CircularProgressIndicator(
                value: rate / 100,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: _getRateColor(rate),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Center(
            child: Text(
              "${rate.toInt()}%",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _mainBarData(StatsState state) {
    return BarChartData(
      maxY: (state.maxChartValue < 24) ? 24 : state.maxChartValue,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: const Color(0xFF1E1E1E),
          tooltipRoundedRadius: 12,
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
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final now = DateTime.now();
              final date = now.subtract(Duration(days: 6 - value.toInt()));
              final dayName = DateFormat.E().format(date)[0]; // Первая буква дня
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(dayName, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: state.weeklyChartData.asMap().entries.map((e) {
        final isSuccess = e.value >= 16;
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              gradient: LinearGradient(
                colors: isSuccess
                    ? [const Color(0xFF43C6AC), const Color(0xFF191654)] // Успех
                    : [Colors.blueAccent, Colors.blueAccent.withOpacity(0.5)], // В процессе
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 24,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProBanner(BuildContext context, HapticService haptic) {
    return GestureDetector(
      onTap: () {
        haptic.selectionClick();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
      },
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.auto_graph_rounded, color: Colors.amberAccent),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Deep Analytics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text("Monthly trends & correlation data", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}