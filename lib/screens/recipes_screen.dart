import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastable/injection.dart';

// БЛОКИ
import 'package:fastable/bloc/recipe/recipe_bloc.dart';
import 'package:fastable/bloc/recipe/recipe_event.dart';
import 'package:fastable/bloc/recipe/recipe_state.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart'; // Чтобы узнать язык

// СЕРВИСЫ И ВИДЖЕТЫ
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/pro_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущий язык из настроек
    final locale = context.read<SettingsBloc>().state.locale.languageCode;

    return BlocProvider(
      // Создаем Блок и сразу загружаем рецепты
      create: (context) => getIt<RecipeBloc>()..add(LoadRecipes(locale)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ЗАГОЛОВОК
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Healthy Recipes", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
              ),

              // КОНТЕНТ (Слушаем Pro и Рецепты)
              BlocBuilder<ProBloc, ProState>(
                builder: (context, proState) {
                  final userIsPro = proState.isPro;

                  return BlocBuilder<RecipeBloc, RecipeState>(
                    builder: (context, state) {
                      // 1. ЗАГРУЗКА
                      if (state.status == RecipeStatus.loading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                      }

                      // 2. ПУСТО
                      if (state.recipes.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text("No recipes found", style: TextStyle(color: Colors.white54))),
                        );
                      }

                      // 3. СПИСОК
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final recipe = state.recipes[index];
                            // Рецепт закрыт, если он PRO, а у юзера нет подписки
                            final isLocked = !userIsPro && recipe.isPro;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GestureDetector(
                                onTap: () {
                                  if (isLocked) {
                                    getIt<HapticService>().mediumImpact();
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
                                  } else {
                                    // Здесь будет переход на экран деталей рецепта
                                    getIt<HapticService>().selectionClick();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Selected: ${recipe.title}")),
                                    );
                                  }
                                },
                                child: GlassCard(
                                  height: 100,
                                  child: Row(
                                    children: [
                                      // КАРТИНКА / ИКОНКА
                                      Container(
                                        width: 80, height: 100,
                                        decoration: BoxDecoration(
                                          color: recipe.color.withOpacity(0.2),
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                          image: recipe.imageUrl.isNotEmpty
                                              ? DecorationImage(image: NetworkImage(recipe.imageUrl), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: recipe.imageUrl.isEmpty
                                            ? Icon(Icons.restaurant, color: recipe.color)
                                            : (isLocked ? Container(color: Colors.black54, child: const Icon(Icons.lock, color: Colors.white)) : null),
                                      ),
                                      const SizedBox(width: 16),

                                      // ТЕКСТ
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                recipe.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                "${recipe.calories} kcal • ${recipe.timeMinutes} min",
                                                style: const TextStyle(color: Colors.white54, fontSize: 12)
                                            ),
                                            // Метка PREMIUM
                                            if (isLocked)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.star, color: Colors.amber, size: 12),
                                                    SizedBox(width: 4),
                                                    Text("PREMIUM", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              )
                                          ],
                                        ),
                                      ),

                                      // СТРЕЛКА ИЛИ ЗАМОК
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: Icon(
                                            isLocked ? Icons.lock : Icons.arrow_forward_ios,
                                            color: isLocked ? Colors.white54 : Colors.white30,
                                            size: 16
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: state.recipes.length,
                        ),
                      );
                    },
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}