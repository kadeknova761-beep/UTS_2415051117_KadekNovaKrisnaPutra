import '../core/exceptions.dart';
import '../models/meal.dart';
import '../models/meal_category.dart';
import '../services/meal_api_service.dart';
import 'meal_repository.dart';

/// Implementasi [MealRepository] yang mengambil data dari TheMealDB.
///
/// Tugasnya menerjemahkan kebutuhan provider menjadi pemanggilan service,
/// mengubah JSON ke model, dan menangani keterbatasan API gratis.
class MealRepositoryImpl implements MealRepository {
  MealRepositoryImpl(this._service);

  final MealApiService _service;

  /// API gratis hanya punya random.php (1 resep), jadi dipanggil beberapa kali.
  static const int _recommendationCount = 6;

  /// Katalog awal (tanpa filter) diambil dari beberapa huruf awal nama resep.
  static const List<String> _catalogLetters = ['b', 'c', 's'];

  @override
  Future<List<MealCategory>> getCategories() async {
    final json = await _service.fetchCategories();
    return _parse(() => json.map(MealCategory.fromJson).toList());
  }

  @override
  Future<List<Meal>> getRecommendations() async {
    final results = await Future.wait(
      List.generate(_recommendationCount, (_) => _service.fetchRandomMeal()),
    );
    return _parse(
      () =>
          _unique(results.whereType<Map<String, dynamic>>().map(Meal.fromJson)),
    );
  }

  @override
  Future<List<Meal>> getMealsByCategory(String category) async {
    final json = await _service.fetchMealsByCategory(category);
    return _parse(
      () => json
          .map(Meal.fromJson)
          // filter.php tidak membawa kategori, jadi diisi dari filter aktif.
          .map(
            (meal) => Meal(
              id: meal.id,
              name: meal.name,
              thumbnailUrl: meal.thumbnailUrl,
              category: category,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<Meal>> searchMeals(String query) async {
    final keyword = query.trim();

    if (keyword.isEmpty) {
      final batches = await Future.wait(
        _catalogLetters.map(_service.searchMealsByLetter),
      );
      final meals = _parse(
        () => _unique(batches.expand((batch) => batch).map(Meal.fromJson)),
      );
      meals.sort((a, b) => a.name.compareTo(b.name));
      return meals;
    }

    final json = await _service.searchMealsByName(keyword);
    return _parse(() => json.map(Meal.fromJson).toList());
  }

  @override
  Future<Meal> getMealDetail(String id) async {
    final json = await _service.lookupMeal(id);
    if (json == null) {
      throw const AppException('Resep tidak ditemukan.');
    }
    return _parse(() => Meal.fromJson(json));
  }

  /// Membuang duplikat berdasarkan id (random.php bisa mengulang resep).
  List<Meal> _unique(Iterable<Meal> meals) {
    final byId = <String, Meal>{};
    for (final meal in meals) {
      byId.putIfAbsent(meal.id, () => meal);
    }
    return byId.values.toList();
  }

  /// Data yang tidak sesuai bentuk model dipetakan ke [AppException].
  T _parse<T>(T Function() action) {
    try {
      return action();
    } on FormatException {
      throw const AppException('Data dari server tidak valid.');
    } on TypeError {
      throw const AppException('Data dari server tidak valid.');
    }
  }
}
