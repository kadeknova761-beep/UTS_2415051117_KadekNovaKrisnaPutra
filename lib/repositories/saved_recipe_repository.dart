import '../models/saved_recipe.dart';

/// Kontrak sumber data koleksi pribadi.
abstract class SavedRecipeRepository {
  Future<List<SavedRecipe>> getAll();

  Future<SavedRecipe> add(SavedRecipe recipe);

  /// Memperbarui catatan dan rating resep yang sudah tersimpan.
  Future<SavedRecipe> update(SavedRecipe recipe);

  Future<void> remove(String id);
}
