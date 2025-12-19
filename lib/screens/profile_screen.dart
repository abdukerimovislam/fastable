import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/settings_screen.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/widgets/mesh_background.dart'; // <--- Добавили импорт

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _linkGoogleAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.accountLinked), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.linkError), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final l10n = AppLocalizations.of(context)!;

    String displayName = user?.displayName ?? l10n.defaultUser;
    String email = user?.email ?? l10n.anonymousLogin;
    ImageProvider? avatarImage;

    if (user?.photoURL != null) {
      avatarImage = NetworkImage(user!.photoURL!);
    }

    if (user != null && user.isAnonymous) {
      displayName = l10n.guestUser;
      email = l10n.dataOnDevice;
    }

    // ВАЖНО: Оборачиваем в MeshBackground
    return MeshBackground(
      isFasting: false, // Для профиля используем нейтральный (зеленый/синий) фон
      child: Scaffold(
        backgroundColor: Colors.transparent, // Делаем прозрачным, чтобы видеть фон
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.navProfile, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- КАРТОЧКА ПОЛЬЗОВАТЕЛЯ (GLASS) ---
            if (user != null)
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: avatarImage,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: avatarImage == null
                            ? Icon(user.isAnonymous ? Icons.person_outline : Icons.person, size: 32, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // --- НАСТРОЙКИ (GLASS TILE) ---
            GlassCard(
              padding: EdgeInsets.zero,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.settings, color: Colors.blueAccent),
                ),
                title: Text(l10n.navSettings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)),
              ),
            ),

            const SizedBox(height: 16),

            // --- ДЕЙСТВИЯ АККАУНТА ---
            if (user != null && user.isAnonymous) ...[
              // ГОСТЬ
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () => _linkGoogleAccount(context),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.login, color: Colors.greenAccent),
                  ),
                  title: Text(l10n.connectGoogle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(l10n.saveProgressCloud, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ),
              ),
              const SizedBox(height: 16),

              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () async {
                  final shouldLogout = await _showConfirmDialog(context, l10n.attention, l10n.guestLogoutWarning, l10n.deleteAndExit, isDestructive: true);
                  if (shouldLogout == true) {
                    await AuthService().signOut();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  ),
                  title: Text(l10n.resetAndExit, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                ),
              ),

            ] else ...[
              // USER
              GlassCard(
                padding: EdgeInsets.zero,
                onTap: () async {
                  final shouldLogout = await _showConfirmDialog(context, l10n.signOut, l10n.confirmLogout, l10n.signOut, isDestructive: true);
                  if (shouldLogout == true) {
                    await AuthService().signOut();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.logout, color: Colors.redAccent),
                  ),
                  title: Text(l10n.signOut, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content, String confirmText, {bool isDestructive = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.95), // Темный фон диалога
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(confirmText, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}