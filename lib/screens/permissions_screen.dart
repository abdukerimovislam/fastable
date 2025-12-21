import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/widgets/glass_card.dart'; // Ваш виджет
import 'package:fastable/widgets/mesh_background.dart'; // Ваш фон
import 'package:fastable/home_page.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // Статусы разрешений
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _trackingStatus = PermissionStatus.denied; // iOS Tracking

  @override
  void initState() {
    super.initState();
    _checkStatuses();
  }

  Future<void> _checkStatuses() async {
    final notif = await Permission.notification.status;
    final loc = await Permission.locationWhenInUse.status;
    final track = await Permission.appTrackingTransparency.status;

    setState(() {
      _notificationStatus = notif;
      _locationStatus = loc;
      _trackingStatus = track;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();

    // Если пользователь навсегда запретил, отправляем в настройки
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    _checkStatuses(); // Обновляем UI
  }

  Future<void> _finishOnboarding() async {
    // Запоминаем, что пользователь прошел этот экран
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);

    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),
                const Text(
                  "Let's set up\nyour experience",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "To make Fastable work perfectly, we need a few permissions.",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
                const SizedBox(height: 40),

                // 1. УВЕДОМЛЕНИЯ
                _buildPermissionItem(
                  icon: Icons.notifications_active,
                  title: "Notifications",
                  desc: "To remind you when your fast ends.",
                  status: _notificationStatus,
                  onTap: () => _requestPermission(Permission.notification),
                ),

                const SizedBox(height: 16),

                // 2. ГЕОЛОКАЦИЯ
                _buildPermissionItem(
                  icon: Icons.wb_sunny,
                  title: "Location",
                  desc: "For Circadian Rhythm (Sunset/Sunrise).",
                  status: _locationStatus,
                  onTap: () => _requestPermission(Permission.locationWhenInUse),
                ),

                const SizedBox(height: 16),

                // 3. ТРЕКИНГ (Только iOS, на Android скроется или будет granted)
                // Полезно для AdMob
                FutureBuilder(
                  future: Permission.appTrackingTransparency.status,
                  builder: (context, snapshot) {
                    // Показываем только если не Android или если реально нужно
                    // Обычно на Android этот пермишен всегда denied или не используется
                    // Поэтому можно показывать только на iOS
                    if (Theme.of(context).platform == TargetPlatform.iOS) {
                      return _buildPermissionItem(
                        icon: Icons.ad_units,
                        title: "Tracking",
                        desc: "To show personalized ads.",
                        status: _trackingStatus,
                        onTap: () => _requestPermission(Permission.appTrackingTransparency),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const Spacer(),

                // КНОПКА "CONTINUE"
                GestureDetector(
                  onTap: _finishOnboarding,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Center(
                      child: Text(
                        "Start Fasting",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required PermissionStatus status,
    required VoidCallback onTap,
  }) {
    final bool isGranted = status.isGranted;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check : icon,
              color: isGranted ? Colors.green : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Allow", style: TextStyle(color: Colors.blueAccent)),
            ),
        ],
      ),
    );
  }
}