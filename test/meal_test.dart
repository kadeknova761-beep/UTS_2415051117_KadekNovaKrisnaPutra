import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/models/saved_recipe.dart';

void main() {
  group('Meal.fromJson', () {
    test('mengumpulkan bahan yang terisi dan membuang yang kosong', () {
      final meal = Meal.fromJson({
        'idMeal': '1',
        'strMeal': 'Nasi Goreng',
        'strMealThumb': 'https://example.com/a.jpg',
        'strIngredient1': 'Rice',
        'strMeasure1': '2 cups',
        'strIngredient2': 'Egg',
        'strMeasure2': null,
        'strIngredient3': '',
        'strMeasure3': ' ',
        'strIngredient4': null,
        'strTags': 'Spicy, Rice',
      });

      expect(meal.ingredients.length, 2);
      expect(meal.ingredients.first.name, 'Rice');
      expect(meal.ingredients.last.measure, '');
      expect(meal.tags, ['Spicy', 'Rice']);
      expect(meal.hasDetail, false);
    });

    test('melempar FormatException jika id kosong', () {
      expect(
        () => Meal.fromJson({'strMeal': 'Tanpa Id'}),
        throwsFormatException,
      );
    });
  });

  group('SavedRecipe', () {
    test('toInsertJson tidak memuat id, user_id, dan created_at', () {
      const saved = SavedRecipe(
        mealId: '1',
        mealName: 'Nasi Goreng',
        rating: 5,
      );
      final json = saved.toInsertJson();

      expect(json.containsKey('id'), false);
      expect(json.containsKey('user_id'), false);
      expect(json.containsKey('created_at'), false);
      expect(json['rating'], 5);
    });

    test('fromJson membaca kolom tabel saved_recipes', () {
      final saved = SavedRecipe.fromJson({
        'id': 'abc-123',
        'meal_id': '1',
        'meal_name': 'Nasi Goreng',
        'meal_thumb': null,
        'note': null,
        'rating': 4,
        'created_at': '2026-11-04T10:00:00Z',
      });

      expect(saved.id, 'abc-123');
      expect(saved.note, '');
      expect(saved.rating, 4);
      expect(saved.createdAt, isNotNull);
    });
  });
}
