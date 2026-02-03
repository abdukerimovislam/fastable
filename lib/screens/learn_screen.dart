import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

import 'package:fastable/bloc/article/article_bloc.dart';
import 'package:fastable/bloc/article/article_event.dart';
import 'package:fastable/bloc/article/article_state.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/l10n/app_localizations.dart'; // ВАЖНО
import 'package:url_launcher/url_launcher.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // 0 = Articles, 1 = Recipes
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = context.read<SettingsBloc>().state.locale.languageCode;
    final l10n = AppLocalizations.of(context)!; // Получаем локализацию

    return BlocProvider(
      create: (context) => getIt<ArticleBloc>()..add(LoadArticles(locale)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ProBloc, ProState>(
            builder: (context, proState) {
              final isPro = proState.isPro;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ЗАГОЛОВОК
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Text(
                        l10n.learnTitle, // "Learn & Eat"
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildSegmentedControl(l10n),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // КОНТЕНТ (В ЗАВИСИМОСТИ ОТ ВКЛАДКИ)
                  if (_selectedIndex == 0)
                    ..._buildArticlesTab(context, isPro, l10n)
                  else
                    ..._buildRecipesTab(context, isPro, l10n),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGETS: ПЕРЕКЛЮЧАТЕЛЬ ---

  Widget _buildSegmentedControl(AppLocalizations l10n) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Анимированный фон активной вкладки
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: _selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
              ),
            ),
          ),
          // Текстовые кнопки
          Row(
            children: [
              _buildTabButton(l10n.tabArticles, 0),
              _buildTabButton(l10n.tabRecipes, 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final bool isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_selectedIndex != index) {
            getIt<HapticService>().selectionClick();
            setState(() => _selectedIndex = index);
          }
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  // --- TAB: ARTICLES ---

  List<Widget> _buildArticlesTab(BuildContext context, bool isPro, AppLocalizations l10n) {
    return [
      // Категории
      SliverToBoxAdapter(
        child: SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryCard(l10n.catBasics, Icons.book, Colors.blueAccent),
              const SizedBox(width: 12),
              _buildCategoryCard(l10n.catNutrition, Icons.restaurant, Colors.greenAccent),
              const SizedBox(width: 12),
              _buildCategoryCard(l10n.catHealth, Icons.favorite, Colors.redAccent),
              const SizedBox(width: 12),
              _buildCategoryCard(l10n.catKeto, Icons.bolt, Colors.orangeAccent),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Text(l10n.headerLatestArticles, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state.status == ArticleStatus.loading) {
            return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.white)));
          }
          if (state.articles.isEmpty) {
            return SliverToBoxAdapter(child: Center(child: Text(l10n.statusNoArticles, style: const TextStyle(color: Colors.white54))));
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final article = state.articles[index];
                return _buildArticleItem(context, article: article, isPro: isPro, l10n: l10n);
              },
              childCount: state.articles.length,
            ),
          );
        },
      ),
    ];
  }

  // --- TAB: RECIPES ---

  List<Widget> _buildRecipesTab(BuildContext context, bool isPro, AppLocalizations l10n) {
    // Mock Data (В будущем из API). Названия пока на английском, так как это данные.
    final mockRecipes = [
      {'title': 'Avocado Salad', 'cal': 320, 'time': 10, 'isPro': false, 'color': Colors.greenAccent},
      {'title': 'Keto Steak', 'cal': 540, 'time': 25, 'isPro': true, 'color': Colors.redAccent},
      {'title': 'Berry Smoothie', 'cal': 180, 'time': 5, 'isPro': false, 'color': Colors.purpleAccent},
      {'title': 'Salmon Delight', 'cal': 450, 'time': 30, 'isPro': true, 'color': Colors.orangeAccent},
    ];

    return [
      if (!isPro)
        SliverToBoxAdapter(child: _buildProBanner(context, l10n)),

      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        sliver: SliverToBoxAdapter(
          child: Text(l10n.headerHealthyChoices, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),

      SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final recipe = mockRecipes[index];
            return _buildRecipeItem(
              context,
              title: recipe['title'] as String,
              cal: recipe['cal'] as int,
              time: recipe['time'] as int,
              isProRequired: recipe['isPro'] as bool,
              color: recipe['color'] as Color,
              userIsPro: isPro,
              l10n: l10n,
            );
          },
          childCount: mockRecipes.length,
        ),
      ),
    ];
  }

  // --- ITEMS ---

  Widget _buildArticleItem(BuildContext context, {required dynamic article, required bool isPro, required AppLocalizations l10n}) {
    final bool isLocked = article.isPro && !isPro;
    final Color imageColor = isLocked ? Colors.purpleAccent : Colors.blueAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: GestureDetector(
        onTap: () async {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          } else {
            getIt<HapticService>().selectionClick();
            if (article.contentUrl.isNotEmpty) {
              final uri = Uri.parse(article.contentUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgComingSoon)));
            }
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: imageColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(isLocked ? Icons.lock : Icons.article, color: imageColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(article.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isLocked) const Icon(Icons.lock_outline, color: Colors.amber)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeItem(BuildContext context, {
    required String title,
    required int cal,
    required int time,
    required bool isProRequired,
    required Color color,
    required bool userIsPro,
    required AppLocalizations l10n,
  }) {
    final isLocked = isProRequired && !userIsPro;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          } else {
            // Тут навигация к деталям рецепта
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.restaurant_menu, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        // Используем переводы для единиц измерения
                        Text("$cal ${l10n.unitKcal}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule, size: 14, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text("$time ${l10n.unitMin}", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_outline, color: Colors.amber)
              else
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return GlassCard(
      width: 100, padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)), const SizedBox(height: 12), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
    );
  }

  Widget _buildProBanner(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF9D423), Color(0xFFFF4E50)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.learnBannerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(l10n.learnBannerSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}