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
import 'package:fastable/bloc/settings/settings_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// Модели и Локализация
import 'package:fastable/models/content_models.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';

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
    final edgePadding = AppLayout.edgePadding(context);
    final sectionGap = AppLayout.sectionGap(context);

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
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.locale != current.locale,
            listener: (context, settingsState) {
              final languageCode = settingsState.locale.languageCode;
              context.read<ArticleBloc>().add(LoadArticles(languageCode));
              if (!isAndroid) {
                context.read<RecipeBloc>().add(LoadRecipes(languageCode));
              }
            },
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
                    // ЗАГОЛОВОК (SliverAppBar)
                    SliverAppBar(
                      expandedHeight: 120.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsets.only(
                          left: edgePadding,
                          bottom: 16,
                        ),
                        title: Text(
                          l10n.learnTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    // ПЕРЕКЛЮЧАТЕЛЬ (ТОЛЬКО НА iOS)
                    if (!isAndroid)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: edgePadding,
                            vertical: 8,
                          ),
                          child: _buildSegmentedControl(l10n),
                        ),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: sectionGap + 4)),

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
      ),
    );
  }

  // --- WIDGETS: ПЕРЕКЛЮЧАТЕЛЬ ---

  Widget _buildSegmentedControl(AppLocalizations l10n) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: _selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
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
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
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

  List<Widget> _buildArticlesTab(
    BuildContext context,
    bool isPro,
    AppLocalizations l10n,
  ) {
    final edgePadding = AppLayout.edgePadding(context);
    return [
      SliverToBoxAdapter(
        child: _buildSectionHeader(
          context,
          eyebrow: l10n.tabArticles,
          title: l10n.learnQuickBites,
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 128,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: edgePadding - 4),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStoryCircle(
                context,
                l10n.storyFasting101,
                Colors.orangeAccent,
                Icons.local_fire_department,
                true,
              ),
              _buildStoryCircle(
                context,
                l10n.storyAutophagy,
                Colors.purpleAccent,
                Icons.autorenew_rounded,
                false,
              ),
              _buildStoryCircle(
                context,
                l10n.storyKetoDiet,
                Colors.greenAccent,
                Icons.eco_rounded,
                false,
              ),
              _buildStoryCircle(
                context,
                l10n.storyHydration,
                Colors.blueAccent,
                Icons.water_drop_rounded,
                false,
              ),
              _buildStoryCircle(
                context,
                l10n.storySleep,
                Colors.indigoAccent,
                Icons.bedtime_rounded,
                false,
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 18)),
      SliverToBoxAdapter(
        child: _buildSectionHeader(
          context,
          eyebrow: l10n.tabArticles,
          title: l10n.headerLatestArticles,
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state.status == ArticleStatus.loading) {
            return const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          if (state.articles.isEmpty || state.status == ArticleStatus.failure) {
            return SliverToBoxAdapter(
              child: _buildComingSoonWidget(
                context,
                l10n,
                Icons.menu_book_rounded,
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final article = state.articles[index];
              return _buildArticleItem(
                context,
                article: article,
                isPro: isPro,
                l10n: l10n,
              );
            }, childCount: state.articles.length),
          );
        },
      ),
    ];
  }

  // --- TAB: RECIPES (Только iOS) ---

  List<Widget> _buildRecipesTab(
    BuildContext context,
    bool isPro,
    AppLocalizations l10n,
  ) {
    return [
      if (!isPro) SliverToBoxAdapter(child: _buildProBanner(context, l10n)),

      SliverToBoxAdapter(
        child: _buildSectionHeader(
          context,
          eyebrow: l10n.tabRecipes,
          title: l10n.headerHealthyChoices,
        ),
      ),

      BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state.status == RecipeStatus.loading) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            );
          }

          if (state.recipes.isEmpty || state.status == RecipeStatus.failure) {
            return SliverToBoxAdapter(
              child: _buildComingSoonWidget(
                context,
                l10n,
                Icons.restaurant_menu,
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final recipe = state.recipes[index];
              return _buildRecipeItem(
                context,
                recipe: recipe,
                userIsPro: isPro,
                l10n: l10n,
              );
            }, childCount: state.recipes.length),
          );
        },
      ),
    ];
  }

  // --- COMMON WIDGETS ---

  Widget _buildStoryCircle(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
    bool hasUnseenContent,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        getIt<HapticService>().lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.storyOpening(title)),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        width: 88,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnseenContent
                    ? const LinearGradient(
                        colors: [Colors.pinkAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: hasUnseenContent
                    ? null
                    : Border.all(color: Colors.white24, width: 2),
              ),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF121722),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String eyebrow,
    required String title,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayout.edgePadding(context),
        8,
        AppLayout.edgePadding(context),
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonWidget(
    BuildContext context,
    AppLocalizations l10n,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayout.edgePadding(context),
        20,
        AppLayout.edgePadding(context),
        24,
      ),
      child: GlassCard(
        padding: EdgeInsets.all(AppLayout.cardPadding(context) + 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 46,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.comingSoonTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.comingSoonDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(
    BuildContext context, {
    required ArticleModel article,
    required bool isPro,
    required AppLocalizations l10n,
  }) {
    final isAndroid = Platform.isAndroid;
    final bool isLocked = !isAndroid && (article.isPro && !isPro);

    final Color imageColor = isLocked ? Colors.purpleAccent : Colors.blueAccent;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: AppLayout.edgePadding(context),
        right: AppLayout.edgePadding(context),
      ),
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProScreen()),
            );
          } else {
            getIt<HapticService>().selectionClick();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.msgComingSoon)));
          }
        },
        child: GlassCard(
          padding: EdgeInsets.all(AppLayout.cardPadding(context)),
          border: isLocked
              ? Border.all(color: Colors.amber.withValues(alpha: 0.28))
              : null,
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: imageColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isLocked ? Icons.lock : Icons.article,
                  color: imageColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isLocked)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeItem(
    BuildContext context, {
    required RecipeModel recipe,
    required bool userIsPro,
    required AppLocalizations l10n,
  }) {
    final isLocked = recipe.isPro && !userIsPro;
    final Color color = recipe.color;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 14,
        left: AppLayout.edgePadding(context),
        right: AppLayout.edgePadding(context),
      ),
      child: GlassCard(
        onTap: () {
          if (isLocked) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProScreen()),
            );
          } else {
            getIt<HapticService>().selectionClick();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.msgComingSoon)));
          }
        },
        padding: EdgeInsets.all(AppLayout.cardPadding(context)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: recipe.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.white.withValues(alpha: 0.1),
                          highlightColor: Colors.white.withValues(alpha: 0.3),
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: color.withValues(alpha: 0.2),
                          child: Icon(Icons.restaurant_menu, color: color),
                        ),
                      )
                    : Container(
                        color: color.withValues(alpha: 0.2),
                        child: Icon(Icons.restaurant_menu, color: color),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildMetaChip(
                        icon: Icons.local_fire_department_rounded,
                        label: "${recipe.calories} ${l10n.unitKcal}",
                      ),
                      _buildMetaChip(
                        icon: Icons.schedule_rounded,
                        label: "${recipe.timeMinutes} ${l10n.unitMin}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.amber,
                  size: 16,
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.42),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.58)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBanner(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayout.edgePadding(context),
        0,
        AppLayout.edgePadding(context),
        20,
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProScreen()),
        ),
        child: Container(
          padding: EdgeInsets.all(AppLayout.cardPadding(context)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF6B73C), Color(0xFFEF626C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF626C).withValues(alpha: 0.22),
                blurRadius: 22,
                spreadRadius: -10,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.proTitle.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.learnBannerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      l10n.learnBannerSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
