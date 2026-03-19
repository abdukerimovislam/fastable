import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/services/locale_service.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart';

// BLoC
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_event.dart';
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';

// Экраны
import 'package:fastable/screens/medical_disclaimer_screen.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/profile_screen.dart';

const String kWaterGoalKey = 'water_goal';
const String kNotifyWaterKey = 'notify_water';
const String kNotifyWeightKey = 'notify_weight';
const String kNotifyFastingStartKey = 'notify_fasting_start';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _waterGoal = 8;
  bool _isLoading = true;
  bool _notifyWater = false;
  bool _notifyWeight = false;
  bool _notifyFastingStart = false;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _waterGoal = prefs.getInt(kWaterGoalKey) ?? 8;
      _notifyWater = prefs.getBool(kNotifyWaterKey) ?? false;
      _notifyWeight = prefs.getBool(kNotifyWeightKey) ?? false;
      _notifyFastingStart = prefs.getBool(kNotifyFastingStartKey) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onWaterToggle(bool value) {
    setState(() => _notifyWater = value);
    _saveBool(kNotifyWaterKey, value);
  }

  void _onWeightToggle(bool value) {
    setState(() => _notifyWeight = value);
    _saveBool(kNotifyWeightKey, value);
    if (value) {
      final l10n = AppLocalizations.of(context)!;
      _notificationService.scheduleDailyWeightReminder(l10n);
    }
  }

  void _onFastingStartToggle(bool value) {
    setState(() => _notifyFastingStart = value);
    _saveBool(kNotifyFastingStartKey, value);
  }

  // --- UI WIDGETS ---

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    String currentCode = LocaleService().localeNotifier.value.languageCode;
    final Map<String, String> languages = {
      'en': 'English',
      'ru': 'Русский',
      'es': 'Español',
      'pt': 'Português'
    };

    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.settingLanguage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: languages.containsKey(currentCode) ? currentCode : 'en',
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(Icons.language, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: languages.entries.map((entry) => DropdownMenuItem<String>(value: entry.key, child: Text(entry.value))).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<SettingsBloc>().add(ChangeLocale(Locale(newValue)));
                    LocaleService().setLocale(newValue);
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntStepper({required String title, required String unit, required int currentValue, required int step, required String saveKey}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$currentValue $unit", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Row(
                children: [
                  _buildCircleBtn(Icons.remove, () {
                    final newValue = currentValue - step;
                    if (newValue >= 1) {
                      setState(() { if (saveKey == kWaterGoalKey) _waterGoal = newValue; });
                      _saveInt(saveKey, newValue);
                    }
                  }),
                  const SizedBox(width: 12),
                  _buildCircleBtn(Icons.add, () {
                    final newValue = currentValue + step;
                    setState(() { if (saveKey == kWaterGoalKey) _waterGoal = newValue; });
                    _saveInt(saveKey, newValue);
                  }, isFilled: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, {bool isFilled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isFilled ? Colors.blueAccent : Colors.transparent,
          shape: BoxShape.circle,
          border: isFilled ? null : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: SwitchListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
          trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.blueAccent.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint("Could not launch $url");
  }

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 8, bottom: 10), child: Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MeshBackground(
      isFasting: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.navSettings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 150),
            children: [
              // 1. PRO СЕКЦИЯ (Только iOS)
              if (Platform.isIOS) ...[
                _sectionHeader("PRO"),
                GlassCard(
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(l10n.proTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Unlock all features', style: TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  onTap: () => context.read<ProBloc>().add(RestorePurchasesEvent()),
                  child: ListTile(
                    leading: const Icon(Icons.restore, color: Colors.white70),
                    title: Text(l10n.restorePurchases, style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 2. ОСНОВНЫЕ НАСТРОЙКИ (Язык и Вода)
              _sectionHeader(l10n.lblSettings),
              _buildLanguageSelector(l10n),
              const SizedBox(height: 12),
              _buildIntStepper(title: l10n.settingWaterGoal, unit: l10n.waterCups, currentValue: _waterGoal, step: 1, saveKey: kWaterGoalKey),
              const SizedBox(height: 12),

              // Здоровье
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {},
                child: ListTile(
                  leading: const Icon(Icons.health_and_safety, color: Colors.greenAccent),
                  title: Text(l10n.settingsHealthConnect, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(l10n.settingsSyncWeight, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)),
                ),
              ),
              const SizedBox(height: 24),

              // 3. УВЕДОМЛЕНИЯ
              _sectionHeader(l10n.settingsNotifications),
              _buildSwitchTile(title: l10n.notifyWater, subtitle: l10n.notifyWaterDesc, value: _notifyWater, onChanged: _onWaterToggle),
              _buildSwitchTile(title: l10n.notifyWeight, subtitle: l10n.notifyWeightDesc, value: _notifyWeight, onChanged: _onWeightToggle),
              _buildSwitchTile(title: l10n.notifyFastingStart, subtitle: l10n.notifyFastingStartDesc, value: _notifyFastingStart, onChanged: _onFastingStartToggle),
              const SizedBox(height: 24),

              // 4. ЮРИДИЧЕСКАЯ ИНФОРМАЦИЯ И ПОДДЕРЖКА
              _sectionHeader(l10n.aboutAndLegal),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalDisclaimerScreen())),
                child: ListTile(leading: const Icon(Icons.info_outline, color: Colors.amber), title: Text(l10n.settingsMedicalDisclaimer, style: const TextStyle(color: Colors.white)), trailing: const Icon(Icons.chevron_right, color: Colors.white54)),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () => _launchUrl('https://sites.google.com/view/fastable-privacy-policy'),
                child: ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey), title: Text(l10n.privacyPolicy, style: const TextStyle(color: Colors.white)), trailing: Icon(Icons.open_in_new, size: 16, color: Colors.white.withOpacity(0.4))),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () => _launchUrl('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                child: ListTile(leading: const Icon(Icons.description_outlined, color: Colors.grey), title: Text(l10n.settingsTermsOfUse, style: const TextStyle(color: Colors.white)), trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.white54)),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () => _launchUrl('mailto:freeman60012@gmail.com'),
                child: ListTile(leading: const Icon(Icons.mail_outline, color: Colors.blueAccent), title: Text(l10n.contactSupport ?? "Contact Support", style: const TextStyle(color: Colors.white)), trailing: Icon(Icons.open_in_new, size: 16, color: Colors.white.withOpacity(0.4))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}