import 'package:equatable/equatable.dart';
import 'package:fastable/models/content_models.dart'; // Твоя модель

enum RecipeStatus { initial, loading, success, failure }

class RecipeState extends Equatable {
  final RecipeStatus status;
  final List<RecipeModel> recipes;
  final String? errorMessage;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.recipes = const [],
    this.errorMessage,
  });

  RecipeState copyWith({
    RecipeStatus? status,
    List<RecipeModel>? recipes,
    String? errorMessage,
  }) {
    return RecipeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recipes, errorMessage];
}