import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// --- DI & BLOCS ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

// --- SERVICES ---
import 'package:fastable/services/haptic_service.dart';

// --- WIDGETS ---
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/pro_correlation_chart.dart'; // 🔥 ИМПОРТ НАШЕГО ГРАФИКА
import 'package:fastable/ui/app_layout.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // Хелпер для перевода пола
  String _getGenderName(Gender gender, AppLocalizations l10n) {
    return gender == Gender.male ? l10n.genderMale : l10n.genderFemale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();
    final sectionGap = AppLayout.sectionGap(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: AnimationLimiter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppLayout.screenPadding(context, top: 18, bottom: 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 40.0,
                  curve: Curves.easeOutCubic,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
              // ЗАГОЛОВОК
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                child: Text(
                  l10n.navStats,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // 1. ГЛАВНАЯ КАРТОЧКА: BMI & ВЕС
              _buildBodyCompositionCard(context, l10n, haptic),

              SizedBox(height: sectionGap),

              // 2. ЭНЕРГИЯ (BMR / TDEE)
              _buildEnergyCard(context, l10n),

              SizedBox(height: sectionGap + 10),
              _sectionHeader("INSIGHTS & TRENDS"),

              // 🔥 3. НАШ НОВЫЙ PRO-ГРАФИК (Advanced Charts)
              const ProCorrelationChart(),

              SizedBox(height: sectionGap + 10),
              _sectionHeader(l10n.fastingPhase),

              // 4. СТАТИСТИКА ГОЛОДАНИЯ
              BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  return _buildFastingRingsCard(context, state, l10n);
                },
              ),

              const SizedBox(height: 12),
              ],
             ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildBodyCompositionCard(
    BuildContext context,
    AppLocalizations l10n,
    HapticService haptic,
  ) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        Color bmiColor = const Color(0xFF43C6AC); // Green/Teal
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
          padding: EdgeInsets.all(AppLayout.cardPadding(context)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.metabolicProfile,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${state.age} y.o • ${_getGenderName(state.gender, l10n).toUpperCase()}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      haptic.selectionClick();
                      _showMetabolicInfo(context, l10n);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Circular BMI Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: (state.bmi / 40).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          color: bmiColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "BMI",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.bmi.toStringAsFixed(1),
                            style: TextStyle(
                              color: bmiColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Weight & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lblCurrentWeight,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                state.currentWeight.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.unitKg,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bmiColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: bmiColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            bmiStatus,
                            style: TextStyle(
                              color: bmiColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnergyCard(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        return GlassCard(
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.cardPadding(context),
            vertical: AppLayout.compactCardPadding(context),
          ),
          child: Row(
            children: [
              _buildEnergyItem(
                l10n.lblBasalBmr,
                "${state.bmr.toInt()}",
                l10n.unitKcal,
                Colors.blueAccent,
                Icons.bed_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white10,
                margin: EdgeInsets.symmetric(
                  horizontal: AppLayout.cardPadding(context),
                ),
              ),
              _buildEnergyItem(
                l10n.lblActiveTdee,
                "${state.tdee.toInt()}",
                l10n.unitKcal,
                Colors.greenAccent,
                Icons.directions_run_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnergyItem(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingRingsCard(BuildContext context, HistoryState state, AppLocalizations l10n) {
    final streak = state.currentStreak;
    final totalFasts = state.records.length;
    final totalHours = state.totalFastingTime.inHours;

    // Outer ring: Streak (max 30 days)
    final double p1 = streak > 0 ? (streak / 30).clamp(0.05, 1.0) : 0.0;
    const Color c1 = Color(0xFFFF2A5F); // Pink/Red

    // Middle ring: Total Fasts (max 50)
    final double p2 = totalFasts > 0 ? (totalFasts / 50).clamp(0.05, 1.0) : 0.0;
    const Color c2 = Color(0xFFB5FF00); // Neon Green

    // Inner ring: Total Hours (max 500)
    final double p3 = totalHours > 0 ? (totalHours / 500).clamp(0.05, 1.0) : 0.0;
    const Color c3 = Color(0xFF00E5FF); // Cyan

    return GlassCard(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: AppLayout.cardPadding(context)),
      child: Row(
        children: [
          // THE RINGS
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background rings
                SizedBox(width: 130, height: 130, child: CircularProgressIndicator(value: 1, strokeWidth: 12, color: c1.withValues(alpha: 0.15))),
                SizedBox(width: 98, height: 98, child: CircularProgressIndicator(value: 1, strokeWidth: 12, color: c2.withValues(alpha: 0.15))),
                SizedBox(width: 66, height: 66, child: CircularProgressIndicator(value: 1, strokeWidth: 12, color: c3.withValues(alpha: 0.15))),
                
                // Foreground rings
                SizedBox(
                  width: 130, height: 130,
                  child: CircularProgressIndicator(value: p1, strokeWidth: 12, color: c1, strokeCap: StrokeCap.round),
                ),
                SizedBox(
                  width: 98, height: 98,
                  child: CircularProgressIndicator(value: p2, strokeWidth: 12, color: c2, strokeCap: StrokeCap.round),
                ),
                SizedBox(
                  width: 66, height: 66,
                  child: CircularProgressIndicator(value: p3, strokeWidth: 12, color: c3, strokeCap: StrokeCap.round),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          
          // LEGEND
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRingLegend(
                  color: c1,
                  title: l10n.fastingStatsCurrentStreak,
                  value: "$streak",
                  unit: l10n.valStreakDays(streak).replaceAll(RegExp(r'[0-9]'), '').trim(),
                ),
                const SizedBox(height: 16),
                _buildRingLegend(
                  color: c2,
                  title: l10n.statsTotalFasts,
                  value: "$totalFasts",
                ),
                const SizedBox(height: 16),
                _buildRingLegend(
                  color: c3,
                  title: l10n.lblTotalHours,
                  value: "$totalHours",
                  unit: l10n.unitHoursShort,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingLegend({required Color color, required String title, required String value, String? unit}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 4, right: 10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.2),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showMetabolicInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.metabolicProfile,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              l10n.metricBmrTitle,
              l10n.metricBmrDesc,
              Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              l10n.metricTdeeTitle,
              l10n.metricTdeeDesc,
              Colors.greenAccent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.btnGotIt,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
