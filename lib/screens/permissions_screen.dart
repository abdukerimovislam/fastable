import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/health_service.dart';

import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/health_sync_preferences.dart';
import 'package:fastable/ui/app_layout.dart';

class PermissionsScreen extends StatefulWidget {
  final bool returnToHomeOnContinue;

  const PermissionsScreen({super.key, this.returnToHomeOnContinue = true});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _notificationsGranted = false;
  bool _healthGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    ); // Слушаем сворачивание/разворачивание приложения
    _checkStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Если юзер сходил в настройки и вернулся - обновляем статус
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatuses();
    }
  }

  Future<void> _checkStatuses() async {
    final notifStatus = await Permission.notification.status;

    if (!mounted) return;
    final isHealthEnabledInSettings = await HealthSyncPreferences.isEnabled();

    setState(() {
      _notificationsGranted = notifStatus.isGranted;
      _healthGranted = isHealthEnabledInSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();
    final isAndroid = Platform.isAndroid;
    final cardPadding = AppLayout.cardPadding(context);

    // Данные для Health карточки
    final String healthTitle = isAndroid
        ? l10n.permHealthConnect
        : l10n.permHealthTitle;
    final IconData healthIcon = isAndroid
        ? Icons.health_and_safety
        : Icons.favorite;
    final Color healthColor = isAndroid ? Colors.green : Colors.redAccent;
    final String healthDesc = isAndroid
        ? l10n.permHealthConnectDesc
        : l10n.permHealthDesc;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: AppLayout.contentPadding(context, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: EdgeInsets.all(cardPadding + 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 28,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.permTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.permDesc,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPermissionCard(
                      icon: Icons.notifications_active,
                      color: Colors.orangeAccent,
                      title: l10n.permNotifTitle,
                      desc: l10n.permNotifDesc,
                      value: _notificationsGranted,
                      onChanged: (val) async {
                        haptic.selectionClick();
                        if (val) {
                          final status = await Permission.notification.status;

                          if (status.isPermanentlyDenied) {
                            openAppSettings();
                          } else {
                            await getIt<NotificationService>()
                                .requestPermissions();
                          }

                          await _checkStatuses();

                          if (!context.mounted) return;
                          if (_notificationsGranted) {
                            context.read<SettingsBloc>().add(
                              const ToggleNotifications(true),
                            );
                          }
                        } else {
                          setState(() => _notificationsGranted = false);
                          context.read<SettingsBloc>().add(
                            const ToggleNotifications(false),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildPermissionCard(
                      icon: healthIcon,
                      color: healthColor,
                      title: healthTitle,
                      desc: healthDesc,
                      value: _healthGranted,
                      onChanged: (val) async {
                        haptic.selectionClick();
                        if (val) {
                          final success = await getIt<HealthService>()
                              .requestPermissions();

                          if (!context.mounted) return;

                          if (success) {
                            setState(() => _healthGranted = true);
                            context.read<SettingsBloc>().add(
                              const ToggleHealthSync(
                                true,
                                requestPermissions: false,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.msgHealthSyncEnabled),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setState(() => _healthGranted = false);
                            context.read<SettingsBloc>().add(
                              const ToggleHealthSync(
                                false,
                                requestPermissions: false,
                              ),
                            );
                          }
                        } else {
                          setState(() => _healthGranted = false);
                          context.read<SettingsBloc>().add(
                            const ToggleHealthSync(
                              false,
                              requestPermissions: false,
                            ),
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        haptic.mediumImpact();
                        if (widget.returnToHomeOnContinue) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                          return;
                        }

                        Navigator.of(context).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        l10n.permContinue,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value), // Позволяем кликать по всей карточке
      child: GlassCard(
        padding: EdgeInsets.all(AppLayout.cardPadding(context)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        value
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: value ? color : Colors.white24,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: value,
                activeThumbColor: Colors.blueAccent,
                activeTrackColor: Colors.blueAccent.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white10,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
