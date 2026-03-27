import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

// Импорты Блоков
import 'package:fastable/bloc/article/article_bloc.dart';
import 'package:fastable/bloc/article/article_event.dart';
import 'package:fastable/bloc/article/article_state.dart';
import 'package:fastable/bloc/recipe/recipe_bloc.dart';
import 'package:fastable/bloc/recipe/recipe_event.dart';
import 'package:fastable/bloc/recipe/recipe_state.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// Модели и Локализация
import 'package:fastable/models/content_models.dart';
import 'package:fastable/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isAndroid = Platform.isAndroid;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ArticleBloc>()..add(LoadArticles(locale)),
        ),
        if (!isAndroid)
          BlocProvider(
            create: (context) => getIt<RecipeBloc>()..add(LoadRecipes(locale)),
          ),
      ],
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
                        l10n.learnTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // ПЕРЕКЛЮЧАТЕЛЬ (ТОЛЬКО НА iOS)
                  if (!isAndroid)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildSegmentedControl(l10n),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // КОНТЕНТ
                  if (isAndroid || _selectedIndex == 0)
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
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
              ),
            ),
          ),
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

  // --- TAB: ARTICLES (С интегрированными Stories) ---

  List<Widget> _buildArticlesTab(BuildContext context, bool isPro, AppLocalizations l10n) {
    return [
      // 🔥 STORIES ЛЕНТА 🔥
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Quick Bites", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStoryCircle(context, "Fasting 101", Colors.orangeAccent, Icons.local_fire_department, true),
              _buildStoryCircle(context, "Autophagy", Colors.purpleAccent, Icons.autorenew_rounded, false),
              _buildStoryCircle(context, "Keto Diet", Colors.greenAccent, Icons.eco_rounded, false),
              _buildStoryCircle(context, "Hydration", Colors.blueAccent, Icons.water_drop_rounded, false),
              _buildStoryCircle(context, "Sleep", Colors.indigoAccent, Icons.bedtime_rounded, false),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.headerLatestArticles,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state.status == ArticleStatus.loading) {
            return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.white)));
          }
          if (state.articles.isEmpty || state.status == ArticleStatus.failure) {
            return SliverToBoxAdapter(
              child: _buildComingSoonWidget(l10n, Icons.menu_book_rounded),
            );
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

  // --- TAB: RECIPES (Только iOS) ---

  List<Widget> _buildRecipesTab(BuildContext context, bool isPro, AppLocalizations l10n) {
    return [
      if (!isPro)
        SliverToBoxAdapter(child: _buildProBanner(context, l10n)),

      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        sliver: SliverToBoxAdapter(
          child: Text(
            l10n.headerHealthyChoices,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state.status == RecipeStatus.loading) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            );
          }

          if (state.recipes.isEmpty || state.status == RecipeStatus.failure) {
            return SliverToBoxAdapter(
              child: _buildComingSoonWidget(l10n, Icons.restaurant_menu),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final recipe = state.recipes[index];
                return _buildRecipeItem(context, recipe: recipe, userIsPro: isPro, l10n: l10n);
              },
              childCount: state.recipes.length,
            ),
          );
        },
      ),
    ];
  }

  // --- COMMON WIDGETS ---

  Widget _buildStoryCircle(BuildContext context, String title, Color color, IconData icon, bool hasUnseenContent) {
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening story: $title..."), backgroundColor: color),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnseenContent
                    ? const LinearGradient(colors: [Colors.pinkAccent, Colors.orangeAccent], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                border: hasUnseenContent ? null : Border.all(color: Colors.white24, width: 2),
              ),
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonWidget(AppLocalizations l10n, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.comingSoonTitle,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.comingSoonDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context,
      {required ArticleModel article,
        required bool isPro,
        required AppLocalizations l10n}) {

    final isAndroid = Platform.isAndroid;
    final bool isLocked = !isAndroid && (article.isPro && !isPro);

    final Color imageColor = isLocked ? Colors.purpleAccent : Colors.blueAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          } else {
            getIt<HapticService>().selectionClick();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.msgComingSoon))
            );
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

  Widget _buildRecipeItem(BuildContext context,
      {required RecipeModel recipe,
        required bool userIsPro,
        required AppLocalizations l10n}) {
    final isLocked = recipe.isPro && !userIsPro;
    final Color color = recipe.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: GlassCard(
        onTap: () {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProScreen()));
          } else {
            getIt<HapticService>().selectionClick();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.msgComingSoon)));
          }
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: recipe.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.3),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: color.withOpacity(0.2),
                    child: Icon(Icons.restaurant_menu, color: color),
                  ),
                )
                    : Container(
                  color: color.withOpacity(0.2),
                  child: Icon(Icons.restaurant_menu, color: color),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text("${recipe.calories} ${l10n.unitKcal}",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.schedule,
                          size: 14, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text("${recipe.timeMinutes} ${l10n.unitMin}",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline, color: Colors.amber)
            else
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
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