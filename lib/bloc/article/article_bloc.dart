import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/bloc/article/article_event.dart';
import 'package:fastable/bloc/article/article_state.dart';
import 'package:fastable/repositories/article_repository.dart';

@injectable
class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository _articleRepository;

  ArticleBloc(this._articleRepository) : super(const ArticleState()) {
    on<LoadArticles>(_onLoadArticles);
  }

  Future<void> _onLoadArticles(LoadArticles event, Emitter<ArticleState> emit) async {
    emit(state.copyWith(status: ArticleStatus.loading));
    try {
      // Предполагаем, что в репозитории есть метод getArticles(String locale)
      // Если его нет, мы обновим репозиторий следующим шагом
      final articles = await _articleRepository.getArticles(event.locale);
      emit(state.copyWith(
        status: ArticleStatus.success,
        articles: articles,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticleStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}