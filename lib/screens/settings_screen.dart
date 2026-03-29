import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/ui/app_layout.dart';

// BLoC
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';

// Экраны
import 'package:fastable/screens/medical_disclaimer_screen.dart';
import 'package:fastable/screens/permissions_screen.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _updateWaterGoal(
    BuildContext context, {
    required int currentCups,
    required int delta,
  }) {
    final nextCups = currentCups + delta;
    if (nextCups < 1) return;

    getIt<HapticService>().lightImpact();
    context.read<WaterBloc>().add(UpdateWaterGoal(nextCups * 250));
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // --- UI WIDGETS ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context, String currentLang) {
    getIt<HapticService>().mediumImpact();

    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.settingLanguage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = lang['code'] == currentLang;
                return ListTile(
                  onTap: () {
                    getIt<HapticService>().selectionClick();
                    // 🔥 Отправляем событие в BLoC. Экран сам перерисуется благодаря context.watch!
                    context.read<SettingsBloc>().add(
                      ChangeLocale(Locale(lang['code']!)),
                    );
                    Navigator.pop(ctx);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: isSelected
                      ? Colors.blueAccent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  leading: Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.blueAccent : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.blueAccent,
                        )
                      : null,
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 ИСПРАВЛЕНИЕ: Передаем currentCode напрямую из виджета
  Widget _buildLanguageSelector(AppLocalizations l10n, String currentCode) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: () => _showLanguagePicker(context, currentCode),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.language_rounded,
            color: Colors.orangeAccent,
            size: 20,
          ),
        ),
        title: Text(
          l10n.settingLanguage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageName(currentCode),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntStepper({
    required String title,
    required String unit,
    required int currentValue,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  color: Colors.cyanAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentValue $unit",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Row(
                children: [
                  _buildCircleBtn(Icons.remove, onDecrement),
                  const SizedBox(width: 12),
                  _buildCircleBtn(Icons.add, onIncrement, isFilled: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isFilled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isFilled ? Colors.blueAccent : Colors.transparent,
          shape: BoxShape.circle,
          border: isFilled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ),
          trailing: CupertinoSwitch(
            value: value,
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    final waterState = context.watch<WaterBloc>().state;
    final currentLanguageCode = settingsState.locale.languageCode;
    final isHealthSyncEnabled = settingsState.isHealthSyncEnabled;
    final waterGoalCups = (waterState.dailyGoal / 250).round().clamp(1, 99);

    return MeshBackground(
      isFasting: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.navSettings,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: ListView(
            padding: AppLayout.screenPadding(
              context,
              top: 10,
              bottom: 92,
              includeBottomSafeArea: true,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. PRO СЕКЦИЯ (Только iOS)
              if (Platform.isIOS) ...[
                _sectionHeader("PRO"),
                GlassCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    getIt<HapticService>().lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProScreen()),
                    );
                  },
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.proTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Unlock all features',
                      style: TextStyle(color: Colors.white54),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    getIt<HapticService>().lightImpact();
                    context.read<ProBloc>().add(RestorePurchasesEvent());
                  },
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restore_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.restorePurchases,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],

              // 2. ОСНОВНЫЕ НАСТРОЙКИ (Язык и Вода)
              _sectionHeader(l10n.lblSettings),
              // 🔥 Передаем актуальный код языка в виджет
              _buildLanguageSelector(l10n, currentLanguageCode),
              const SizedBox(height: 12),
              _buildIntStepper(
                title: l10n.settingWaterGoal,
                unit: l10n.waterCups,
                currentValue: waterGoalCups,
                onDecrement: () => _updateWaterGoal(
                  context,
                  currentCups: waterGoalCups,
                  delta: -1,
                ),
                onIncrement: () => _updateWaterGoal(
                  context,
                  currentCups: waterGoalCups,
                  delta: 1,
                ),
              ),
              const SizedBox(height: 12),

              // Здоровье
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  getIt<HapticService>().lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PermissionsScreen(
                        returnToHomeOnContinue: false,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.greenAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.settingsHealthConnect,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    isHealthSyncEnabled
                        ? l10n.msgHealthSyncEnabled
                        : l10n.settingsSyncWeight,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHealthSyncEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.greenAccent,
                            size: 14,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. УВЕДОМЛЕНИЯ
              _sectionHeader(l10n.settingsNotifications),
              _buildSwitchTile(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blueAccent,
                title: l10n.notifyWater,
                subtitle: l10n.notifyWaterDesc,
                value: settingsState.notifyWater,
                onChanged: (value) {
                  getIt<HapticService>().selectionClick();
                  context.read<SettingsBloc>().add(ToggleWaterReminder(value));
                },
              ),
              _buildSwitchTile(
                icon: Icons.monitor_weight_rounded,
                iconColor: Colors.purpleAccent,
                title: l10n.notifyWeight,
                subtitle: l10n.notifyWeightDesc,
                value: settingsState.notifyWeight,
                onChanged: (value) {
                  getIt<HapticService>().selectionClick();
                  context.read<SettingsBloc>().add(ToggleWeightReminder(value));
                },
              ),
              _buildSwitchTile(
                icon: Icons.timer_rounded,
                iconColor: Colors.amberAccent,
                title: l10n.notifyFastingStart,
                subtitle: l10n.notifyFastingStartDesc,
                value: settingsState.notifyFastingStart,
                onChanged: (value) {
                  getIt<HapticService>().selectionClick();
                  context.read<SettingsBloc>().add(
                    ToggleFastingStartReminder(value),
                  );
                },
              ),

              // 4. ЮРИДИЧЕСКАЯ ИНФОРМАЦИЯ И ПОДДЕРЖКА
              _sectionHeader(l10n.aboutAndLegal),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  getIt<HapticService>().lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicalDisclaimerScreen(),
                    ),
                  );
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  title: Text(
                    l10n.settingsMedicalDisclaimer,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  getIt<HapticService>().lightImpact();
                  _launchUrl(
                    'https://sites.google.com/view/fastable-privacy-policy',
                  );
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  title: Text(
                    l10n.privacyPolicy,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  getIt<HapticService>().lightImpact();
                  _launchUrl(
                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                  );
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: Colors.white70,
                    size: 22,
                  ),
                  title: Text(
                    l10n.settingsTermsOfUse,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  getIt<HapticService>().lightImpact();
                  _launchUrl('mailto:freeman60012@gmail.com');
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.mail_outline_rounded,
                    color: Colors.blueAccent,
                    size: 22,
                  ),
                  title: Text(
                    l10n.contactSupport,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Fastable v1.0.0",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
