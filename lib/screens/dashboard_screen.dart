import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fastable/injection.dart'; // Для getIt
import 'package:fastable/services/notification_service.dart'; // <--- Импорт сервиса уведомлений
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/insight/insight_bloc.dart'; // Блок инсайтов
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
  // Рекламный баннер
  Widget _buildBannerAd() {
    final BannerAd bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdFailedToLoad: (ad, err) => ad.dispose()),
    )..load();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;

    // 1. Предоставляем InsightBloc всему экрану
    return BlocProvider(
      create: (_) => getIt<InsightBloc>(),

      // 2. Используем BlocConsumer, чтобы реагировать на покупку PRO
      child: BlocConsumer<ProBloc, ProState>(
          listener: (context, proState) {
            // 🔔 ЛОГИКА УВЕДОМЛЕНИЙ
            // Если статус PRO изменился, обновляем планировщик уведомлений
            if (proState.isPro) {
              final notificationService = getIt<NotificationService>();
              notificationService.requestPermissions().then((_) {
                // Планируем инсайт на 9 утра
                notificationService.scheduleDailyInsight(l10n);
              });
            } else {
              // Если подписка слетела — отменяем
              getIt<NotificationService>().cancelDailyInsight();
            }
          },
          builder: (context, proState) {
            final isPro = true;
            final showAds = isAndroid || !isPro;
            final showProBanner = !isAndroid && !isPro;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER ROW
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

                          // Кнопка AI COACH
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, CoachScreen.route());
                            },
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
                      const SizedBox(height: 24),

                      // 1. TIMER
                      const FastingTimerCard(),

                      const SizedBox(height: 16),

                      // --- ИНСАЙТ ОТ ИИ ---
                      // Показываем карточку. Если isPro=false, она сама покажет "замок" и размытие.
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InsightCard(isPro: isPro),
                      ),

                      // 2. STATS
                      const StatsRow(),

                      const SizedBox(height: 16),

                      // 3. WATER & WEIGHT
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
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(l10n.proBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(l10n.proBannerDesc, style: const TextStyle(color: Colors.white54, fontSize: 13))
                            ]),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3))
                          ]),
                        ),

                      const SizedBox(height: 20),

                      if (showAds) _buildBannerAd(),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}