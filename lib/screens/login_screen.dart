import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastable/injection.dart';
import 'package:fastable/services/auth_service.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/home_page.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/utils/app_session_refresh.dart';
import 'package:fastable/ui/app_layout.dart';

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

  Future<void> _navigateToHome() async {
    if (!mounted) return;

    await AppSessionRefresh.refresh(context);
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<void> _handleGoogleSignIn(AppLocalizations l10n) async {
    try {
      _setLoading(true);
      final user = await getIt<AuthService>().signInWithGoogle();
      _setLoading(false);
      if (user != null) {
        await _navigateToHome();
      }
    } on DataConflictException {
      _setLoading(false);
      _showConflictDialog(l10n);
    } on AuthFlowException catch (e) {
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedAuthError(l10n, e.error))),
        );
      }
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
      if (user != null) {
        await _navigateToHome();
      }
    } on DataConflictException {
      _setLoading(false);
      _showConflictDialog(l10n);
    } on AuthFlowException catch (e) {
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedAuthError(l10n, e.error))),
        );
      }
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
        title: Text(
          l10n.dialogSyncConflictTitle,
          style: const TextStyle(color: Colors.white),
        ),
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
            child: Text(
              l10n.btnOverwriteLocal,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resolveConflict(merge: true, l10n: l10n);
            },
            child: Text(
              l10n.btnMergeData,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveConflict({
    required bool merge,
    required AppLocalizations l10n,
  }) async {
    try {
      _setLoading(true);
      await getIt<AuthService>().resolveDataConflict(mergeData: merge);
      _setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.msgSyncCompleted)));
        await _navigateToHome();
      }
    } catch (e) {
      _setLoading(false);
    }
  }

  String _localizedAuthError(AppLocalizations l10n, AuthFlowError error) {
    switch (error) {
      case AuthFlowError.googleSignInFailed:
        return l10n.authGoogleFailed;
      case AuthFlowError.appleSignInUnavailable:
        return l10n.authAppleUnavailable;
      case AuthFlowError.appleSignInFailed:
        return l10n.authAppleFailed;
    }
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;
    final edgePadding = AppLayout.edgePadding(context) + 4;
    final cardPadding = AppLayout.cardPadding(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MeshBackground(
        isFasting: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: edgePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      GlassCard(
                        padding: EdgeInsets.all(cardPadding + 4),
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withValues(alpha: 0.9),
                                    const Color(0xFF43C6AC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                size: 46,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              "Fastable",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.onboardingTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.authSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFeaturePill(
                                  icon: Icons.auto_awesome_rounded,
                                  label: l10n.featureCoach,
                                  color: Colors.purpleAccent,
                                ),
                                _buildFeaturePill(
                                  icon: Icons.restaurant_menu_rounded,
                                  label: l10n.featureRecipes,
                                  color: Colors.greenAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GlassCard(
                        padding: EdgeInsets.all(cardPadding),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _handleGoogleSignIn(l10n),
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      size: 28,
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    label: Text(
                                      l10n.signInGoogle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (!isAndroid) ...[
                                    const SizedBox(height: 12),
                                    FilledButton.icon(
                                      onPressed: () => _handleAppleSignIn(l10n),
                                      icon: const Icon(Icons.apple, size: 22),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.08),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      label: Text(
                                        l10n.signInApple,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: _navigateToHome,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.continueGuest,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
