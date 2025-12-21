import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Не забудьте добавить в pubspec.yaml

import 'package:fastable/services/auth_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;

  // Настройки
  int _userHeight = 175;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _loadSettings();

    // Слушаем авторизацию
    _authService.authStateChanges.listen((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userHeight = prefs.getInt('user_height') ?? 175;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  // --- ACTIONS ---

  void _handleGoogleSignIn() async {
    await _authService.signInWithGoogle();
  }

  void _handleSignOut() async {
    await _authService.signOut();
    await _authService.signInAnonymously();
  }

  Future<void> _updateHeight(int newHeight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_height', newHeight);
    setState(() => _userHeight = newHeight);
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    // Здесь можно вызвать логику отключения пушей в NotificationService
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  void _showHeightPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Select Height", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: _userHeight - 100), // 100 - мин. рост
                  onSelectedItemChanged: (index) {
                    _updateHeight(100 + index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 150, // 100cm - 250cm
                    builder: (context, index) {
                      final h = 100 + index;
                      return Center(
                        child: Text(
                          "$h cm",
                          style: TextStyle(
                              color: h == _userHeight ? Colors.blueAccent : Colors.white54,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Если есть переводы для профиля
    final bool isGuest = _user == null || _user!.isAnonymous;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MeshBackground(
        isFasting: false, // Нейтральный фон
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 20),
                  child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                ),

                // 1. АККАУНТ
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isGuest ? Colors.grey.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                        backgroundImage: (!isGuest && _user?.photoURL != null) ? NetworkImage(_user!.photoURL!) : null,
                        child: _user?.photoURL == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGuest ? "Guest User" : (_user?.displayName ?? "User"),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isGuest ? "Sign in to sync data" : (_user?.email ?? ""),
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // КНОПКА ВХОДА/ВЫХОДА
                GestureDetector(
                  onTap: isGuest ? _handleGoogleSignIn : _handleSignOut,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isGuest ? Colors.white : Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isGuest ? Colors.transparent : Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        isGuest ? "Sync with Google" : "Sign Out",
                        style: TextStyle(
                            color: isGuest ? Colors.black : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                _sectionHeader("Personal Data"),

                // 2. ДАННЫЕ (РОСТ)
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.height,
                        title: "Height",
                        value: "$_userHeight cm",
                        onTap: _showHeightPicker,
                        showArrow: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _sectionHeader("Settings"),

                // 3. НАСТРОЙКИ (Уведомления, Звук)
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: "Notifications",
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _buildSwitchTile(
                        icon: Icons.volume_up_outlined,
                        title: "Sound Effects",
                        value: _soundEnabled,
                        onChanged: _toggleSound,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _sectionHeader("About"),

                // 4. ЮРИДИЧЕСКАЯ ИНФОРМАЦИЯ
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: "Privacy Policy",
                        onTap: () => _launchUrl("https://your-app-domain.com/privacy"), // Замените на вашу ссылку
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        title: "Terms of Service",
                        onTap: () => _launchUrl("https://your-app-domain.com/terms"), // Замените на вашу ссылку
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      _buildSettingsTile(
                        icon: Icons.mail_outline,
                        title: "Contact Support",
                        onTap: () => _launchUrl("mailto:support@midasapps.com"), // Почта поддержки
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
            if (value != null)
              Text(value, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
            activeTrackColor: Colors.blueAccent.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}