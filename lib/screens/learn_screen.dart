import 'package:flutter/material.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/models/article.dart';
import 'package:fastable/repositories/article_repository.dart';
import 'package:fastable/services/pro_service.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fastable/widgets/glass_card.dart'; // Наш виджет

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with TickerProviderStateMixin {
  final ArticleRepository _articleRepository = ArticleRepository();
  late Future<List<Article>> _articlesFuture;
  late TabController _tabController;

  final List<String> _categories = ['fasting', 'keto', 'partner'];
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _articlesFuture = _fetchArticles(shouldCheckPro: true);
  }

  Future<List<Article>> _fetchArticles({bool shouldCheckPro = false}) async {
    if (shouldCheckPro) await _checkProStatus();
    final languageCode = Localizations.localeOf(context).languageCode;
    return _articleRepository.fetchArticles(languageCode);
  }

  Future<void> _checkProStatus() async {
    final isActive = await ProService().isPro();
    if (mounted) setState(() => _isPro = isActive);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- ДИАЛОГ СТАТЬИ (Dark Sheet) ---
  void _showArticleDialog(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Для закругленных углов
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212), // Темный фон для чтения
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Ручка
                  Container(
                    width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: EdgeInsets.zero,
                      children: [
                        if (article.imageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                              child: Image.network(
                                article.imageUrl,
                                fit: BoxFit.cover,
                                height: 250,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(height: 250, color: Colors.grey.shade900, child: const Center(child: CircularProgressIndicator()));
                                },
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(article.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Text(
                                article.contentFull ?? article.summary,
                                style: TextStyle(fontSize: 17, height: 1.6, color: Colors.white.withOpacity(0.9)),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArticleList(List<Article> allArticles, String categoryKey) {
    final l10n = AppLocalizations.of(context)!;
    final filteredArticles = allArticles.where((article) => article.category == categoryKey).toList();

    if (categoryKey == 'partner' && !_isPro) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GlassCard( // Карточка PRO
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(l10n.premiumContentTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(l10n.premiumContentDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProScreen())),
                  icon: const Icon(Icons.lock_open, color: Colors.black),
                  label: Text(l10n.getPro, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (filteredArticles.isEmpty) {
      return Center(child: Text(l10n.noArticlesFound, style: TextStyle(color: Colors.white.withOpacity(0.5))));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        final isProLocked = article.isPremium && !_isPro;

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  onTap: isProLocked
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProScreen())).then((_) => _fetchArticles())
                      : () => _showArticleDialog(context, article),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: (isProLocked ? Colors.amber : Colors.blueAccent).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(article.icon, size: 28, color: isProLocked ? Colors.amber : Colors.blueAccent),
                    ),
                    title: Text(article.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isProLocked ? Colors.white.withOpacity(0.5) : Colors.white)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    trailing: Icon(isProLocked ? Icons.lock : Icons.chevron_right, color: isProLocked ? Colors.amber : Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTabTitle(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'fasting': return l10n.tabFasting;
      case 'keto': return l10n.tabKeto;
      case 'partner': return l10n.tabPartner;
      default: return categoryKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = _categories.map((key) => Tab(text: _getTabTitle(key, l10n))).toList();

    return Scaffold(
      backgroundColor: Colors.transparent, // ВАЖНО
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.navLearn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          indicatorColor: Colors.white, // Подчеркивание белым
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('${l10n.errorLoading} ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(l10n.noArticlesFound, style: const TextStyle(color: Colors.white)));

          return TabBarView(
            controller: _tabController,
            children: _categories.map((categoryKey) => _buildArticleList(snapshot.data!, categoryKey)).toList(),
          );
        },
      ),
    );
  }
}