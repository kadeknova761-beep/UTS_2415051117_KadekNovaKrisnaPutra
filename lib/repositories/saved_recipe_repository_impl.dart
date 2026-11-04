import '../models/saved_recipe.dart';
import '../services/saved_recipe_service.dart';
import 'saved_recipe_repository.dart';

/// Implementasi memakai Supabase lewat [SavedRecipeService].
class SavedRecipeRepositoryImpl implements SavedRecipeRepository {
  SavedRecipeRepositoryImpl(this._service);

  final SavedRecipeService _service;

  @override
  Future<List<SavedRecipe>> getAll() => _service.fetchAll();

  @override
  Future<SavedRecipe> add(SavedRecipe recipe) => _service.insert(recipe);

  @override
  Future<SavedRecipe> update(SavedRecipe recipe) => _service.update(recipe);

  @override
  Future<void> remove(String id) => _service.delete(id);
}
