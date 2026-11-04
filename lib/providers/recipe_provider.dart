import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../models/meal_category.dart';
import '../repositories/meal_repository.dart';

/// State resep: kategori, rekomendasi (Home), dan katalog (List/Cari).
///
/// Filter (kategori dan kata kunci) adalah shared state: Home dan List
/// membaca dan mengubah nilai yang sama.
class RecipeProvider extends ChangeNotifier {
  RecipeProvider(
    this._repository, {
    this.searchDebounce = const Duration(milliseconds: 450),
  });

  final MealRepository _repository;

  /// Jeda setelah pengguna berhenti mengetik sebelum pencarian dikirim.
  final Duration searchDebounce;

  // Kategori
  LoadStatus _categoriesStatus = LoadStatus.initial;
  List<MealCategory> _categories = const [];
  String? _categoriesError;

  // Rekomendasi di Home
  LoadStatus _recommendationsStatus = LoadStatus.initial;
  List<Meal> _recommendations = const [];
  String? _recommendationsError;

  // Katalog di List/Cari, mengikuti filter
  LoadStatus _mealsStatus = LoadStatus.initial;
  List<Meal> _meals = const [];
  String? _mealsError;
  String? _selectedCategory;
  String _query = '';

  // Penanda permintaan terbaru agar hasil lama tidak menimpa hasil baru.
  int _mealsRequestId = 0;
  Timer? _searchTimer;
  bool _disposed = false;

  LoadStatus get categoriesStatus => _categoriesStatus;
  List<MealCategory> get categories => _categories;
  String? get categoriesError => _categoriesError;

  LoadStatus get recommendationsStatus => _recommendationsStatus;
  List<Meal> get recommendations => _recommendations;
  String? get recommendationsError => _recommendationsError;

  LoadStatus get mealsStatus => _mealsStatus;
  List<Meal> get meals => _meals;
  String? get mealsError => _mealsError;
  String? get selectedCategory => _selectedCategory;
  String get query => _query;

  /// Memuat semua data awal secara bersamaan.
  Future<void> init() async {
    await Future.wait([loadCategories(), loadRecommendations(), loadMeals()]);
  }

  Future<void> loadCategories() async {
    _categoriesStatus = LoadStatus.loading;
    _categoriesError = null;
    _notify();

    try {
      final result = await _repository.getCategories();
      _categories = result;
      _categoriesStatus = result.isEmpty
          ? LoadStatus.empty
          : LoadStatus.success;
    } on Exception catch (error) {
      _categoriesError = _messageOf(error);
      _categoriesStatus = LoadStatus.error;
    }
    _notify();
  }

  Future<void> loadRecommendations() async {
    _recommendationsStatus = LoadStatus.loading;
    _recommendationsError = null;
    _notify();

    try {
      final result = await _repository.getRecommendations();
      _recommendations = result;
      _recommendationsStatus = result.isEmpty
          ? LoadStatus.empty
          : LoadStatus.success;
    } on Exception catch (error) {
      _recommendationsError = _messageOf(error);
      _recommendationsStatus = LoadStatus.error;
    }
    _notify();
  }

  /// Memuat katalog sesuai filter yang sedang aktif.
  Future<void> loadMeals() async {
    final requestId = ++_mealsRequestId;
    _mealsStatus = LoadStatus.loading;
    _mealsError = null;
    _notify();

    try {
      final category = _selectedCategory;
      final result = category != null
          ? await _repository.getMealsByCategory(category)
          : await _repository.searchMeals(_query);

      // Ada permintaan yang lebih baru, abaikan hasil ini.
      if (requestId != _mealsRequestId) return;

      _meals = result;
      _mealsStatus = result.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } on Exception catch (error) {
      if (requestId != _mealsRequestId) return;

      _mealsError = _messageOf(error);
      _mealsStatus = LoadStatus.error;
    }
    _notify();
  }

  /// Memilih kategori (atau null untuk melepas). Mengosongkan kata kunci.
  Future<void> selectCategory(String? name) {
    _searchTimer?.cancel();
    _selectedCategory = name;
    _query = '';
    return loadMeals();
  }

  /// Mencari berdasarkan nama, langsung tanpa jeda. Melepas kategori.
  Future<void> search(String query) {
    _searchTimer?.cancel();
    _query = query;
    _selectedCategory = null;
    return loadMeals();
  }

  /// Dipanggil setiap pengguna mengetik di kolom cari.
  ///
  /// Kata kunci dan filter diperbarui seketika agar UI tetap sinkron,
  /// tetapi permintaan ke API baru dikirim setelah [searchDebounce] tanpa
  /// ketikan baru. Ini mencegah satu permintaan per huruf.
  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _query = query;
    _selectedCategory = null;
    _notify();
    _searchTimer = Timer(searchDebounce, () {
      loadMeals();
    });
  }

  /// Menghapus semua filter dan memuat ulang katalog penuh.
  Future<void> clearFilters() async {
    _searchTimer?.cancel();
    final hasFilter = _selectedCategory != null || _query.isNotEmpty;
    if (!hasFilter && _mealsStatus == LoadStatus.success) return;

    _selectedCategory = null;
    _query = '';
    await loadMeals();
  }

  String _messageOf(Exception error) {
    if (error is AppException) return error.message;
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }
}
