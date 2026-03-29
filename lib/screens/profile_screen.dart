import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- DI & BLOC ---
import 'package:fastable/injection.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
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
import 'package:fastable/utils/roulette_sheet.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/login_screen.dart';
import 'package:fastable/widgets/mesh_background.dart';
import 'package:fastable/utils/onboarding_personalization.dart';
import 'package:fastable/utils/app_session_refresh.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/premium_bottom_sheet_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- LOCALIZATION HELPERS ---
  String _getAchTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'achFirstFast':
        return l10n.achFirstFast;
      case 'achStreak3':
        return l10n.achStreak3;
      case 'achStreak7':
        return l10n.achStreak7;
      case 'achTotal10':
        return l10n.achTotal10;
      case 'achTotalHours100':
        return l10n.achTotalHours100;
      default:
        return key;
    }
  }

  String _getAchDesc(AppLocalizations l10n, String key) {
    switch (key) {
      case 'achFirstFastDesc':
        return l10n.achFirstFastDesc;
      case 'achStreak3Desc':
        return l10n.achStreak3Desc;
      case 'achStreak7Desc':
        return l10n.achStreak7Desc;
      case 'achTotal10Desc':
        return l10n.achTotal10Desc;
      case 'achTotalHours100Desc':
        return l10n.achTotalHours100Desc;
      default:
        return "";
    }
  }

  // --- 🔐 AUTH ACTIONS ---
  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      _showLoading(context);
      final user = await getIt<AuthService>().signInWithGoogle();
      if (context.mounted) {
        Navigator.pop(context);
        if (user != null) {
          await AppSessionRefresh.refresh(context);
        }
      }
    } on DataConflictException {
      if (context.mounted) {
        Navigator.pop(context);
        _showConflictDialog(context, l10n);
      }
    } on AuthFlowException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedAuthError(l10n, e.error))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgLoginFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      _showLoading(context);
      final user = await getIt<AuthService>().signInWithApple();
      if (context.mounted) {
        Navigator.pop(context);
        if (user != null) {
          await AppSessionRefresh.refresh(context);
        }
      }
    } on DataConflictException {
      if (context.mounted) {
        Navigator.pop(context);
        _showConflictDialog(context, l10n);
      }
    } on AuthFlowException catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizedAuthError(l10n, e.error))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgAppleLoginFailed(e.toString()))),
        );
      }
    }
  }

  void _handleSignOut(BuildContext context) async {
    await getIt<AuthService>().signOut();
    if (context.mounted) {
      await AppSessionRefresh.refresh(context);
    }
    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _handleDeleteAccount(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppLayout.edgePadding(context) + 8,
        ),
        child: GlassCard(
          padding: EdgeInsets.all(AppLayout.cardPadding(context) + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.confirmDeleteMsg,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          _showLoading(context);
                          await getIt<AuthService>().deleteAccount();
                          if (context.mounted) {
                            Navigator.pop(context);
                            await AppSessionRefresh.refresh(context);
                          }
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        } on AccountDeletionException catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _localizedDeleteError(l10n, e.error),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.msgDeleteError)),
                            );
                          }
                        }
                      },
                      child: Text(l10n.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConflictDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppLayout.edgePadding(context) + 8,
        ),
        child: GlassCard(
          padding: EdgeInsets.all(AppLayout.cardPadding(context) + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dialogSyncConflictTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.dialogSyncConflictContent,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _resolve(context, merge: false, l10n: l10n);
                      },
                      child: Text(l10n.btnOverwriteLocal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _resolve(context, merge: true, l10n: l10n);
                      },
                      child: Text(l10n.btnMergeData),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context, {
    required bool merge,
    required AppLocalizations l10n,
  }) async {
    try {
      _showLoading(context);
      await getIt<AuthService>().resolveDataConflict(mergeData: merge);
      if (context.mounted) {
        Navigator.pop(context);
        await AppSessionRefresh.refresh(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.msgSyncCompleted)));
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppLayout.edgePadding(context) + 32,
        ),
        child: const GlassCard(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator(color: Colors.white)],
          ),
        ),
      ),
    );
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

  String _localizedDeleteError(
    AppLocalizations l10n,
    AccountDeletionError error,
  ) {
    switch (error) {
      case AccountDeletionError.reauthenticationCancelled:
        return l10n.msgDeleteReauthCancelled;
      case AccountDeletionError.reauthenticationFailed:
        return l10n.msgDeleteReauthFailed;
      case AccountDeletionError.reauthenticationUnavailable:
        return l10n.msgDeleteReauthUnavailable;
      case AccountDeletionError.deleteFailed:
        return l10n.msgDeleteError;
    }
  }

  // --- PICKERS ---
  void _showHeightPicker(
    BuildContext context,
    double currentHeight,
    AppLocalizations l10n,
  ) {
    getIt<HapticService>().mediumImpact();
    showRouletteSheet<int>(
      context: context,
      title: l10n.selectHeight,
      items: List.generate(151, (index) => 100 + index),
      initialItem: currentHeight.toInt().clamp(100, 250),
      textMapper: (val) => "$val cm",
      onSave: (val) =>
          context.read<WeightBloc>().add(UpdateHeight(val.toDouble())),
    );
  }

  void _showWeightPicker(
    BuildContext context,
    double currentWeight,
    AppLocalizations l10n,
  ) {
    getIt<HapticService>().mediumImpact();
    double current = (currentWeight * 10).round() / 10.0;
    if (current < 30.0) current = 70.0;
    showRouletteSheet<double>(
      context: context,
      title: l10n.selectWeight,
      items: List.generate(2700, (index) => 30.0 + (index * 0.1)),
      initialItem: current,
      textMapper: (val) => "${val.toStringAsFixed(1)} ${l10n.unitKg}",
      onSave: (val) => context.read<WeightBloc>().add(AddWeightEntry(val)),
    );
  }

  void _showAgePicker(
    BuildContext context,
    int currentAge,
    AppLocalizations l10n,
  ) {
    getIt<HapticService>().mediumImpact();
    showRouletteSheet<int>(
      context: context,
      title: l10n.selectAge,
      items: List.generate(91, (index) => 10 + index),
      initialItem: currentAge.clamp(10, 100),
      textMapper: (val) => "$val",
      onSave: (val) => context.read<WeightBloc>().add(UpdateAge(val)),
    );
  }

  void _showGenderPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PremiumBottomSheetScaffold(
        maxHeightFactor: 0.56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectGender,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _buildOptionItem(
              ctx,
              title: l10n.genderMale,
              icon: Icons.male_rounded,
              onTap: () => context.read<WeightBloc>().add(
                const UpdateGender(Gender.male),
              ),
            ),
            const SizedBox(height: 10),
            _buildOptionItem(
              ctx,
              title: l10n.genderFemale,
              icon: Icons.female_rounded,
              onTap: () => context.read<WeightBloc>().add(
                const UpdateGender(Gender.female),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PremiumBottomSheetScaffold(
        maxHeightFactor: 0.66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectActivity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _buildOptionItem(
              ctx,
              title: l10n.activitySedentary,
              icon: Icons.self_improvement_rounded,
              onTap: () => context.read<WeightBloc>().add(
                const UpdateActivityLevel(ActivityLevel.sedentary),
              ),
            ),
            const SizedBox(height: 10),
            _buildOptionItem(
              ctx,
              title: l10n.activityModerate,
              icon: Icons.directions_walk_rounded,
              onTap: () => context.read<WeightBloc>().add(
                const UpdateActivityLevel(ActivityLevel.moderate),
              ),
            ),
            const SizedBox(height: 10),
            _buildOptionItem(
              ctx,
              title: l10n.activityActive,
              icon: Icons.local_fire_department_rounded,
              onTap: () => context.read<WeightBloc>().add(
                const UpdateActivityLevel(ActivityLevel.active),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: () {
        getIt<HapticService>().selectionClick();
        onTap();
        Navigator.pop(context);
      },
      padding: EdgeInsets.all(AppLayout.cardPadding(context)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white70),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.34),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSignalChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOnboardingSummary(
    AppLocalizations l10n,
    OnboardingPersonalizationSnapshot personalization,
  ) {
    if (!personalization.hasCompletedOnboarding) {
      return const SizedBox.shrink();
    }

    final currentPlan = personalization.localizedCurrentPlan(l10n);
    final recommendedPlan = personalization.localizedRecommendedPlan();

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.smartPlanProfileTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "${l10n.smartPlanCurrentPlanLabel}: $currentPlan",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${l10n.smartPlanRecommendedPlanLabel}: $recommendedPlan",
            style: TextStyle(
              color: Colors.amber.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            personalization.localizedReason(l10n),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.smartPlanSignalsLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSignalChip(
                personalization.localizedGoal(l10n),
                Colors.greenAccent,
              ),
              _buildSignalChip(
                personalization.localizedExperience(l10n),
                Colors.blueAccent,
              ),
              _buildSignalChip(
                personalization.localizedSleepPattern(l10n),
                Colors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;
    final onboardingProfile = context
        .select<OnboardingProfileCubit, OnboardingProfileState>(
          (cubit) => cubit.state,
        );
    final weightState = context.select<WeightBloc, WeightState>(
      (bloc) => bloc.state,
    );
    final fastingState = context.select<FastingBloc, FastingState>(
      (bloc) => bloc.state,
    );
    final personalization = OnboardingPersonalizationSnapshot.fromState(
      onboardingProfile: onboardingProfile,
      weightState: weightState,
      fastingState: fastingState,
    );
    final cardPadding = AppLayout.cardPadding(context);

    return StreamBuilder(
      stream: getIt<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        final user = getIt<AuthService>().currentUser;
        final isGuest = user == null || user.isAnonymous;
        final photoUrl = isGuest ? null : user.photoURL;

        return MeshBackground(
          isFasting: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: AppLayout.screenPadding(
                  context,
                  top: 18,
                  bottom: 32,
                  includeBottomSafeArea: true,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок с кнопкой Назад
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.navProfile,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isGuest
                                          ? l10n.saveProgressCloud
                                          : (user.email ?? l10n.defaultUser),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.56,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 1. АККАУНТ И ВХОД
                        GlassCard(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: isGuest
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : Colors.blueAccent.withValues(
                                            alpha: 0.2,
                                          ),
                                    backgroundImage: photoUrl != null
                                        ? NetworkImage(photoUrl)
                                        : null,
                                    child: photoUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isGuest
                                              ? l10n.guestUser
                                              : (user.displayName ??
                                                    l10n.defaultUser),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isGuest
                                              ? l10n.authSubtitle
                                              : (user.email ?? ""),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.54,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isGuest)
                                    _buildSignalChip(
                                      l10n.guestUser,
                                      Colors.orangeAccent,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (isGuest) ...[
                                _buildAccountActionCard(
                                  context,
                                  icon: Icons.cloud_upload_rounded,
                                  title: l10n.signInGoogle,
                                  subtitle: l10n.saveProgressCloud,
                                  color: Colors.white,
                                  onTap: () =>
                                      _handleGoogleSignIn(context, l10n),
                                ),
                                if (!isAndroid) ...[
                                  const SizedBox(height: 10),
                                  _buildAccountActionCard(
                                    context,
                                    icon: Icons.apple_rounded,
                                    title: l10n.signInApple,
                                    subtitle: l10n.saveProgressCloud,
                                    color: Colors.white70,
                                    onTap: () =>
                                        _handleAppleSignIn(context, l10n),
                                  ),
                                ],
                              ] else ...[
                                _buildAccountActionCard(
                                  context,
                                  icon: Icons.logout_rounded,
                                  title: l10n.signOut,
                                  subtitle: user.email ?? l10n.defaultUser,
                                  color: Colors.redAccent,
                                  onTap: () => _handleSignOut(context),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOnboardingSummary(l10n, personalization),

                        // 2. ДОСТИЖЕНИЯ
                        const SizedBox(height: 30),
                        _sectionHeader(l10n.lblAchievements),
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
                                  final isUnlocked = state.unlockedAchievements
                                      .any((a) => a.id == ach.id);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        getIt<HapticService>().selectionClick();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFF1E1E1E,
                                            ),
                                            content: Row(
                                              children: [
                                                Icon(
                                                  ach.icon,
                                                  color: isUnlocked
                                                      ? ach.color
                                                      : Colors.grey,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _getAchTitle(
                                                          l10n,
                                                          ach.titleKey,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        isUnlocked
                                                            ? _getAchDesc(
                                                                l10n,
                                                                ach.descKey,
                                                              )
                                                            : l10n.statusLocked,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: GlassCard(
                                        width: 100,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 12,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: isUnlocked
                                                    ? ach.color.withValues(
                                                        alpha: 0.2,
                                                      )
                                                    : Colors.white.withValues(
                                                        alpha: 0.05,
                                                      ),
                                                shape: BoxShape.circle,
                                                boxShadow: isUnlocked
                                                    ? [
                                                        BoxShadow(
                                                          color: ach.color
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          blurRadius: 10,
                                                        ),
                                                      ]
                                                    : [],
                                              ),
                                              child: Icon(
                                                ach.icon,
                                                color: isUnlocked
                                                    ? ach.color
                                                    : Colors.white24,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _getAchTitle(
                                                l10n,
                                                ach.titleKey,
                                              ).toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isUnlocked
                                                    ? Colors.white
                                                    : Colors.white24,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // 3. ФИЗИЧЕСКИЕ ДАННЫЕ
                        const SizedBox(height: 30),
                        _sectionHeader(l10n.lblPersonalData),
                        BlocBuilder<WeightBloc, WeightState>(
                          builder: (context, weightState) {
                            return GlassCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  _buildSettingsTile(
                                    icon: Icons.height,
                                    title: l10n.selectHeight,
                                    value: "${weightState.heightCm.toInt()} cm",
                                    onTap: () => _showHeightPicker(
                                      context,
                                      weightState.heightCm,
                                      l10n,
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Colors.white10,
                                  ),
                                  _buildSettingsTile(
                                    icon: Icons.monitor_weight_outlined,
                                    title: l10n.selectWeight,
                                    value:
                                        "${weightState.currentWeight.toInt()} ${l10n.unitKg}",
                                    onTap: () => _showWeightPicker(
                                      context,
                                      weightState.currentWeight,
                                      l10n,
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Colors.white10,
                                  ),
                                  _buildSettingsTile(
                                    icon: Icons.cake_outlined,
                                    title: l10n.selectAge,
                                    value: "${weightState.age}",
                                    onTap: () => _showAgePicker(
                                      context,
                                      weightState.age,
                                      l10n,
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Colors.white10,
                                  ),
                                  _buildSettingsTile(
                                    icon: Icons.wc,
                                    title: l10n.selectGender,
                                    value: weightState.gender == Gender.male
                                        ? l10n.genderMale
                                        : l10n.genderFemale,
                                    onTap: () =>
                                        _showGenderPicker(context, l10n),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Colors.white10,
                                  ),
                                  _buildSettingsTile(
                                    icon: Icons.local_fire_department_outlined,
                                    title: l10n.selectActivity,
                                    value: _getActivityLabel(
                                      l10n,
                                      weightState.activityLevel,
                                    ),
                                    onTap: () =>
                                        _showActivityPicker(context, l10n),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // 4. ОПАСНАЯ ЗОНА (УДАЛЕНИЕ АККАУНТА)
                        const SizedBox(height: 40),
                        GlassCard(
                          padding: EdgeInsets.all(cardPadding),
                          color: Colors.redAccent.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.deleteAccount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.confirmDeleteMsg,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.66),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _handleDeleteAccount(context, l10n),
                                  icon: Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.86,
                                    ),
                                  ),
                                  label: Text(
                                    l10n.deleteAccount,
                                    style: TextStyle(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.86,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPERS ---
  String _getActivityLabel(AppLocalizations l10n, ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return l10n.activitySedentary;
      case ActivityLevel.moderate:
        return l10n.activityModerate;
      case ActivityLevel.active:
        return l10n.activityActive;
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAccountActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppLayout.cardPadding(context)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.28),
            size: 16,
          ),
        ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
