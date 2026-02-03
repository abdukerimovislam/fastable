import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/recipes_screen.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

// НОВЫЕ ИМПОРТЫ
import 'package:fastable/bloc/article/article_bloc.dart';
import 'package:fastable/bloc/article/article_event.dart';
import 'package:fastable/bloc/article/article_state.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // Для открытия статей в браузере

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<SettingsBloc>().state.locale.languageCode;

    // Внедряем ArticleBloc
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
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Text(
                        "Learn",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  if (Platform.isIOS)
                    SliverToBoxAdapter(
                      child: _buildRecipesBanner(context, isPro),
                    ),

                  // КАТЕГОРИИ (Пока можно оставить статичными или тоже вынести в базу)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildCategoryCard("Basics", Icons.book, Colors.blueAccent),
                          const SizedBox(width: 12),
                          _buildCategoryCard("Nutrition", Icons.restaurant, Colors.greenAccent),
                          const SizedBox(width: 12),
                          _buildCategoryCard("Health", Icons.favorite, Colors.redAccent),
                          const SizedBox(width: 12),
                          _buildCategoryCard("Keto", Icons.bolt, Colors.orangeAccent),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text("Latest Articles", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ДИНАМИЧЕСКИЙ СПИСОК СТАТЕЙ
                  BlocBuilder<ArticleBloc, ArticleState>(
                    builder: (context, state) {
                      if (state.status == ArticleStatus.loading) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          )),
                        );
                      }

                      if (state.articles.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No articles yet.", style: TextStyle(color: Colors.white54)),
                          )),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final article = state.articles[index];
                            return _buildArticleItem(
                              context,
                              article: article,
                              isPro: isPro,
                            );
                          },
                          childCount: state.articles.length,
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Обновленный метод построения элемента статьи
  Widget _buildArticleItem(BuildContext context, {
    required dynamic article, // Используем dynamic или ArticleModel
    required bool isPro,
  }) {
    // Определяем доступность
    final bool isLocked = article.isPro && !isPro;

    // Цвета можно рандомизировать или хранить в базе, пока возьмем синий
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
            // Открываем URL статьи или внутренний экран
            if (article.contentUrl.isNotEmpty) {
              final uri = Uri.parse(article.contentUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon...")));
            }
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imageColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    if (isLocked) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text("PRO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_outline, color: Colors.amber)
              else
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  // ... Остальные методы (_buildRecipesBanner, _buildCategoryCard) оставь без изменений ...
  // (Я их не привожу, чтобы не загромождать ответ, так как они такие же)
  Widget _buildRecipesBanner(BuildContext context, bool isPro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GestureDetector(
        onTap: () {
          getIt<HapticService>().mediumImpact();
          if (isPro) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          }
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43C6AC), Color(0xFF191654)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF43C6AC).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: Icon(Icons.restaurant_menu, size: 140, color: Colors.white.withOpacity(0.1)),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, color: Colors.amber, size: 12), SizedBox(width: 4), Text("PREMIUM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
                    ),
                    const SizedBox(height: 8),
                    const Text("Healthy Recipes", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Keto, Low-Carb & More", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              if (!isPro)
                Positioned(right: 24, top: 24, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Icon(Icons.lock, color: Colors.white, size: 20))),
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
}