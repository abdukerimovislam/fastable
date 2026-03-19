import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upgrader/upgrader.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/insight/insight_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/coach_screen.dart';
import 'package:fastable/screens/medical_disclaimer_screen.dart';
import 'package:fastable/screens/profile_screen.dart'; // 🔥 ИСПРАВЛЕНИЕ: Добавлен импорт экрана профиля

import 'package:fastable/screens/dashboard_widgets/fasting_timer_card.dart';
import 'package:fastable/screens/dashboard_widgets/water_weight_row.dart';
import 'package:fastable/screens/dashboard_widgets/stats_row.dart';
import 'package:fastable/screens/dashboard_widgets/insight_card.dart';

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

  final String _bannerId = Platform.isAndroid
      ? 'ca-app-pub-7039790177400209/1487192350'
      : 'ca-app-pub-7039790177400209/7671069742';

  final String _interstitialId = Platform.isAndroid
      ? 'ca-app-pub-7039790177400209/3371119662'
      : 'ca-app-pub-7039790177400209/9605397701';

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

    final isPro = context.read<ProBloc>().state.isPro;
    if (Platform.isAndroid || !isPro) {
      _loadAds();
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
          debugPrint('Banner failed: $err');
          ad.dispose();
        },
      ),
    )..load();

    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
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
        onAdFailedToLoad: (err) => debugPrint('Interstitial failed: $err'),
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

    return BlocProvider(
      create: (_) => getIt<InsightBloc>(),
      child: BlocConsumer<ProBloc, ProState>(
        listener: (context, proState) {
          final shouldShowAds = isAndroid || !proState.isPro;

          if (!shouldShowAds) {
            _bannerAd?.dispose();
            _interstitialAd?.dispose();
            setState(() {
              _bannerAd = null;
              _isBannerReady = false;
            });

            final notificationService = getIt<NotificationService>();
            notificationService.requestPermissions().then((_) {
              notificationService.scheduleDailyInsight(l10n);
            });
          } else {
            if (!_isBannerReady && _bannerAd == null) {
              _loadAds();
            }
            getIt<NotificationService>().cancelDailyInsight();
          }
        },
        builder: (context, proState) {
          final showAds = isAndroid || !proState.isPro;
          final showProBanner = !isAndroid && !proState.isPro;
          final showProFeatures = !isAndroid;

          return UpgradeAlert(
            upgrader: Upgrader(),
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 100 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.dashboardToday, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                              Text(l10n.dashboardOverview, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              // 🔥 ИСПРАВЛЕНИЕ: Кнопка Профиля (левее всех)
                              IconButton(
                                icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                              ),

                              // Кнопка дисклеймера
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.white54, size: 28),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalDisclaimerScreen())),
                              ),

                              // Кнопка ИИ-коуча
                              if (showProFeatures) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, CoachScreen.route()),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1),
                                    ),
                                    child: const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 28),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (showAds && _isBannerReady && _bannerAd != null) ...[
                        Container(
                          width: double.infinity,
                          height: _bannerAd!.size.height.toDouble(),
                          alignment: Alignment.center,
                          child: AdWidget(ad: _bannerAd!),
                        ),
                        const SizedBox(height: 16),
                      ],

                      FastingTimerCard(
                        onStartFasting: showAds ? _showInterstitialAd : null,
                      ),

                      const SizedBox(height: 16),

                      if (showProFeatures)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InsightCard(isPro: proState.isPro),
                        ),

                      const StatsRow(),
                      const SizedBox(height: 16),
                      const WaterWeightRow(),
                      const SizedBox(height: 16),

                      if (showProBanner)
                        GlassCard(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
                          child: Row(children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.star, color: Colors.amber)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(l10n.proBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(l10n.proBannerDesc, style: const TextStyle(color: Colors.white54, fontSize: 13))
                              ]),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}