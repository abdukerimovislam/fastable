import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/widgets/mesh_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Future<void> _handleGoogleSignIn(AppLocalizations l10n) async {
    try {
      _setLoading(true);
      final user = await getIt<AuthService>().signInWithGoogle();
      _setLoading(false);
      if (user != null) _navigateToHome();
    } on DataConflictException {
      _setLoading(false);
      _showConflictDialog(l10n);
    } catch (e) {
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgLoginFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(AppLocalizations l10n) async {
    try {
      _setLoading(true);
      final user = await getIt<AuthService>().signInWithApple();
      _setLoading(false);
      if (user != null) _navigateToHome();
    } on DataConflictException {
      _setLoading(false);
      _showConflictDialog(l10n);
    } catch (e) {
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgAppleLoginFailed(e.toString()))),
        );
      }
    }
  }

  // --- 🔄 MERGE CONFLICT DIALOG ---
  void _showConflictDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.dialogSyncConflictTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.dialogSyncConflictContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _resolveConflict(merge: false, l10n: l10n);
            },
            child: Text(l10n.btnOverwriteLocal, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resolveConflict(merge: true, l10n: l10n);
            },
            child: Text(l10n.btnMergeData, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveConflict({required bool merge, required AppLocalizations l10n}) async {
    try {
      _setLoading(true);
      await getIt<AuthService>().resolveDataConflict(mergeData: merge);
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgSyncCompleted)));
        _navigateToHome();
      }
    } catch (e) {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MeshBackground(
        isFasting: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // Логотип
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department, size: 50, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Fastable",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingTitle, // "Your personal fasting tracker"
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                  ),
                  const Spacer(flex: 3),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  else ...[
                    // Кнопка Google
                    GestureDetector(
                      onTap: () => _handleGoogleSignIn(l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.g_mobiledata, color: Colors.black, size: 28),
                            const SizedBox(width: 8),
                            Text(l10n.signInGoogle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Кнопка Apple (Только iOS)
                    if (!isAndroid)
                      GestureDetector(
                        onTap: () => _handleAppleSignIn(l10n),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(l10n.signInApple, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Продолжить как гость
                    GestureDetector(
                      onTap: _navigateToHome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3))),
                        child: Center(
                          child: Text(l10n.continueGuest ?? "Continue as Guest", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}