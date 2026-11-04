import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../models/saved_recipe.dart';
import '../repositories/saved_recipe_repository.dart';

/// State koleksi resep pribadi (data dari database).
class SavedRecipeProvider extends ChangeNotifier {
  SavedRecipeProvider(this._repository);

  final SavedRecipeRepository _repository;

  LoadStatus _status = LoadStatus.initial;
  List<SavedRecipe> _items = const [];
  String? _error;
  bool _disposed = false;

  LoadStatus get status => _status;
  List<SavedRecipe> get items => _items;
  String? get error => _error;

  bool isSaved(String mealId) => _items.any((item) => item.mealId == mealId);

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _notify();

    try {
      final result = await _repository.getAll();
      _items = result;
      _status = result.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } on Exception catch (e) {
      _error = _messageOf(e);
      _status = LoadStatus.error;
    }
    _notify();
  }

  /// Menyimpan resep ke koleksi. Mengembalikan null bila sukses,
  /// atau pesan error yang siap ditampilkan.
  Future<String?> save(Meal meal, {String note = '', int? rating}) async {
    try {
      final saved = await _repository.add(
        SavedRecipe(
          mealId: meal.id,
          mealName: meal.name,
          thumbnailUrl: meal.thumbnailUrl.isEmpty ? null : meal.thumbnailUrl,
          note: note,
          rating: rating,
        ),
      );
      _items = [saved, ..._items];
      _status = LoadStatus.success;
      _notify();
      return null;
    } on Exception catch (e) {
      return _messageOf(e);
    }
  }

  /// Mengubah catatan dan rating. Mengembalikan null bila sukses,
  /// atau pesan error yang siap ditampilkan.
  Future<String?> update(
    SavedRecipe recipe, {
    required String note,
    int? rating,
  }) async {
    try {
      final updated = await _repository.update(
        recipe.copyWith(note: note, rating: rating),
      );
      _items = [
        for (final item in _items) item.id == updated.id ? updated : item,
      ];
      _notify();
      return null;
    } on Exception catch (e) {
      return _messageOf(e);
    }
  }

  /// Menghapus resep dari koleksi. Mengembalikan null bila sukses,
  /// atau pesan error yang siap ditampilkan.
  Future<String?> remove(SavedRecipe recipe) async {
    final id = recipe.id;
    if (id == null) return 'Resep belum tersimpan di database.';
    try {
      await _repository.remove(id);
      _items = _items.where((item) => item.id != id).toList();
      _status = _items.isEmpty ? LoadStatus.empty : LoadStatus.success;
      _notify();
      return null;
    } on Exception catch (e) {
      return _messageOf(e);
    }
  }

  String _messageOf(Exception e) =>
      e is AppException ? e.message : 'Terjadi kesalahan. Silakan coba lagi.';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
