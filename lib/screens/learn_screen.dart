import 'dart:io'; // Для Platform
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/screens/recipes_screen.dart'; // Экран рецептов
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/injection.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProBloc, ProState>(
          builder: (context, state) {
            final isPro = state.isPro;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ЗАГОЛОВОК
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Text(
                      "Learn",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // --- БЛОК РЕЦЕПТОВ (Только для iOS) ---
                if (Platform.isIOS)
                  SliverToBoxAdapter(
                    child: _buildRecipesBanner(context, isPro),
                  ),

                // КАТЕГОРИИ
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

                // ЗАГОЛОВОК СПИСКА
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text("Latest Articles", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // СПИСОК СТАТЕЙ
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildArticleItem(
                      context,
                      title: "What is Intermittent Fasting?",
                      desc: "The complete beginner's guide to IF.",
                      readTime: "5 min",
                      imageColor: Colors.blueAccent,
                      isLocked: false,
                      isPro: isPro,
                    ),
                    _buildArticleItem(
                      context,
                      title: "Autophagy: The Science",
                      desc: "How your body repairs itself.",
                      readTime: "8 min",
                      imageColor: Colors.purpleAccent,
                      isLocked: true, // Pro Article
                      isPro: isPro,
                    ),
                    _buildArticleItem(
                      context,
                      title: "What to drink while fasting?",
                      desc: "Coffee, tea, and water hacks.",
                      readTime: "3 min",
                      imageColor: Colors.brown,
                      isLocked: false,
                      isPro: isPro,
                    ),
                    _buildArticleItem(
                      context,
                      title: "Fasting & Muscle Growth",
                      desc: "Can you build muscle on IF?",
                      readTime: "10 min",
                      imageColor: Colors.redAccent,
                      isLocked: true, // Pro Article
                      isPro: isPro,
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- НОВЫЙ БАННЕР ДЛЯ РЕЦЕПТОВ ---
  Widget _buildRecipesBanner(BuildContext context, bool isPro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GestureDetector(
        onTap: () {
          getIt<HapticService>().mediumImpact();
          if (isPro) {
            // Если PRO - открываем рецепты
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen()));
          } else {
            // Если Free - открываем Paywall
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          }
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43C6AC), Color(0xFF191654)], // Красивый градиент
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
              // Фоновая иконка
              Positioned(
                right: -20,
                bottom: -20,
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
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          SizedBox(width: 4),
                          Text("PREMIUM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Healthy Recipes",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Keto, Low-Carb & More",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Замок, если не PRO
              if (!isPro)
                Positioned(
                  right: 24,
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return GlassCard(
      width: 100,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, {
    required String title,
    required String desc,
    required String readTime,
    required Color imageColor,
    required bool isLocked,
    required bool isPro,
  }) {
    final bool showLock = isLocked && !isPro;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          if (showLock) {
            getIt<HapticService>().mediumImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
          } else {
            getIt<HapticService>().selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening article...")));
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
                child: Icon(showLock ? Icons.lock : Icons.article, color: imageColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(readTime, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        if (isLocked && isPro) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: const Text("PRO", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              if (showLock)
                const Icon(Icons.lock_outline, color: Colors.amber)
              else
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}