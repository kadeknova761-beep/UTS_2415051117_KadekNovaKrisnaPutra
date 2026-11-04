import '../core/dummy_data.dart';
import '../core/exceptions.dart';
import '../models/meal.dart';
import '../models/meal_category.dart';
import 'meal_repository.dart';

/// Implementasi sementara memakai data dummy.
///
/// [delay] meniru lama jaringan, [shouldFail] meniru kegagalan sehingga
/// state loading dan error bisa diuji tanpa API sungguhan.
class FakeMealRepository implements MealRepository {
  final Duration delay;
  final bool shouldFail;

  const FakeMealRepository({
    this.delay = const Duration(milliseconds: 600),
    this.shouldFail = false,
  });

  Future<T> _simulate<T>(T Function() action) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw const AppException('Gagal memuat data (simulasi).');
    }
    return action();
  }

  @override
  Future<List<MealCategory>> getCategories() {
    return _simulate(() => dummyCategories);
  }

  @override
  Future<List<Meal>> getRecommendations() {
    return _simulate(() => dummyMeals);
  }

  @override
  Future<List<Meal>> getMealsByCategory(String category) {
    return _simulate(
      () => dummyMeals.where((meal) => meal.category == category).toList(),
    );
  }

  @override
  Future<List<Meal>> searchMeals(String query) {
    return _simulate(() {
      final keyword = query.trim().toLowerCase();
      if (keyword.isEmpty) return dummyMeals;
      return dummyMeals
          .where((meal) => meal.name.toLowerCase().contains(keyword))
          .toList();
    });
  }

  @override
  Future<Meal> getMealDetail(String id) {
    return _simulate(
      () => dummyMeals.firstWhere(
        (meal) => meal.id == id,
        orElse: () => throw const AppException('Resep tidak ditemukan.'),
      ),
    );
  }
}
