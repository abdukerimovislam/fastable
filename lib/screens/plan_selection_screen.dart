import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/fasting_plan.dart';

class PlanSelectionScreen extends StatelessWidget {
  PlanSelectionScreen({super.key});

  // Define our list of available fasting plans
  final List<FastingPlan> plans = [
    FastingPlan(
      duration: const Duration(hours: 16),
      translationKey: "fastingPlan16_8",
    ),
    FastingPlan(
      duration: const Duration(hours: 18),
      translationKey: "fastingPlan18_6",
    ),
    FastingPlan(
      duration: const Duration(hours: 20),
      translationKey: "fastingPlan20_4",
    ),
    FastingPlan(
      duration: const Duration(hours: 24),
      translationKey: "fastingPlanEatStopEat",
    ),
  ];

  // A helper function to get the translated string from a key
  String _getTranslatedName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "fastingPlan16_8":
        return l10n.fastingPlan16_8;
      case "fastingPlan18_6":
        return l10n.fastingPlan18_6;
      case "fastingPlan20_4":
        return l10n.fastingPlan20_4;
      case "fastingPlanEatStopEat":
        return l10n.fastingPlanEatStopEat;
      default:
        return "Unknown Plan";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.choosePlan),
      ),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];

          return Card( // We use Card for a modern, elevated look
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                _getTranslatedName(context, plan.translationKey),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${plan.duration.inHours} ${plan.duration.inHours == 1 ? 'Hour' : 'Hours'}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // This is where the magic happens!
                // We "pop" the screen and send the selected plan's data back.
                Navigator.of(context).pop(plan);
              },
            ),
          );
        },
      ),
    );
  }
}