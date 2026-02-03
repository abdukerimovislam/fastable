import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/bloc/recipe/recipe_event.dart';
import 'package:fastable/bloc/recipe/recipe_state.dart';
import 'package:fastable/repositories/recipe_repository.dart';

@injectable
class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _recipeRepository;

  RecipeBloc(this._recipeRepository) : super(const RecipeState()) {
    on<LoadRecipes>(_onLoadRecipes);
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<RecipeState> emit) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final recipes = await _recipeRepository.getRecipes(event.locale);
      emit(state.copyWith(
        status: RecipeStatus.success,
        recipes: recipes,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: RecipeStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }
}