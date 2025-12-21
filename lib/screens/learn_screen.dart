import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/models/content_models.dart';
import 'package:fastable/services/content_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  String? _selectedTag; // Фильтр

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Определяем текущий код языка (например, 'ru' или 'en')
    final String localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Guide",
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildTabBtn(l10n.tabRecipes, 0),
                      _buildTabBtn(l10n.tabKnowledge, 1),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. РЕЦЕПТЫ (STREAM)
                _buildRecipesTab(l10n, localeCode),

                // 2. СТАТЬИ (STREAM)
                _buildKnowledgeTab(localeCode),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String title, int index) {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, child) {
        final double value = _tabController.animation!.value;
        final bool isSelected = (value - index).abs() < 0.5;

        return GestureDetector(
          onTap: () => _tabController.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipesTab(AppLocalizations l10n, String locale) {
    return StreamBuilder<List<RecipeModel>>(
      stream: _contentService.getRecipes(locale),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No recipes found", style: TextStyle(color: Colors.white.withOpacity(0.5))));
        }

        final allRecipes = snapshot.data!;
        // Фильтрация на клиенте
        final filteredRecipes = _selectedTag == null
            ? allRecipes
            : allRecipes.where((r) => r.tags.contains(_selectedTag)).toList();

        return Column(
          children: [
            // Фильтры
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip(l10n.categoryAll, null),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.categoryKeto, "keto"),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.categoryFitness, "fitness"),
                  const SizedBox(width: 8),
                  _buildFilterChip(l10n.categoryVegan, "vegan"),
                ],
              ),
            ),

            // Список
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildRecipeCard(filteredRecipes[index], l10n);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? tag) {
    final bool isSelected = _selectedTag == tag;
    return GestureDetector(
      onTap: () => setState(() => _selectedTag = tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe, AppLocalizations l10n) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: recipe.color.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: recipe.imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(recipe.imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: Stack(
              children: [
                if (recipe.imageUrl.isEmpty)
                  Center(child: Icon(Icons.restaurant_menu, size: 60, color: recipe.color)),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(l10n.recipeTime(recipe.timeMinutes), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    if (recipe.tags.contains("keto"))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: const Text("KETO", style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(recipe.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMacro("Cal", "${recipe.calories}", Colors.grey),
                    const SizedBox(width: 12),
                    _buildMacro("Prot", "${recipe.protein}g", Colors.blue),
                    const SizedBox(width: 12),
                    _buildMacro("Fat", "${recipe.fat}g", Colors.orange),
                    const SizedBox(width: 12),
                    _buildMacro("Carb", "${recipe.carbs}g", Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacro(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      ],
    );
  }

  Widget _buildKnowledgeTab(String locale) {
    return StreamBuilder<List<ArticleModel>>(
      stream: _contentService.getArticles(locale),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final article = snapshot.data![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.article, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(article.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}