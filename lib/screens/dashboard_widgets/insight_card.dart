import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/bloc/insight/insight_bloc.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/screens/pro_screen.dart'; // Для перехода на оплату

class InsightCard extends StatelessWidget {
  final bool isPro; // <--- Принимаем статус подписки

  const InsightCard({
    super.key,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ЕСЛИ ПОЛЬЗОВАТЕЛЬ FREE -> ПОКАЗЫВАЕМ ТИЗЕР (РАЗМЫТО)
    // Мы не вызываем Bloc, чтобы не тратить лимиты API на бесплатных юзеров
    if (!isPro) {
      return _buildLockedState(context);
    }

    // 2. ЕСЛИ PRO -> ГРУЗИМ РЕАЛЬНЫЙ ИНСАЙТ
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<InsightBloc, InsightState>(
      builder: (context, state) {
        if (state is InsightInitial) {
          // ЗАПУСКАЕМ ЗАГРУЗКУ
          context.read<InsightBloc>().add(FetchDailyInsight(
            fallbackText: l10n.aiInsightFallback,
            notEnoughDataText: l10n.aiInsightNotEnoughData, // <--- ВАЖНО: Добавили этот параметр
            languageCode: locale,
          ));
          return const SizedBox.shrink();
        }

        if (state is InsightLoading) {
          return _buildLoadingShimmer();
        }

        if (state is InsightLoaded) {
          return GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 12),
                Text(
                  state.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        // На случай ошибки или другого состояния
        return const SizedBox.shrink();
      },
    );
  }

  // --- ЗАГОЛОВОК ---
  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          l10n.aiInsightTitle, // "DAILY INSIGHT"
          style: TextStyle(
            color: Colors.purpleAccent.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // --- РЕЖИМ "LOCKED" (РАЗМЫТИЕ) ---
  Widget _buildLockedState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        // При клике ведем на экран покупки
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // СЛОЙ 1: Размытый контент
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 12),

                // Эффект размытия только на тексте
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // Сила размытия
                  child: Text(
                    l10n.aiInsightTeaser, // "Based on your last 7 days..."
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5), // Делаем текст тусклым
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            // СЛОЙ 2: Замок и кнопка поверх размытия
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                // Легкое затемнение, чтобы текст читался лучше
                color: Colors.black.withOpacity(0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                      ),
                      child: const Icon(Icons.lock, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapToUnlock,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- РЕЖИМ ЗАГРУЗКИ ---
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: GlassCard(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 12, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 12, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}