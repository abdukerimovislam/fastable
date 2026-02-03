import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_event.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_state.dart';

// --- MODELS ---
import 'package:fastable/models/achievement.dart';

// --- СЕРВИСЫ ---
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/services/haptic_service.dart';

// --- ВИДЖЕТЫ ---
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- LOCALIZATION HELPERS ---
  String _getAchTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'achFirstFast': return l10n.achFirstFast;
      case 'achStreak3': return l10n.achStreak3;
      case 'achStreak7': return l10n.achStreak7;
      case 'achTotal10': return l10n.achTotal10;
      case 'achTotalHours100': return l10n.achTotalHours100;
      default: return key;
    }
  }

  String _getAchDesc(AppLocalizations l10n, String key) {
    switch (key) {
      case 'achFirstFastDesc': return l10n.achFirstFastDesc;
      case 'achStreak3Desc': return l10n.achStreak3Desc;
      case 'achStreak7Desc': return l10n.achStreak7Desc;
      case 'achTotal10Desc': return l10n.achTotal10Desc;
      case 'achTotalHours100Desc': return l10n.achTotalHours100Desc;
      default: return "";
    }
  }

  // --- ACTIONS ---

  void _handleGoogleSignIn(BuildContext context) async {
    await getIt<AuthService>().signInWithGoogle();
  }

  void _handleSignOut(BuildContext context) async {
    await getIt<AuthService>().signOut();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // --- PICKERS ---

  void _showHeightPicker(BuildContext context, double currentHeight) {
    getIt<HapticService>().mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.98),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _buildWheelPicker(
        ctx,
        title: "Height",
        initialItem: (currentHeight - 100).toInt(),
        count: 150,
        builder: (i) => "${100 + i} cm",
        onChanged: (i) => context.read<WeightBloc>().add(UpdateHeight(100.0 + i)),
      ),
    );
  }

  void _showAgePicker(BuildContext context, int currentAge) {
    getIt<HapticService>().mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.98),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _buildWheelPicker(
        ctx,
        title: "Age",
        initialItem: currentAge - 10,
        count: 90,
        builder: (i) => "${10 + i}",
        onChanged: (i) => context.read<WeightBloc>().add(UpdateAge(10 + i)),
      ),
    );
  }

  void _showGenderPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _buildOptionItem(ctx, l10n.genderMale, () => context.read<WeightBloc>().add(const UpdateGender(Gender.male))),
          _buildOptionItem(ctx, l10n.genderFemale, () => context.read<WeightBloc>().add(const UpdateGender(Gender.female))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showActivityPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _buildOptionItem(ctx, l10n.activitySedentary, () => context.read<WeightBloc>().add(const UpdateActivityLevel(ActivityLevel.sedentary))),
          _buildOptionItem(ctx, l10n.activityModerate, () => context.read<WeightBloc>().add(const UpdateActivityLevel(ActivityLevel.moderate))),
          _buildOptionItem(ctx, l10n.activityActive, () => context.read<WeightBloc>().add(const UpdateActivityLevel(ActivityLevel.active))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          _buildLangItem(context, "English", "en"),
          _buildLangItem(context, "Русский", "ru"),
          _buildLangItem(context, "Español", "es"),
          _buildLangItem(context, "Português", "pt"),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = getIt<AuthService>().currentUser;
    final isGuest = user == null || user.isAnonymous;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                          Text(isGuest ? l10n.guestUser : (user?.displayName ?? l10n.defaultUser), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(isGuest ? l10n.authSubtitle : (user?.email ?? ""), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                  child: Center(child: Text(isGuest ? l10n.signInGoogle : l10n.signOut, style: TextStyle(color: isGuest ? Colors.black : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))),
                ),
              ),

              // 2. ACHIEVEMENTS
              const SizedBox(height: 30),
              _sectionHeader("Achievements"),
              BlocBuilder<StatsBloc, StatsState>(
                builder: (context, state) {
                  return SizedBox(
                    height: 125,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Achievement.all.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final ach = Achievement.all[index];
                        final isUnlocked = state.unlockedAchievements.any((a) => a.id == ach.id);
                        final title = _getAchTitle(l10n, ach.titleKey);
                        final desc = _getAchDesc(l10n, ach.descKey);

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              getIt<HapticService>().selectionClick();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: const Color(0xFF1E1E1E),
                                content: Row(children: [Icon(ach.icon, color: isUnlocked ? ach.color : Colors.grey), const SizedBox(width: 12), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(isUnlocked ? desc : "Locked", style: const TextStyle(color: Colors.white70, fontSize: 12))]))]),
                                duration: const Duration(seconds: 2),
                              ));
                            },
                            child: GlassCard(
                              width: 100,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isUnlocked ? ach.color.withOpacity(0.2) : Colors.white.withOpacity(0.05), shape: BoxShape.circle, boxShadow: isUnlocked ? [BoxShadow(color: ach.color.withOpacity(0.3), blurRadius: 10)] : []), child: Icon(ach.icon, color: isUnlocked ? ach.color : Colors.white24, size: 28)),
                                const SizedBox(height: 8),
                                Text(title.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: isUnlocked ? Colors.white : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // 3. PERSONAL DATA (РАСШИРЕННЫЙ)
              const SizedBox(height: 30),
              _sectionHeader("Personal Data"),
              BlocBuilder<WeightBloc, WeightState>(
                builder: (context, weightState) {
                  return GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsTile(icon: Icons.height, title: l10n.selectHeight, value: "${weightState.heightCm.toInt()} cm", onTap: () => _showHeightPicker(context, weightState.heightCm)),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSettingsTile(icon: Icons.cake_outlined, title: l10n.selectAge, value: "${weightState.age}", onTap: () => _showAgePicker(context, weightState.age)),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSettingsTile(icon: Icons.wc, title: l10n.selectGender, value: weightState.gender == Gender.male ? l10n.genderMale : l10n.genderFemale, onTap: () => _showGenderPicker(context, l10n)),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSettingsTile(icon: Icons.local_fire_department_outlined, title: l10n.selectActivity, value: _getActivityLabel(l10n, weightState.activityLevel), onTap: () => _showActivityPicker(context, l10n)),
                      ],
                    ),
                  );
                },
              ),

              // 4. SETTINGS
              const SizedBox(height: 24),
              _sectionHeader("Settings"),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsTile(icon: Icons.language, title: l10n.settingLanguage, value: settingsState.locale.languageCode.toUpperCase(), onTap: () => _showLanguageSheet(context)),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSettingsTile(icon: settingsState.themeMode == ThemeMode.light ? Icons.wb_sunny : Icons.nightlight_round, title: l10n.settingTheme, value: settingsState.themeMode == ThemeMode.light ? l10n.themeLight : (settingsState.themeMode == ThemeMode.dark ? l10n.themeDark : l10n.themeSystem), onTap: () => context.read<SettingsBloc>().add(ChangeTheme(settingsState.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark))),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSwitchTile(icon: Icons.notifications_active_outlined, title: l10n.settingsNotifications, value: settingsState.areNotificationsEnabled, onChanged: (val) => context.read<SettingsBloc>().add(ToggleNotifications(val))),
                        const Divider(height: 1, color: Colors.white10),
                        _buildSwitchTile(icon: Icons.favorite, title: l10n.settingsHealthConnect, value: settingsState.isHealthSyncEnabled, onChanged: (val) => context.read<SettingsBloc>().add(ToggleHealthSync(val))),
                      ],
                    ),
                  );
                },
              ),

              // 5. ABOUT
              const SizedBox(height: 24),
              _sectionHeader("About"),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(icon: Icons.lock_outline, title: l10n.privacyPolicy, onTap: () => _launchUrl("https://your-app-domain.com/privacy")),
                    const Divider(height: 1, color: Colors.white10),
                    _buildSettingsTile(icon: Icons.description_outlined, title: l10n.termsOfService, onTap: () => _launchUrl("https://your-app-domain.com/terms")),
                    const Divider(height: 1, color: Colors.white10),
                    _buildSettingsTile(icon: Icons.mail_outline, title: l10n.contactSupport, onTap: () => _launchUrl("mailto:support@fastable.app")),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Center(child: Text("Version 1.0.0 (Build 22)", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12))),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---

  String _getActivityLabel(AppLocalizations l10n, ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary: return l10n.activitySedentary;
      case ActivityLevel.moderate: return l10n.activityModerate;
      case ActivityLevel.active: return l10n.activityActive;
    }
  }

  Widget _buildWheelPicker(BuildContext context, {required String title, required int initialItem, required int count, required String Function(int) builder, required Function(int) onChanged}) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40, perspective: 0.005, physics: const FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: initialItem),
              onSelectedItemChanged: (index) { getIt<HapticService>().selectionClick(); onChanged(index); },
              childDelegate: ListWheelChildBuilderDelegate(childCount: count, builder: (ctx, idx) => Center(child: Text(builder(idx), style: const TextStyle(color: Colors.white, fontSize: 20)))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)), onTap: () { getIt<HapticService>().selectionClick(); onTap(); Navigator.pop(context); });
  }

  Widget _buildLangItem(BuildContext context, String name, String code) {
    return ListTile(title: Text(name, style: const TextStyle(color: Colors.white)), onTap: () { context.read<SettingsBloc>().add(ChangeLocale(Locale(code))); Navigator.pop(context); });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint("Could not launch $url");
  }

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 8, bottom: 10), child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)));
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? value, required VoidCallback onTap, bool showArrow = true}) {
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Row(children: [Icon(icon, color: Colors.white70, size: 22), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))), if (value != null) Text(value, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)), if (showArrow) ...[const SizedBox(width: 8), Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 20)]])));
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [Icon(icon, color: Colors.white70, size: 22), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))), Switch(value: value, onChanged: onChanged, activeColor: Colors.blueAccent, activeTrackColor: Colors.blueAccent.withOpacity(0.3), inactiveThumbColor: Colors.grey, inactiveTrackColor: Colors.white10)]));
  }
}