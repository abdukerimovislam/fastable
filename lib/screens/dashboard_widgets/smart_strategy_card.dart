import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/onboarding_personalization.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/ui/app_layout.dart';

class SmartStrategyCard extends StatelessWidget {
  final AppLocalizations l10n;
  final OnboardingPersonalizationSnapshot personalization;

  const SmartStrategyCard({
    super.key,
    required this.l10n,
    required this.personalization,
  });

  Widget _buildSignalChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!personalization.hasCompletedOnboarding) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: EdgeInsets.all(AppLayout.compactCardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.smartPlanDashboardTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            personalization.localizedCurrentPlan(l10n),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            personalization.localizedReason(l10n),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (personalization.localizedCurrentPlan(l10n) !=
              personalization.localizedRecommendedPlan()) ...[
            const SizedBox(height: 10),
            Text(
              "${l10n.smartPlanRecommendedPlanLabel}: ${personalization.localizedRecommendedPlan()}",
              style: TextStyle(
                color: Colors.amber.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSignalChip(
                personalization.localizedGoal(l10n),
                Colors.greenAccent,
              ),
              _buildSignalChip(
                personalization.localizedExperience(l10n),
                Colors.blueAccent,
              ),
              _buildSignalChip(
                personalization.localizedSleepPattern(l10n),
                Colors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
