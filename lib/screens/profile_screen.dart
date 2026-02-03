import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';

// --- СЕРВИСЫ ---
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/services/haptic_service.dart';

// --- ВИДЖЕТЫ ---
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- ACTIONS ---

  void _handleGoogleSignIn(BuildContext context) async {
    await getIt<AuthService>().signInWithGoogle();
    // BlocBuilder сам обновит UI, так как User берется из AuthService,
    // но для надежности можно сделать force refresh, если нужно.
  }

  void _handleSignOut(BuildContext context) async {
    await getIt<AuthService>().signOut();
    if (context.mounted) {
      // Перенаправляем на экран логина, чтобы сбросить стейт навигации
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showHeightPicker(BuildContext context, double currentHeight) {
    getIt<HapticService>().mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.98),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
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
                  controller: FixedExtentScrollController(initialItem: (currentHeight - 100).toInt()), // 100 - мин. рост
                  onSelectedItemChanged: (index) {
                    getIt<HapticService>().selectionClick();
                    // Отправляем событие в WeightBloc
                    final newHeight = 100.0 + index;
                    context.read<WeightBloc>().add(UpdateHeight(newHeight));
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 150, // 100cm - 250cm
                    builder: (context, index) {
                      final h = 100 + index;
                      final isSelected = h == currentHeight.toInt();
                      return Center(
                        child: Text(
                          "$h cm",
                          style: TextStyle(
                              color: isSelected ? Colors.blueAccent : Colors.white54,
                              fontSize: 20,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
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

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _buildLangItem(context, "English", "en"),
            _buildLangItem(context, "Русский", "ru"),
            _buildLangItem(context, "Español", "es"),
            _buildLangItem(context, "Português", "pt"),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildLangItem(BuildContext context, String name, String code) {
    return ListTile(
      title: Text(name, style: const TextStyle(color: Colors.white)),
      onTap: () {
        context.read<SettingsBloc>().add(ChangeLocale(Locale(code)));
        Navigator.pop(context);
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = getIt<AuthService>().currentUser;
    final isGuest = user == null || user.isAnonymous;

    return Scaffold(
      backgroundColor: Colors.transparent, // Фон рисуется в HomePage
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 20),
                child: Text(l10n.navProfile, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              ),

              // 1. АККАУНТ
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isGuest ? Colors.grey.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                      backgroundImage: (!isGuest && user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? l10n.guestUser : (user?.displayName ?? l10n.defaultUser),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isGuest ? l10n.authSubtitle : (user?.email ?? ""),
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
                onTap: () => isGuest ? _handleGoogleSignIn(context) : _handleSignOut(context),
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
                      isGuest ? l10n.signInGoogle : l10n.signOut,
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

              // 2. ДАННЫЕ (РОСТ) -> Берем из WeightBloc
              BlocBuilder<WeightBloc, WeightState>(
                builder: (context, weightState) {
                  return GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.height,
                          title: l10n.settingHeight, // "Height"
                          value: "${weightState.heightCm.toInt()} cm",
                          onTap: () => _showHeightPicker(context, weightState.heightCm),
                          showArrow: true,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              _sectionHeader("Settings"),

              // 3. НАСТРОЙКИ -> Берем из SettingsBloc
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // ЯЗЫК
                        _buildSettingsTile(
                          icon: Icons.language,
                          title: l10n.settingLanguage,
                          value: settingsState.locale.languageCode.toUpperCase(),
                          onTap: () => _showLanguageSheet(context),
                        ),
                        const Divider(height: 1, color: Colors.white10),

                        // ТЕМА
                        _buildSettingsTile(
                          icon: settingsState.themeMode == ThemeMode.light ? Icons.wb_sunny : Icons.nightlight_round,
                          title: l10n.settingTheme,
                          value: settingsState.themeMode == ThemeMode.light ? l10n.themeLight : (settingsState.themeMode == ThemeMode.dark ? l10n.themeDark : l10n.themeSystem),
                          onTap: () {
                            final newMode = settingsState.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                            context.read<SettingsBloc>().add(ChangeTheme(newMode));
                          },
                        ),
                        const Divider(height: 1, color: Colors.white10),

                        // УВЕДОМЛЕНИЯ
                        _buildSwitchTile(
                          icon: Icons.notifications_active_outlined,
                          title: l10n.settingsNotifications,
                          value: settingsState.areNotificationsEnabled,
                          onChanged: (val) => context.read<SettingsBloc>().add(ToggleNotifications(val)),
                        ),

                        const Divider(height: 1, color: Colors.white10),

                        // HEALTH CONNECT
                        _buildSwitchTile(
                          icon: Icons.favorite,
                          title: l10n.settingsHealthConnect,
                          value: settingsState.isHealthSyncEnabled,
                          onChanged: (val) => context.read<SettingsBloc>().add(ToggleHealthSync(val)),
                        ),
                      ],
                    ),
                  );
                },
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
                      title: l10n.privacyPolicy,
                      onTap: () => _launchUrl("https://your-app-domain.com/privacy"),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: l10n.termsOfService,
                      onTap: () => _launchUrl("https://your-app-domain.com/terms"),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    _buildSettingsTile(
                      icon: Icons.mail_outline,
                      title: "Contact Support",
                      onTap: () => _launchUrl("mailto:support@fastable.app"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Version 1.0.0 (Build 22)",
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ),
              const SizedBox(height: 100),
            ],
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