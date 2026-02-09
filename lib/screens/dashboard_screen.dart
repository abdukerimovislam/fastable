import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fastable/injection.dart'; // Для getIt
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/insight/insight_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/coach_screen.dart';

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

  // 🔥 РЕАЛЬНЫЕ ID РЕКЛАМЫ (Для релиза)
  // Убедитесь, что эти ID активны в AdMob
  final String _bannerId = Platform.isAndroid
      ? 'ca-app-pub-7039790177400209/1487192350' // Android Real ID
      : 'ca-app-pub-7039790177400209/1487192350'; // iOS Real ID

  final String _interstitialId = Platform.isAndroid
      ? 'ca-app-pub-7039790177400209/3371119662' // Android Real ID
      : 'ca-app-pub-7039790177400209/3371119662'; // iOS Real ID

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // --- МЕТОДЫ РЕКЛАМЫ ---

  void _loadAds() {
    // 1. Загрузка Баннера
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

    // 2. Загрузка Межстраничной рекламы (для кнопки Старт)
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          // Перезагружаем рекламу после закрытия
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitial(); // Загружаем следующую сразу
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

  /// Метод, который мы передадим в FastingTimerCard
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Сбрасываем, новая загрузится через колбэк
    } else {
      // Если реклама еще не загрузилась, пробуем загрузить снова
      _loadInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid; // 🔥 Проверка платформы

    return BlocProvider(
      create: (_) => getIt<InsightBloc>(),
      child: BlocConsumer<ProBloc, ProState>(
        listener: (context, proState) {
          // Определяем, нужно ли показывать рекламу
          // Android: Всегда ДА. iOS: Только если НЕ Pro.
          final shouldShowAds = isAndroid || !proState.isPro;

          if (!shouldShowAds) {
            // Если мы на iOS и купили Pro -> Убираем всю рекламу
            _bannerAd?.dispose();
            _interstitialAd?.dispose();
            setState(() {
              _bannerAd = null;
              _isBannerReady = false;
            });

            // Включаем уведомления с инсайтами (только для Pro)
            final notificationService = getIt<NotificationService>();
            notificationService.requestPermissions().then((_) {
              notificationService.scheduleDailyInsight(l10n);
            });
          } else {
            // Если мы на Android или iOS Free -> Грузим рекламу
            if (!_isBannerReady && _bannerAd == null) {
              _loadAds();
            }
            // Отключаем инсайты (так как они для Pro)
            getIt<NotificationService>().cancelDailyInsight();
          }
        },
        builder: (context, proState) {
          // 🔥 ЛОГИКА UI
          // 1. Реклама: Android = Всегда, iOS = Если не Pro
          final showAds = isAndroid || !proState.isPro;

          // 2. Pro Баннер: Android = Никогда, iOS = Если не Pro
          final showProBanner = !isAndroid && !proState.isPro;

          // 3. Pro Фичи (Коуч, Инсайты): Android = Нет, iOS = Да (доступность внутри виджетов может зависеть от Pro)
          // *Примечание: На iOS мы показываем карточки, но блокируем контент замком. На Android скрываем полностью.*
          final showProFeatures = !isAndroid;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ROW ---
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
                        // 🔥 КНОПКА КОУЧА (Скрыта на Android)
                        if (showProFeatures)
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
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- 🔥 РЕКЛАМНЫЙ БАННЕР (ПО ЦЕНТРУ) ---
                    if (showAds && _isBannerReady && _bannerAd != null) ...[
                      Container(
                        width: double.infinity,
                        height: _bannerAd!.size.height.toDouble(),
                        alignment: Alignment.center,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // --- 1. TIMER ---
                    FastingTimerCard(
                      // Если реклама включена, передаем функцию показа
                      onStartFasting: showAds ? _showInterstitialAd : null,
                    ),

                    const SizedBox(height: 16),

                    // --- 2. ИНСАЙТ (Скрыт на Android) ---
                    if (showProFeatures)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InsightCard(isPro: proState.isPro),
                      ),

                    // --- 3. STATS ---
                    const StatsRow(),

                    const SizedBox(height: 16),

                    // --- 4. WATER & WEIGHT ---
                    const WaterWeightRow(),

                    const SizedBox(height: 16),

                    // --- PRO BANNER (Только на iOS Free) ---
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
          );
        },
      ),
    );
  }
}