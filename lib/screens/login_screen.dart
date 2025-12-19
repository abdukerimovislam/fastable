import 'package:flutter/material.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart'; // Используем наш виджет
import 'package:fastable/widgets/mesh_background.dart'; // Используем живой фон
import 'package:shared_preferences/shared_preferences.dart';

// --- ИСПРАВЛЕНИЕ: Добавляем константу ---
const String kOnboardingCompleteKey = 'onboarding_complete';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _completeLogin() async {
    // Отмечаем, что онбординг (или логин) пройден
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        await _completeLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInGuest() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInAnonymously();
      if (user != null) {
        await _completeLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Guest Login Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MeshBackground(
      isFasting: false, // Сине-зеленый фон
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // ЗАГОЛОВОК
                const Icon(Icons.lock_open_rounded, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  l10n.authWelcome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.authSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                ),

                const Spacer(),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else ...[
                  // КНОПКА GOOGLE (Стеклянная)
                  GlassCard(
                    padding: EdgeInsets.zero,
                    onTap: _signInWithGoogle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(l10n.signInGoogle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // КНОПКА GUEST (Прозрачная)
                  TextButton(
                    onPressed: _signInGuest,
                    child: Text(
                      l10n.continueGuest,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}