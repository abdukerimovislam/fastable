import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/injection.dart'; // Для getIt
import 'package:fastable/repositories/history_repository.dart'; // Для репозитория

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Фаза голодания
    final phase = context.select((FastingBloc b) => b.state.phase);
    // BMI (ИМТ)
    final bmi = context.select((WeightBloc b) => b.state.bmi);

    final bmiStr = bmi.toStringAsFixed(1);
    final bmiColor = _getBMIColor(bmi);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. PHASE
          _buildInfoItem(
            icon: Icons.local_fire_department_rounded,
            color: Colors.orangeAccent,
            label: l10n.metricPhase,
            value: phase == FastingPhase.fasting ? l10n.fastingPhase : l10n.eatingWindow,
          ),

          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),

          // 2. STREAK (ТЕПЕРЬ ЖИВОЙ)
          // Используем FutureBuilder, чтобы загрузить стрик из базы
          FutureBuilder<int>(
            future: getIt<HistoryRepository>().calculateStreak(),
            initialData: 0,
            builder: (context, snapshot) {
              final streak = snapshot.data ?? 0;
              return _buildInfoItem(
                icon: Icons.bolt_rounded,
                color: const Color(0xFFF9D423),
                label: l10n.metricStreak,
                value: l10n.valStreakDays(streak), // Используем реальное значение
              );
            },
          ),

          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),

          // 3. BMI
          _buildInfoItem(
            icon: Icons.health_and_safety_rounded,
            color: bmiColor,
            label: l10n.bmiScore,
            value: bmiStr,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required Color color, required String label, required String value}) {
    return Expanded(
        child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10))
            ]
        )
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return Colors.greenAccent;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}