import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/load_status.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/recipe_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';

/// Repository palsu yang mencatat kata kunci yang benar-benar dicari.
class _CountingRepository extends FakeMealRepository {
  _CountingRepository() : super(delay: Duration.zero);

  final List<String> queries = [];

  @override
  Future<List<Meal>> searchMeals(String query) {
    queries.add(query);
    return super.searchMeals(query);
  }
}

void main() {
  const debounce = Duration(milliseconds: 30);
  const wait = Duration(milliseconds: 150);

  test('mengetik cepat hanya memicu satu pencarian', () async {
    final repository = _CountingRepository();
    final provider = RecipeProvider(repository, searchDebounce: debounce);
    addTearDown(provider.dispose);

    provider.onSearchChanged('n');
    provider.onSearchChanged('na');
    provider.onSearchChanged('nas');

    // Kata kunci langsung tersimpan, tetapi belum ada permintaan.
    expect(provider.query, 'nas');
    expect(repository.queries, isEmpty);

    await Future<void>.delayed(wait);

    expect(repository.queries, ['nas']);
    expect(provider.mealsStatus, LoadStatus.success);
  });

  test('memilih kategori membatalkan pencarian yang tertunda', () async {
    final repository = _CountingRepository();
    final provider = RecipeProvider(repository, searchDebounce: debounce);
    addTearDown(provider.dispose);

    provider.onSearchChanged('nasi');
    await provider.selectCategory('Beef');
    await Future<void>.delayed(wait);

    expect(repository.queries, isEmpty);
    expect(provider.selectedCategory, 'Beef');
    expect(provider.query, '');
  });
}
