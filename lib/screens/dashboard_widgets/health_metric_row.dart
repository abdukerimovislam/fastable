import 'package:fastable/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/services/health_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/health_sync_preferences.dart';

class HealthMetricsRow extends StatefulWidget {
  const HealthMetricsRow({super.key});

  @override
  State<HealthMetricsRow> createState() => _HealthMetricsRowState();
}

class _HealthMetricsRowState extends State<HealthMetricsRow> {
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

  // Единый метод для первичного запроса прав и ручного обновления
  Future<void> _refreshData({
    bool triggerHaptic = true,
    bool allowPermissionRequest = true,
  }) async {
    if (mounted) setState(() => _isLoading = true);
    if (triggerHaptic) {
      getIt<HapticService>().selectionClick();
    }

    // 1. Если не подключено - запрашиваем права
    if (!_isHealthConnected && allowPermissionRequest) {
      final granted = await _healthService.requestPermissions();
      if (granted) {
        final prefs = await SharedPreferences.getInstance();
        await HealthSyncPreferences.setEnabled(true, prefs);
        _isHealthConnected = true;
        if (mounted) {
          context.read<SettingsBloc>().add(
            const ToggleHealthSync(true, requestPermissions: false),
          );
        }
      }
    }

    // 2. Если подключено - тянем данные
    if (_isHealthConnected) {
      try {
        final sleep = await _healthService.getLastNightSleep();
        final menstruation = await _healthService
            .getDaysSinceLastMenstruation();

        if (mounted) {
          setState(() {
            _sleepDuration = (sleep.inMinutes > 0) ? sleep : null;
            _daysSinceMenstruation = menstruation;
          });
        }
      } catch (e) {
        // 🔥 ВОТ ОНА - ЗАЩИТА ОТ КРАШЕЙ!
        // Если Android говорит, что прав нет (хотя наш флаг true), значит приложение переустанавливали.
        // Сбрасываем флаг и возвращаем пользователя к состоянию "нужно синхронизировать".
        appLog("HealthMetricsRow Error: $e");
        final prefs = await SharedPreferences.getInstance();
        await HealthSyncPreferences.setEnabled(false, prefs);
        if (mounted) {
          context.read<SettingsBloc>().add(
            const ToggleHealthSync(false, requestPermissions: false),
          );
        }
        if (mounted) {
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

  Future<void> _syncWithSettings(bool isEnabled) async {
    if (!isEnabled) {
      if (!mounted) return;
      setState(() {
        _isHealthConnected = false;
        _isLoading = false;
        _sleepDuration = null;
        _daysSinceMenstruation = null;
      });
      return;
    }

    _isHealthConnected = true;
    await _refreshData(triggerHaptic: false, allowPermissionRequest: false);
  }

  // --- Хелперы для UI ---

  String _formatSleep(Duration d, AppLocalizations l10n) {
    return "${d.inHours}${l10n.unitHoursShort} ${d.inMinutes % 60}${l10n.unitMin}";
  }

  String _getCyclePhase(int days, AppLocalizations l10n) {
    if (days <= 5) return l10n.cyclePhaseMenstruation;
    if (days <= 13) return l10n.cyclePhaseFollicular;
    if (days <= 16) return l10n.cyclePhaseOvulation;
    return l10n.cyclePhaseLuteal;
  }

  Color _getCycleColor(int? days) {
    if (!_isHealthConnected || days == null) return Colors.white54;
    if (days <= 5) return Colors.redAccent;
    if (days <= 13) return Colors.greenAccent;
    if (days <= 16) return Colors.purpleAccent;
    return Colors.orangeAccent;
  }

  Widget _buildStatusBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.isHealthSyncEnabled != current.isHealthSyncEnabled,
      listener: (context, state) {
        _syncWithSettings(state.isHealthSyncEnabled);
      },
      child: _isLoading
          ? _buildLoading()
          : Row(
              children: [
                // 1. КАРТОЧКА СНА
                Expanded(
                  child: GlassCard(
                    onTap: _refreshData,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    color: _isHealthConnected
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.03),
                    child: Column(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: _isHealthConnected
                              ? const Color(0xFF9FA8DA)
                              : Colors.white54,
                          size: 24,
                        ),
                        const SizedBox(height: 8),

                        if (!_isHealthConnected)
                          _buildStatusBadge(
                            Icons.lock_outline,
                            l10n.healthBadgeSync,
                            Colors.white54,
                          )
                        else if (_sleepDuration == null)
                          _buildStatusBadge(
                            Icons.sync_problem,
                            l10n.healthNoData,
                            Colors.orangeAccent,
                          )
                        else
                          Text(
                            _formatSleep(_sleepDuration!, l10n),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                        const SizedBox(height: 4),
                        Text(
                          l10n.healthSleepLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. КАРТОЧКА ЦИКЛА
                Expanded(
                  child: GlassCard(
                    onTap: _refreshData,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    color: _isHealthConnected
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.03),
                    child: Column(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: _getCycleColor(_daysSinceMenstruation),
                          size: 24,
                        ),
                        const SizedBox(height: 8),

                        if (!_isHealthConnected)
                          _buildStatusBadge(
                            Icons.lock_outline,
                            l10n.healthBadgeSync,
                            Colors.white54,
                          )
                        else if (_daysSinceMenstruation == null)
                          _buildStatusBadge(
                            Icons.sync_problem,
                            l10n.healthNoData,
                            Colors.orangeAccent,
                          )
                        else
                          Text(
                            _getCyclePhase(_daysSinceMenstruation!, l10n),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                        const SizedBox(height: 4),
                        Text(
                          l10n.healthCyclePhaseLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(child: GlassCard(height: 95, child: Container())),
          const SizedBox(width: 12),
          Expanded(child: GlassCard(height: 95, child: Container())),
        ],
      ),
    );
  }
}
