import 'dart:io'; // 🔥 Важно для проверки платформы
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

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // Локальное состояние для UI переключателей
  bool _notificationsGranted = false;
  bool _healthGranted = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatuses();
  }

  Future<void> _checkInitialStatuses() async {
    final notifStatus = await Permission.notification.status;
    // HealthService проверяем через наш сервис (он может вернуть false если прав нет)

    if (mounted) {
      setState(() {
        _notificationsGranted = notifStatus.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final haptic = getIt<HapticService>();
    final isAndroid = Platform.isAndroid; // 🔥 Проверка платформы

    // 🔥 Адаптация под платформу
    final String healthTitle = isAndroid ? "Health Connect" : "Apple Health";
    final IconData healthIcon = isAndroid ? Icons.health_and_safety : Icons.favorite; // health_and_safety для Android
    final Color healthColor = isAndroid ? Colors.green : Colors.redAccent;
    final String healthDesc = isAndroid ? "Sync weight & steps with Google" : l10n.permHealthDesc;

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
                  l10n.permTitle, // "Enable Permissions"
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.permDesc, // "To give you..."
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
                      // Запрашиваем через наш сервис
                      await getIt<NotificationService>().requestPermissions();

                      // Проверяем результат
                      final status = await Permission.notification.status;
                      setState(() => _notificationsGranted = status.isGranted);

                      // Сохраняем в глобальные настройки
                      if (mounted && status.isGranted) {
                        context.read<SettingsBloc>().add(const ToggleNotifications(true));
                      }
                    } else {
                      // Если юзер отключает свитч
                      openAppSettings();
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 2. HEALTH (Platform specific)
                _buildPermissionCard(
                  icon: healthIcon, // 🔥
                  color: healthColor, // 🔥
                  title: healthTitle, // 🔥
                  desc: healthDesc, // 🔥
                  value: _healthGranted,
                  onChanged: (val) async {
                    haptic.selectionClick();
                    if (val) {
                      // Запрашиваем через наш сервис
                      final granted = await getIt<HealthService>().requestPermissions();
                      setState(() => _healthGranted = granted);

                      // Сохраняем в глобальные настройки
                      if (mounted && granted) {
                        context.read<SettingsBloc>().add(const ToggleHealthSync(true));
                      }
                    }
                  },
                ),

                const Spacer(),

                // CONTINUE BUTTON
                GestureDetector(
                  onTap: () {
                    haptic.mediumImpact();
                    // Переход на Главную
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
                        l10n.permContinue, // "Continue"
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
    return GlassCard(
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
                Text(desc, style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.blueAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}