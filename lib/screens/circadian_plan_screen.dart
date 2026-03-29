import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/circadian_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/ui/app_layout.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';

class CircadianPlanScreen extends StatefulWidget {
  const CircadianPlanScreen({super.key});

  @override
  State<CircadianPlanScreen> createState() => _CircadianPlanScreenState();
}

class _CircadianPlanScreenState extends State<CircadianPlanScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, DateTime>? _sunTimes;

  @override
  void initState() {
    super.initState();
    _fetchSunTimes();
  }

  Future<void> _fetchSunTimes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final times = await getIt<CircadianService>().getAccurateSunTimes();

    if (mounted) {
      setState(() {
        _sunTimes = times;
        _isLoading = false;
        _hasError = times == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPro = context.select<ProBloc, bool>((bloc) => bloc.state.isPro);
    final intro = _parseIntroDescription(l10n.circadianIntroDesc);
    double theoreticalHours = 14.0;
    Duration exactDurationToSunrise = const Duration(hours: 14);
    Duration exactDurationToSunset = const Duration(hours: 4);
    DateTime displaySunrise = DateTime.now();
    DateTime displaySunset = DateTime.now();
    final now = DateTime.now();

    if (_sunTimes != null) {
      displaySunrise = _sunTimes!['sunrise']!;
      displaySunset = _sunTimes!['sunset']!;

      // Математика длительности (только для визуала)
      final theoreticalWindow = displaySunrise.difference(displaySunset);
      theoreticalHours = theoreticalWindow.inMinutes / 60.0;

      // ИДЕАЛЬНО ТОЧНОЕ время до рассвета
      exactDurationToSunrise = displaySunrise.difference(now);
      if (exactDurationToSunrise.isNegative) {
        exactDurationToSunrise = const Duration(minutes: 1);
      }

      exactDurationToSunset = displaySunset.difference(now);
      if (exactDurationToSunset.isNegative) {
        exactDurationToSunset = const Duration(minutes: 1);
      }
    }

    final isDaytime = displaySunset.isAfter(now);
    final nextTargetLabel = isDaytime
        ? l10n.circadianTargetSunset
        : l10n.circadianTargetSunrise;
    final nextTargetDuration = isDaytime
        ? exactDurationToSunset
        : exactDurationToSunrise;
    final edgePadding = AppLayout.edgePadding(context);
    final cardPadding = AppLayout.cardPadding(context);
    final sectionGap = AppLayout.sectionGap(context);

    return MeshBackground(
      isFasting: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            l10n.circadianTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: edgePadding,
              vertical: 14,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(
                          l10n: l10n,
                          intro: intro,
                          isDaytime: isDaytime,
                          nextTargetLabel: nextTargetLabel,
                          nextTargetDuration: nextTargetDuration,
                        ),
                        const SizedBox(height: 16),
                        GlassCard(
                          padding: EdgeInsets.all(cardPadding),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.amber,
                                    ),
                                  ),
                                )
                              : _hasError
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: _buildErrorState(),
                                )
                              : _buildSunWindowCard(
                                  sunrise: displaySunrise,
                                  sunset: displaySunset,
                                  theoreticalHours: theoreticalHours,
                                ),
                        ),
                        const SizedBox(height: 16),
                        _buildHowItWorksCard(l10n: l10n, intro: intro),
                        SizedBox(height: sectionGap + 6),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: sectionGap + 2),

                ElevatedButton(
                  onPressed: _isLoading || _hasError
                      ? null
                      : () => _handlePrimaryAction(
                          isPro: isPro,
                          isDaytime: isDaytime,
                          exactDurationToSunrise: exactDurationToSunrise,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPro ? Colors.amber : Colors.purpleAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.amber.withValues(alpha: 0.5),
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.12,
                    ),
                    disabledForegroundColor: Colors.white54,
                  ),
                  child: Text(
                    (isPro ? l10n.circadianStartFast : l10n.btnUnlockPro)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required AppLocalizations l10n,
    required _CircadianIntroContent intro,
    required bool isDaytime,
    required String nextTargetLabel,
    required Duration nextTargetDuration,
  }) {
    final accentColor = isDaytime ? Colors.orangeAccent : Colors.amber;

    return GlassCard(
      padding: EdgeInsets.all(AppLayout.cardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderChip(
                icon: Icons.star_rounded,
                label: l10n.circadianProExclusive,
                color: Colors.amber,
              ),
              _buildHeaderChip(
                icon: isDaytime
                    ? Icons.light_mode_rounded
                    : Icons.nightlight_round,
                label: isDaytime
                    ? l10n.circadianPhaseDay
                    : l10n.circadianPhaseNight,
                color: isDaytime ? Colors.orangeAccent : Colors.lightBlueAccent,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.circadianIntroTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          if (intro.summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              intro.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            nextTargetLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDurationLabel(nextTargetDuration),
            style: TextStyle(
              color: accentColor,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              isDaytime
                  ? l10n.circadianWarnDayDesc
                  : (intro.footer?.isNotEmpty ?? false)
                  ? intro.footer!
                  : l10n.basedOnLocalCoordinates,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunWindowCard({
    required DateTime sunrise,
    required DateTime sunset,
    required double theoreticalHours,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat('HH:mm');
    final totalHoursLabel =
        theoreticalHours.truncateToDouble() == theoreticalHours
        ? theoreticalHours.toStringAsFixed(0)
        : theoreticalHours.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.circadianManaged,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTimeMetric(
              icon: Icons.wb_sunny_rounded,
              color: Colors.orangeAccent,
              title: l10n.sunriseLabel,
              time: format.format(sunrise),
              subtitle: l10n.targetGoal,
            ),
            _buildTimeMetric(
              icon: Icons.nights_stay_rounded,
              color: Colors.indigoAccent,
              title: l10n.sunsetLabel,
              time: format.format(sunset),
              subtitle: l10n.lastMeal,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 16),
        Text(
          l10n.circadianTotalWindow,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalHoursLabel,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l10n.hoursLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.basedOnLocalCoordinates,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeMetric({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String subtitle,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 135, maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard({
    required AppLocalizations l10n,
    required _CircadianIntroContent intro,
  }) {
    final icons = <IconData>[
      Icons.water_drop_rounded,
      Icons.wb_sunny_outlined,
      Icons.wb_twilight_rounded,
      Icons.nightlight_round,
    ];

    return GlassCard(
      padding: EdgeInsets.all(AppLayout.cardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.circadianManaged,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(intro.points.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == intro.points.length - 1 ? 0 : 12,
              ),
              child: _buildInfoRow(
                icon: icons[index % icons.length],
                text: intro.points[index],
              ),
            );
          }),
          if (intro.points.isEmpty && (intro.footer?.isNotEmpty ?? false))
            Text(
              intro.footer!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 14,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.amber, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  _CircadianIntroContent _parseIntroDescription(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String summary = '';
    final points = <String>[];
    final footerLines = <String>[];

    for (final line in lines) {
      if (line.startsWith('•')) {
        points.add(line.replaceFirst('•', '').trim());
        continue;
      }

      if (summary.isEmpty) {
        summary = line;
      } else {
        footerLines.add(line);
      }
    }

    return _CircadianIntroContent(
      summary: summary,
      points: points,
      footer: footerLines.isEmpty ? null : footerLines.join(' '),
    );
  }

  String _formatDurationLabel(Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    final totalMinutes = duration.inMinutes <= 0 ? 1 : duration.inMinutes;
    return l10n.durationHoursMinutesShort(
      totalMinutes ~/ 60,
      totalMinutes % 60,
    );
  }

  Future<void> _handlePrimaryAction({
    required bool isPro,
    required bool isDaytime,
    required Duration exactDurationToSunrise,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    getIt<HapticService>().mediumImpact();

    if (!isPro) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProScreen()),
      );
      return;
    }

    final fastingState = context.read<FastingBloc>().state;
    if (fastingState.phase != FastingPhase.stopped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.endFastPrompt),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isDaytime) {
      final shouldStartAnyway = await _showDaytimeWarning();
      if (!mounted || shouldStartAnyway != true) {
        return;
      }
    }

    context.read<FastingBloc>().add(StartCircadianFast(exactDurationToSunrise));
    Navigator.of(context).pop(true);
  }

  Future<bool?> _showDaytimeWarning() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181A24),
          title: Text(
            l10n.circadianWarnDayTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            l10n.circadianWarnDayDesc,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.circadianWarnBtnWait),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.circadianWarnBtnStart),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_off_rounded, color: Colors.white54, size: 60),
        const SizedBox(height: 16),
        Text(
          l10n.locationRequiredTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.locationRequiredDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _fetchSunTimes,
          icon: const Icon(Icons.refresh_rounded, color: Colors.amber),
          label: Text(
            l10n.tryAgain,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircadianIntroContent {
  const _CircadianIntroContent({
    required this.summary,
    required this.points,
    required this.footer,
  });

  final String summary;
  final List<String> points;
  final String? footer;
}
