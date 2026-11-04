import '../core/exceptions.dart';
import '../models/saved_recipe.dart';
import 'saved_recipe_repository.dart';

/// Implementasi in-memory untuk tes. Tidak butuh Supabase.
class FakeSavedRecipeRepository implements SavedRecipeRepository {
  FakeSavedRecipeRepository({this.shouldFail = false});

  final bool shouldFail;
  final List<SavedRecipe> _items = [];
  int _nextId = 1;

  @override
  Future<List<SavedRecipe>> getAll() async {
    if (shouldFail) {
      throw const AppException('Gagal memuat koleksi (simulasi).');
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<SavedRecipe> add(SavedRecipe recipe) async {
    if (shouldFail) {
      throw const AppException('Gagal menyimpan resep (simulasi).');
    }
    if (_items.any((item) => item.mealId == recipe.mealId)) {
      throw const AppException('Resep sudah ada di koleksi.');
    }
    final saved = SavedRecipe(
      id: 'fake-${_nextId++}',
      mealId: recipe.mealId,
      mealName: recipe.mealName,
      thumbnailUrl: recipe.thumbnailUrl,
      note: recipe.note,
      rating: recipe.rating,
      createdAt: DateTime.now(),
    );
    _items.insert(0, saved);
    return saved;
  }

  @override
  Future<SavedRecipe> update(SavedRecipe recipe) async {
    if (shouldFail) {
      throw const AppException('Gagal memperbarui resep (simulasi).');
    }
    final index = _items.indexWhere((item) => item.id == recipe.id);
    if (index == -1) {
      throw const AppException('Gagal memperbarui resep.');
    }
    _items[index] = recipe;
    return recipe;
  }

  @override
  Future<void> remove(String id) async {
    if (shouldFail) {
      throw const AppException('Gagal menghapus resep (simulasi).');
    }
    _items.removeWhere((item) => item.id == id);
  }
}
