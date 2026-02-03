import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/pro_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

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
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Healthy Recipes", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                ),

                // Если нет PRO, показываем баннер-заглушку
                if (!isPro)
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen())),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, color: Colors.white),
                            SizedBox(width: 16),
                            Expanded(child: Text("Unlock Recipes with PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Список рецептов
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      // Если не PRO, блюрим контент или показываем только 2 рецепта
                      if (!isPro && index > 1) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GlassCard(
                          height: 100,
                          child: Row(
                            children: [
                              Container(
                                width: 80, height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                    image: const DecorationImage(
                                        image: NetworkImage("https://via.placeholder.com/150"), // Заглушка
                                        fit: BoxFit.cover
                                    )
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Keto Salad #$index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    const Text("350 kcal • 15 min", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: isPro ? 20 : 5, // Показываем больше для Pro
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}