import 'package:equatable/equatable.dart';
import 'package:fastable/models/content_models.dart';

enum ArticleStatus { initial, loading, success, failure }

class ArticleState extends Equatable {
  final ArticleStatus status;
  final List<ArticleModel> articles;
  final String? errorMessage;

  const ArticleState({
    this.status = ArticleStatus.initial,
    this.articles = const [],
    this.errorMessage,
  });

  ArticleState copyWith({
    ArticleStatus? status,
    List<ArticleModel>? articles,
    String? errorMessage,
  }) {
    return ArticleState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, errorMessage];
}
