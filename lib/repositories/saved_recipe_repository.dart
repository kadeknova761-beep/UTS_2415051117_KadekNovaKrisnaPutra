import '../models/saved_recipe.dart';

/// Kontrak sumber data koleksi pribadi.
abstract class SavedRecipeRepository {
  Future<List<SavedRecipe>> getAll();

  Future<SavedRecipe> add(SavedRecipe recipe);
}
