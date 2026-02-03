import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

// --- DI & BLOCS ---
import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

// --- WIDGETS ---
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 20),
                child: Text(
                  l10n.navStats,
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),

              // 1. БЛОК МЕТАБОЛИЗМА (ОБНОВЛЕННЫЙ)
              _buildMetabolicCard(context, l10n),

              const SizedBox(height: 24),
              _sectionHeader(l10n.fastingPhase), // Используем заголовок как "Fasting Stats"

              // 2. ОБЩАЯ СТАТИСТИКА ГОЛОДАНИЯ
              BlocBuilder<StatsBloc, StatsState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          title: l10n.statsTotalFasts,
                          value: "${state.totalFasts}",
                          icon: Icons.check_circle_outline,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          title: l10n.statsTotalHours,
                          value: "${state.totalHours.toStringAsFixed(1)} h",
                          icon: Icons.access_time,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // 3. ДОЛГАЯ СЕРИЯ (STREAK)
              BlocBuilder<StatsBloc, StatsState>(
                builder: (context, state) {
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.fastingStatsCurrentStreak, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            Text("${state.currentStreak} ${l10n.valStreakDays(state.currentStreak).replaceAll(RegExp(r'[0-9]'), '').trim()}",
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 100), // Отступ для нижнего меню
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMetabolicCard(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        Color bmiColor = Colors.greenAccent;
        String bmiStatus = l10n.bmiNormal;

        if (state.bmi < 18.5) {
          bmiColor = Colors.blueAccent;
          bmiStatus = l10n.bmiUnderweight;
        } else if (state.bmi >= 25 && state.bmi < 30) {
          bmiColor = Colors.orangeAccent;
          bmiStatus = l10n.bmiOverweight;
        } else if (state.bmi >= 30) {
          bmiColor = Colors.redAccent;
          bmiStatus = l10n.bmiObese;
        }

        return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.metabolicProfile,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showMetabolicInfo(context, l10n),
                          child: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5), size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: Text(l10n.ageYears(state.age), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // BMI Section
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("BMI", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(state.bmi.toStringAsFixed(1), style: TextStyle(color: bmiColor, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bmiStatus,
                          style: TextStyle(color: bmiColor, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (state.bmi / 40).clamp(0.0, 1.0),
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(bmiColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(color: Colors.white10, height: 24),

              // BMR & TDEE (Basal -> Maintenance)
              Row(
                children: [
                  _buildMiniMetric(l10n.metricBmrTitle, "${state.bmr.toInt()}", "kcal", l10n.metricBmrSubtitle, Colors.blueAccent.withOpacity(0.8)),
                  Container(width: 1, height: 40, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 16)),
                  _buildMiniMetric(l10n.metricTdeeTitle, "${state.tdee.toInt()}", "kcal", l10n.metricTdeeSubtitle, Colors.greenAccent.withOpacity(0.8)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Обновленный виджет мини-метрики с поддержкой цвета для лейбла
  Widget _buildMiniMetric(String title, String value, String unit, String subtitle, Color subtitleColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              // Бейджик "Basal" / "Maintenance"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: subtitleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: subtitleColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(color: subtitleColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showMetabolicInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.metabolicProfile, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n.metricBmrTitle, l10n.metricBmrDesc),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.metricTdeeTitle, l10n.metricTdeeDesc),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnGotIt, style: const TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  

  Widget _buildStatItem({required String title, required String value, required IconData icon, required Color color}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }
}