import 'package:fastable/utils/logger.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/bloc/history/history_bloc.dart';
import 'package:fastable/bloc/history/history_state.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/insight/insight_bloc.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/coach_screen.dart';
import 'package:fastable/screens/medical_disclaimer_screen.dart';
import 'package:fastable/screens/profile_screen.dart';
import 'package:fastable/utils/onboarding_personalization.dart';
import 'package:fastable/ui/app_layout.dart';

import 'package:fastable/screens/dashboard_widgets/fasting_timer_card.dart';
import 'package:fastable/screens/dashboard_widgets/smart_strategy_card.dart';
import 'package:fastable/screens/dashboard_widgets/insight_card.dart';

// BENTO CARDS
import 'package:fastable/screens/dashboard_widgets/bento_water_weight_cards.dart';
import 'package:fastable/screens/dashboard_widgets/bento_health_cards.dart';
import 'package:fastable/screens/dashboard_widgets/bento_stats_cards.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- РЕКЛАМА ---
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  InterstitialAd? _interstitialAd;
  int _interstitialRetryAttempt = 0;

  final String _bannerId = Platform.isAndroid
      ? dotenv.env['ANDROID_BANNER_AD_ID'] ?? ''
      : dotenv.env['IOS_BANNER_AD_ID'] ?? '';

  final String _interstitialId = Platform.isAndroid
      ? dotenv.env['ANDROID_INTERSTITIAL_AD_ID'] ?? ''
      : dotenv.env['IOS_INTERSTITIAL_AD_ID'] ?? '';

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 800));
      final status = await Permission.appTrackingTransparency.status;
      if (status.isDenied) {
        await Permission.appTrackingTransparency.request();
      }
    }

    if (!mounted) return;

    final isPro = context.read<ProBloc>().state.isPro;
    if (Platform.isAndroid) {
      _loadAds();
    } else if (!isPro) {
      _loadInterstitial();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadAds() {
    if (_bannerAd != null) return;

    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerReady = true);
        },
        onAdFailedToLoad: (ad, err) {
          appLog('Banner failed: $err');
          ad.dispose();
          _bannerAd = null;
          _isBannerReady = false;
        },
      ),
    )..load();

    if (_interstitialAd == null) {
      _loadInterstitial();
    }
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialRetryAttempt = 0; // Сбрасываем счетчик при успехе!

          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _loadInterstitial();
                },
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _loadInterstitial();
                },
              );
        },
        onAdFailedToLoad: (err) {
          appLog('Interstitial failed: $err');

          // 🔥 ФИКС: Умная экспоненциальная задержка (Exponential backoff)
          _interstitialRetryAttempt++;
          int delaySec = (1 << _interstitialRetryAttempt).clamp(1, 64);

          Future.delayed(Duration(seconds: delaySec), () {
            if (mounted && _interstitialAd == null) {
              appLog('Retrying Interstitial Load (Attempt $_interstitialRetryAttempt)');
              _loadInterstitial();
            }
          });
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;
    final onboardingProfile = context
        .select<OnboardingProfileCubit, OnboardingProfileState>(
          (cubit) => cubit.state,
    );
    final fastingState = context.select<FastingBloc, FastingState>(
          (bloc) => bloc.state,
    );
    final weightState = context.select<WeightBloc, WeightState>(
          (bloc) => bloc.state,
    );
    final localeCode = Localizations.localeOf(context).languageCode;
    final insightHistoryKey = context.select<HistoryBloc, String>((bloc) {
      final HistoryState state = bloc.state;
      final lastEndTime = state.records.isEmpty
          ? ''
          : state.records.last.endTime.toIso8601String();
      return '${state.records.length}|${state.totalFastingTime.inMinutes}|$lastEndTime';
    });
    final insightWeightKey = context.select<WeightBloc, String>((bloc) {
      final WeightState state = bloc.state;
      final lastWeightDate = state.history.isEmpty
          ? ''
          : state.history.last.date.toIso8601String();
      return '${state.currentWeight.toStringAsFixed(1)}|${state.history.length}|$lastWeightDate';
    });
    final personalization = OnboardingPersonalizationSnapshot.fromState(
      onboardingProfile: onboardingProfile,
      weightState: weightState,
      fastingState: fastingState,
    );

    return BlocConsumer<ProBloc, ProState>(
      listener: (context, proState) {
        final shouldShowAds = isAndroid || !proState.isPro;
        final shouldShowBannerAds = Platform.isAndroid && shouldShowAds;

        if (!shouldShowAds) {
          _bannerAd?.dispose();
          _interstitialAd?.dispose();
          setState(() {
            _bannerAd = null;
            _isBannerReady = false;
          });

          final notificationService = getIt<NotificationService>();
          notificationService.scheduleDailyInsight(l10n);
        } else {
          if (shouldShowBannerAds && !_isBannerReady && _bannerAd == null) {
            _loadAds();
          } else if (!shouldShowBannerAds && _interstitialAd == null) {
            _loadInterstitial();
          }
          getIt<NotificationService>().cancelDailyInsight(
            clearPreference: true,
          );
        }
      },
      builder: (context, proState) {
        final showAds = isAndroid || !proState.isPro;
        final showBannerAds =
            Platform.isAndroid &&
                showAds &&
                _isBannerReady &&
                _bannerAd != null;

        // 🔥 ИСПРАВЛЕНИЕ: Возвращаем логику, блокирующую PRO на Android
        final showProBanner = !isAndroid && !proState.isPro;
        final showProFeatures = !isAndroid;

        final insightProviderKey = ValueKey(
          'insight:$localeCode:$insightHistoryKey:$insightWeightKey',
        );
        final sectionGap = AppLayout.sectionGap(context);

        // Grid spacing definition for StaggeredGrid
        final double gridSpacing = sectionGap;

        return UpgradeAlert(
          upgrader: Upgrader(),
          dialogStyle: Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: AnimationLimiter(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: AppLayout.screenPadding(
                    context,
                    top: 10,
                    bottom: 92,
                    includeBottomSafeArea: true,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 40.0,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // --- HEADER ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashboardOverview,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.account_circle_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileScreen(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white54,
                                    size: 28,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const MedicalDisclaimerScreen(),
                                    ),
                                  ),
                                ),
                                // 🔥 ИСПРАВЛЕНИЕ: Кнопка AI-чата видна только если showProFeatures (не Android)
                                if (showProFeatures) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      if (proState.isPro) {
                                        Navigator.push(context, CoachScreen.route());
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.purpleAccent.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.purpleAccent,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: sectionGap + 4),

                        // --- РЕКЛАМА БАННЕР ---
                        if (showBannerAds) ...[
                          Container(
                            width: double.infinity,
                            height: _bannerAd!.size.height.toDouble(),
                            alignment: Alignment.center,
                            child: AdWidget(
                              key: ObjectKey(_bannerAd),
                              ad: _bannerAd!,
                            ),
                          ),
                          SizedBox(height: sectionGap + 2),
                        ],

                        // --- THE BENTO GRID START ---
                        StaggeredGrid.count(
                          crossAxisCount: 4, // 4-column dense grid
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          children: [
                            // 1. HERO TIMER CARD (Full Width - 4 columns)
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 4,
                              child: FastingTimerCard(
                                onStartFasting: showAds ? _showInterstitialAd : null,
                                onEndFasting: showAds ? _showInterstitialAd : null,
                              ),
                            ),

                            // 2. WATER (Square - 2 columns)
                            const StaggeredGridTile.fit(
                              crossAxisCellCount: 2,
                              child: BentoWaterCard(),
                            ),

                            // 3. WEIGHT (Square - 2 columns)
                            const StaggeredGridTile.fit(
                              crossAxisCellCount: 2,
                              child: BentoWeightCard(),
                            ),

                            // 4. SMART STRATEGY (Full width - 4 columns)
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 4,
                              child: SmartStrategyCard(
                                  l10n: l10n, personalization: personalization
                              ),
                            ),

                            // --- DENSE MICRO ROW: Phase, Streak, BMI, Sleep ---
                            // Each takes 1 column (25% width) side-by-side!
                            const StaggeredGridTile.fit(
                              crossAxisCellCount: 1,
                              child: BentoPhaseCard(),
                            ),
                            const StaggeredGridTile.fit(
                              crossAxisCellCount: 1,
                              child: BentoStreakCard(),
                            ),
                            const StaggeredGridTile.fit(
                              crossAxisCellCount: 1,
                              child: BentoBmiCard(),
                            ),
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 1,
                              child: BentoHealthCards(
                                builder: (context, isLoading, isConnected, sleep, cycle, onRefresh) {
                                  return BentoSleepCard(
                                      isLoading: isLoading, isConnected: isConnected, sleepDuration: sleep, onTap: onRefresh
                                  );
                                },
                              ),
                            ),

                            // CYCLE (Full width - 4 columns)
                            StaggeredGridTile.fit(
                              crossAxisCellCount: 4,
                              child: BentoHealthCards(
                                builder: (context, isLoading, isConnected, sleep, cycle, onRefresh) {
                                  return BentoCycleCard(
                                      isLoading: isLoading, isConnected: isConnected, cycleDays: cycle, onTap: onRefresh
                                  );
                                },
                              ),
                            ),

                            // 🔥 ИСПРАВЛЕНИЕ: AI INSIGHT CARD (Показываем только если showProFeatures)
                            if (showProFeatures)
                              StaggeredGridTile.fit(
                                crossAxisCellCount: 4,
                                child: proState.isPro
                                    ? BlocProvider(
                                  key: insightProviderKey,
                                  create: (_) => getIt<InsightBloc>(),
                                  child: const InsightCard(isPro: true),
                                )
                                    : const InsightCard(isPro: false),
                              ),

                            // PRO BANNER (4 Cols)
                            if (showProBanner)
                              StaggeredGridTile.fit(
                                crossAxisCellCount: 4,
                                child: GlassCard(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProScreen()),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.star, color: Colors.amber),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.proBannerTitle,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              l10n.proBannerDesc,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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
}