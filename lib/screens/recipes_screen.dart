import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fastable/injection.dart';

// БЛОКИ
import 'package:fastable/bloc/recipe/recipe_bloc.dart';
import 'package:fastable/bloc/recipe/recipe_event.dart';
import 'package:fastable/bloc/recipe/recipe_state.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';
import 'package:fastable/bloc/settings/settings_state.dart';

// СЕРВИСЫ И ВИДЖЕТЫ
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/ui/app_layout.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущий язык из настроек
    final locale = context.read<SettingsBloc>().state.locale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    final edgePadding = AppLayout.edgePadding(context);

    return BlocProvider(
      create: (context) => getIt<RecipeBloc>()..add(LoadRecipes(locale)),
      child: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) => previous.locale != current.locale,
        listener: (context, settingsState) {
          context.read<RecipeBloc>().add(
            LoadRecipes(settingsState.locale.languageCode),
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: AnimationLimiter(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ЗАГОЛОВОК
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        edgePadding,
                        16,
                        edgePadding,
                        14,
                      ),
                      child: Text(
                        l10n.featureRecipes,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // КОНТЕНТ
                  BlocBuilder<ProBloc, ProState>(
                    builder: (context, proState) {
                      final userIsPro = proState.isPro;

                      return BlocBuilder<RecipeBloc, RecipeState>(
                        builder: (context, state) {
                          // 1. ЗАГРУЗКА
                          if (state.status == RecipeStatus.loading) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: edgePadding,
                                    vertical: 8,
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.white.withValues(alpha: 0.05),
                                    highlightColor: Colors.white.withValues(alpha: 0.15),
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                ),
                                childCount: 6,
                              ),
                            );
                          }

                          // 2. ПУСТО
                          if (state.recipes.isEmpty) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  l10n.statusNoRecipes,
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              ),
                            );
                          }

                          // 3. СПИСОК
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final recipe = state.recipes[index];
                              final isLocked = !userIsPro && recipe.isPro;

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: edgePadding,
                                        vertical: 8,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isLocked) {
                                            getIt<HapticService>().mediumImpact();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const ProScreen(),
                                              ),
                                            );
                                          } else {
                                            getIt<HapticService>().selectionClick();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.recipeSelected(recipe.title),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: GlassCard(
                                          height: 100,
                                          child: Row(
                                            children: [
                                              // КАРТИНКА / ИКОНКА
                                              Container(
                                                width: 80,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: recipe.color.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.horizontal(
                                                        left: Radius.circular(20),
                                                      ),
                                                  image: recipe.imageUrl.isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            recipe.imageUrl,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                ),
                                                child: recipe.imageUrl.isEmpty
                                                    ? Icon(
                                                        Icons.restaurant,
                                                        color: recipe.color,
                                                      )
                                                    : (isLocked
                                                          ? Container(
                                                              color: Colors.black54,
                                                              child: const Icon(
                                                                Icons.lock,
                                                                color: Colors.white,
                                                              ),
                                                            )
                                                          : null),
                                              ),
                                              const SizedBox(width: 16),

                                              // ТЕКСТ
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      recipe.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "${recipe.calories} ${l10n.unitKcal} • ${recipe.timeMinutes} ${l10n.unitMin}",
                                                      style: const TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    // Метка PREMIUM
                                                    if (isLocked)
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                          top: 6,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                              size: 12,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              l10n.labelPremium,
                                                              style: const TextStyle(
                                                                color: Colors.amber,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),

                                              // СТРЕЛКА
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 16,
                                                ),
                                                child: Icon(
                                                  isLocked
                                                      ? Icons.lock
                                                      : Icons.arrow_forward_ios,
                                                  color: isLocked
                                                      ? Colors.white54
                                                      : Colors.white30,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: state.recipes.length),
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
        ),
      ),
    );
  }
}
