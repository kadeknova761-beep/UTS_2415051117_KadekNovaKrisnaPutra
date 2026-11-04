import '../models/meal.dart';
import '../models/meal_category.dart';

/// Kontrak sumber data resep.
///
/// Provider hanya mengenal kelas abstrak ini, bukan HTTP atau database,
/// sehingga implementasinya bisa diganti tanpa mengubah provider dan UI.
abstract class MealRepository {
  Future<List<MealCategory>> getCategories();

  Future<List<Meal>> getRecommendations();

  Future<List<Meal>> getMealsByCategory(String category);

  Future<List<Meal>> searchMeals(String query);

  Future<Meal> getMealDetail(String id);
}
