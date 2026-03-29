import 'package:equatable/equatable.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecipes extends RecipeEvent {
  final String locale; // Передаем язык ('en', 'ru')
  const LoadRecipes(this.locale);
}
