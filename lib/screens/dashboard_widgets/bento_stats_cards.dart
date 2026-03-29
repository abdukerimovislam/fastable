import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// FASTING PHASE (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoPhaseCard extends StatelessWidget {
  const BentoPhaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phase = context.select((FastingBloc b) => b.state.phase);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            phase == FastingPhase.fasting ? l10n.fastingPhase : l10n.eatingWindow,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.metricPhase,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STREAK (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoStreakCard extends StatelessWidget {
  const BentoStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak = context.select((HistoryBloc b) => b.state.currentStreak);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9D423).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: Color(0xFFF9D423), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.valStreakDays(streak),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.metricStreak,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BMI (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoBmiCard extends StatelessWidget {
  const BentoBmiCard({super.key});

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return Colors.greenAccent;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bmi = context.select((WeightBloc b) => b.state.bmi);
    final bmiColor = _getBMIColor(bmi);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bmiColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.health_and_safety_rounded, color: bmiColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            bmi.toStringAsFixed(1),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.bmiScore,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
