import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();
  @override
  List<Object?> get props => [];
}

class LoadArticles extends ArticleEvent {
  final String locale; // Для загрузки перевода
  const LoadArticles(this.locale);
}
