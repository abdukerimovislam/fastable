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
import 'package:fastable/bloc/settings/settings_state.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with WidgetsBindingObserver {
  bool _notificationsGranted = false;
  bool _healthGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Слушаем сворачивание/разворачивание приложения
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

    // Для Health мы проверяем, включено ли это в наших настройках (SettingsBloc),
    // так как "честно" проверить права Health без запроса сложно на всех ОС.
    if (!mounted) return;
    final isHealthEnabledInSettings = context.read<SettingsBloc>().state.isHealthSyncEnabled;

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

    // Данные для Health карточки
    final String healthTitle = isAndroid ? l10n.permHealthConnect : "Apple Health";
    final IconData healthIcon = isAndroid ? Icons.health_and_safety : Icons.favorite;
    final Color healthColor = isAndroid ? Colors.green : Colors.redAccent;
    final String healthDesc = isAndroid ? l10n.permHealthConnectDesc : l10n.permHealthDesc;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.shield_outlined, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 24),
                Text(
                  l10n.permTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.permDesc,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),

                // 1. NOTIFICATIONS
                _buildPermissionCard(
                  icon: Icons.notifications_active,
                  color: Colors.orangeAccent,
                  title: l10n.permNotifTitle,
                  desc: l10n.permNotifDesc,
                  value: _notificationsGranted,
                  onChanged: (val) async {
                    haptic.selectionClick();
                    if (val) {
                      // Пытаемся включить
                      final status = await Permission.notification.status;

                      if (status.isPermanentlyDenied) {
                        // Если запрещено навсегда - отправляем в настройки
                        openAppSettings();
                      } else {
                        // Иначе запрашиваем
                        await getIt<NotificationService>().requestPermissions();
                      }

                      // Обновляем UI после запроса
                      await _checkStatuses();

                      if (_notificationsGranted && mounted) {
                        context.read<SettingsBloc>().add(const ToggleNotifications(true));
                      }
                    } else {
                      // Юзер выключает свитч. Системные права забрать нельзя,
                      // но мы можем просто выключить их в логике приложения.
                      setState(() => _notificationsGranted = false);
                      context.read<SettingsBloc>().add(const ToggleNotifications(false));
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 2. HEALTH
                _buildPermissionCard(
                  icon: healthIcon,
                  color: healthColor,
                  title: healthTitle,
                  desc: healthDesc,
                  value: _healthGranted,
                  onChanged: (val) async {
                    haptic.selectionClick();
                    if (val) {
                      // Запрос прав
                      final success = await getIt<HealthService>().requestPermissions();

                      if (success && mounted) {
                        setState(() => _healthGranted = true);
                        context.read<SettingsBloc>().add(const ToggleHealthSync(true));
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.msgHealthSyncEnabled), backgroundColor: Colors.green)
                        );
                      } else {
                        // Если отказ или ошибка
                        setState(() => _healthGranted = false);
                        context.read<SettingsBloc>().add(const ToggleHealthSync(false));
                      }
                    } else {
                      // Выключение
                      setState(() => _healthGranted = false);
                      context.read<SettingsBloc>().add(const ToggleHealthSync(false));
                    }
                  },
                ),

                const Spacer(),

                // CONTINUE BUTTON
                GestureDetector(
                  onTap: () {
                    haptic.mediumImpact();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Center(
                      child: Text(
                        l10n.permContinue,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.2)),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: value,
                activeColor: Colors.blueAccent,
                activeTrackColor: Colors.blueAccent.withOpacity(0.3),
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