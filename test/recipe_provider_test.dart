import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/dummy_data.dart';
import 'package:resepku/core/load_status.dart';
import 'package:resepku/providers/recipe_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';

void main() {
  const okRepository = FakeMealRepository(delay: Duration.zero);
  const failRepository = FakeMealRepository(
    delay: Duration.zero,
    shouldFail: true,
  );

  group('RecipeProvider', () {
    test('status awal adalah initial', () {
      final provider = RecipeProvider(okRepository);

      expect(provider.categoriesStatus, LoadStatus.initial);
      expect(provider.mealsStatus, LoadStatus.initial);
      expect(provider.selectedCategory, isNull);
      expect(provider.query, '');
    });

    test('loadCategories: loading lalu success', () async {
      final provider = RecipeProvider(okRepository);
      final statuses = <LoadStatus>[];
      provider.addListener(() => statuses.add(provider.categoriesStatus));

      await provider.loadCategories();

      expect(statuses, [LoadStatus.loading, LoadStatus.success]);
      expect(provider.categories, isNotEmpty);
    });

    test('loadCategories: error saat repository gagal', () async {
      final provider = RecipeProvider(failRepository);

      await provider.loadCategories();

      expect(provider.categoriesStatus, LoadStatus.error);
      expect(provider.categoriesError, isNotNull);
    });

    test(
      'selectCategory memfilter katalog dan mengosongkan kata kunci',
      () async {
        final provider = RecipeProvider(okRepository);
        await provider.search('nasi');

        await provider.selectCategory('Chicken');

        expect(provider.selectedCategory, 'Chicken');
        expect(provider.query, '');
        expect(provider.meals, isNotEmpty);
        expect(
          provider.meals.every((meal) => meal.category == 'Chicken'),
          true,
        );
      },
    );

    test('search melepas kategori dan memfilter berdasarkan nama', () async {
      final provider = RecipeProvider(okRepository);
      await provider.selectCategory('Beef');

      await provider.search('rendang');

      expect(provider.selectedCategory, isNull);
      expect(provider.meals.length, 1);
      expect(provider.meals.first.name, 'Beef Rendang');
    });

    test('search tanpa hasil menghasilkan status empty', () async {
      final provider = RecipeProvider(okRepository);

      await provider.search('tidak-ada-resep-ini');

      expect(provider.mealsStatus, LoadStatus.empty);
      expect(provider.meals, isEmpty);
    });

    test('clearFilters mengembalikan seluruh katalog', () async {
      final provider = RecipeProvider(okRepository);
      await provider.selectCategory('Beef');

      await provider.clearFilters();

      expect(provider.selectedCategory, isNull);
      expect(provider.query, '');
      expect(provider.meals, hasLength(dummyMeals.length));
    });
  });
}
