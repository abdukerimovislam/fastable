import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fastable/l10n/app_localizations.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.medicalDisclaimerTitle,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.health_and_safety, color: Colors.amber, size: 60),
          const SizedBox(height: 20),
          Text(
            l10n.medicalDisclaimerHeading,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.medicalDisclaimerBody,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 30),
          Text(
            l10n.scientificSourcesHeading,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSourceLink(
            l10n.sourceJohnsHopkins,
            l10n.sourceJohnsHopkinsDesc,
            "https://www.hopkinsmedicine.org/health/wellness-and-prevention/intermittent-fasting-what-is-it-and-how-does-it-work",
          ),
          _buildSourceLink(
            l10n.sourceMayoClinic,
            l10n.sourceMayoClinicDesc,
            "https://www.mayoclinic.org/diseases-conditions/heart-disease/expert-answers/fasting-diet/faq-20058334",
          ),
          _buildSourceLink(
            l10n.sourceHarvard,
            l10n.sourceHarvardDesc,
            "https://www.health.harvard.edu/blog/intermittent-fasting-surprising-update-2018062914156",
          ),
        ],
      ),
    );
  }

  Widget _buildSourceLink(String title, String subtitle, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: const Icon(Icons.open_in_new, color: Colors.white24, size: 16),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}