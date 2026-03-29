import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

// Общая логика загрузки для данных здоровья
class BentoHealthCards extends StatefulWidget {
  final Widget Function(
    BuildContext context, 
    bool isLoading, 
    bool isConnected, 
    Duration? sleepDuration, 
    int? daysSinceMenstruation,
    VoidCallback onRefresh,
  ) builder;

  const BentoHealthCards({super.key, required this.builder});

  @override
  State<BentoHealthCards> createState() => _BentoHealthCardsState();
}

class _BentoHealthCardsState extends State<BentoHealthCards> {
  final HealthService _healthService = getIt<HealthService>();
  Duration? _sleepDuration;
  int? _daysSinceMenstruation;
  bool _isLoading = true;
  bool _isHealthConnected = false;

  @override
  void initState() {
    super.initState();
    _checkHealthStatus();
  }

  Future<void> _checkHealthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isHealthConnected = await HealthSyncPreferences.isEnabled(prefs);

    if (_isHealthConnected) {
      await _refreshData(triggerHaptic: false, allowPermissionRequest: false);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData({bool triggerHaptic = true, bool allowPermissionRequest = true}) async {
    if (mounted) setState(() => _isLoading = true);
    if (triggerHaptic) getIt<HapticService>().selectionClick();

    if (!_isHealthConnected && allowPermissionRequest) {
      final granted = await _healthService.requestPermissions();
      if (granted) {
        final prefs = await SharedPreferences.getInstance();
        await HealthSyncPreferences.setEnabled(true, prefs);
        _isHealthConnected = true;
        if (mounted) {
          context.read<SettingsBloc>().add(const ToggleHealthSync(true, requestPermissions: false));
        }
      }
    }

    if (_isHealthConnected) {
      try {
        final sleep = await _healthService.getLastNightSleep();
        final menstruation = await _healthService.getDaysSinceLastMenstruation();
        if (mounted) {
          setState(() {
            _sleepDuration = (sleep.inMinutes > 0) ? sleep : null;
            _daysSinceMenstruation = menstruation;
          });
        }
      } catch (e) {
        final prefs = await SharedPreferences.getInstance();
        await HealthSyncPreferences.setEnabled(false, prefs);
        if (mounted) {
          context.read<SettingsBloc>().add(const ToggleHealthSync(false, requestPermissions: false));
          setState(() {
            _isHealthConnected = false;
            _sleepDuration = null;
            _daysSinceMenstruation = null;
          });
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _syncWithSettings(bool isEnabled) {
    if (!isEnabled) {
      setState(() {
        _isHealthConnected = false;
        _isLoading = false;
        _sleepDuration = null;
        _daysSinceMenstruation = null;
      });
      return;
    }
    _isHealthConnected = true;
    _refreshData(triggerHaptic: false, allowPermissionRequest: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) => prev.isHealthSyncEnabled != curr.isHealthSyncEnabled,
      listener: (context, state) => _syncWithSettings(state.isHealthSyncEnabled),
      child: widget.builder(context, _isLoading, _isHealthConnected, _sleepDuration, _daysSinceMenstruation, _refreshData),
    );
  }
}

// ---------------------------------------------------------------------------
// SLEEP (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoSleepCard extends StatelessWidget {
  final bool isLoading;
  final bool isConnected;
  final Duration? sleepDuration;
  final VoidCallback onTap;

  const BentoSleepCard({
    super.key,
    required this.isLoading,
    required this.isConnected,
    required this.sleepDuration,
    required this.onTap,
  });

  String _formatSleep(Duration d, AppLocalizations l10n) => "${d.inHours}${l10n.unitHoursShort} ${d.inMinutes % 60}${l10n.unitMin}";

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) return GlassCard(child: const Center(child: CircularProgressIndicator(color: Colors.white54)));

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      color: isConnected ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
      child: Column(
        children: [
          Icon(Icons.nightlight_round, color: isConnected ? const Color(0xFF9FA8DA) : Colors.white54, size: 22),
          const SizedBox(height: 8),
          if (!isConnected) _buildBadge(Icons.lock_outline, l10n.healthBadgeSync, Colors.white54)
          else if (sleepDuration == null) _buildBadge(Icons.sync_problem, l10n.healthNoData, Colors.orangeAccent)
          else Text(_formatSleep(sleepDuration!, l10n), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(l10n.healthSleepLabel, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CYCLE (BENTO CARD 1x1)
// ---------------------------------------------------------------------------
class BentoCycleCard extends StatelessWidget {
  final bool isLoading;
  final bool isConnected;
  final int? cycleDays;
  final VoidCallback onTap;

  const BentoCycleCard({
    super.key,
    required this.isLoading,
    required this.isConnected,
    required this.cycleDays,
    required this.onTap,
  });

  String _getCyclePhase(int days, AppLocalizations l10n) {
    if (days <= 5) return l10n.cyclePhaseMenstruation;
    if (days <= 13) return l10n.cyclePhaseFollicular;
    if (days <= 16) return l10n.cyclePhaseOvulation;
    return l10n.cyclePhaseLuteal;
  }

  Color _getCycleColor(int? days) {
    if (!isConnected || days == null) return Colors.white54;
    if (days <= 5) return Colors.redAccent;
    if (days <= 13) return Colors.greenAccent;
    if (days <= 16) return Colors.purpleAccent;
    return Colors.orangeAccent;
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) return GlassCard(child: const Center(child: CircularProgressIndicator(color: Colors.white54)));

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: isConnected ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
      child: Column(
        children: [
          Icon(Icons.water_drop, color: _getCycleColor(cycleDays), size: 24),
          const SizedBox(height: 8),
          if (!isConnected) _buildBadge(Icons.lock_outline, l10n.healthBadgeSync, Colors.white54)
          else if (cycleDays == null) _buildBadge(Icons.sync_problem, l10n.healthNoData, Colors.orangeAccent)
          else Text(_getCyclePhase(cycleDays!, l10n), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(l10n.healthCyclePhaseLabel, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        ],
      ),
    );
  }
}
