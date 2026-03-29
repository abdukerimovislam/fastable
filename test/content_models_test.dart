import 'package:flutter_test/flutter_test.dart';

import 'package:fastable/models/content_models.dart';

void main() {
  test(
    'ArticleModel supports legacy flat translation fields and summary alias',
    () {
      final article = ArticleModel.fromMap('doc-1', <String, dynamic>{
        'title_en': 'Legacy title',
        'summary_en': 'Legacy summary',
        'imageUrl': 'https://example.com/image.png',
        'is_premium': true,
      }, 'es');

      expect(article.id, 'doc-1');
      expect(article.title, 'Legacy title');
      expect(article.subtitle, 'Legacy summary');
      expect(article.imageUrl, 'https://example.com/image.png');
      expect(article.isPro, isTrue);
    },
  );

  test('RecipeModel supports nested translations and legacy premium key', () {
    final recipe = RecipeModel.fromMap('doc-2', <String, dynamic>{
      'title': {'en': 'Protein Bowl', 'ru': 'Белковая тарелка'},
      'description': {'en': 'Fast recipe'},
      'imageUrl': '',
      'calories': 420,
      'protein': 30,
      'fat': 14,
      'carbs': 28,
      'time': 12,
      'tags': ['high-protein'],
      'color': 'green',
      'is_premium': false,
    }, 'ru');

    expect(recipe.title, 'Белковая тарелка');
    expect(recipe.description, 'Fast recipe');
    expect(recipe.calories, 420);
    expect(recipe.timeMinutes, 12);
    expect(recipe.isPro, isFalse);
  });

  test(
    'resolveLocalizedContentField falls back across nested and flat keys',
    () {
      final value = resolveLocalizedContentField(
        <String, dynamic>{
          'subtitle': {'pt': 'Resumo'},
          'summary_en': 'Summary',
        },
        ['subtitle', 'summary'],
        'es',
      );

      expect(value, 'Summary');
    },
  );
}
