import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/dummy_data.dart';
import 'package:resepku/core/load_status.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/recipe_detail_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';

Meal _fullMeal(String id) {
  return Meal(
    id: id,
    name: 'Vegetable Curry',
    thumbnailUrl: '',
    category: 'Vegetarian',
    area: 'Indian',
    instructions: 'Tumis bumbu.\nMasukkan sayuran.',
    ingredients: const [MealIngredient(name: 'Tomat', measure: '2 buah')],
  );
}

/// Repository palsu yang mengembalikan detail lengkap dan menghitung panggilan.
class _SpyRepository extends FakeMealRepository {
  _SpyRepository() : super(delay: Duration.zero);

  int detailCalls = 0;

  @override
  Future<Meal> getMealDetail(String id) {
    detailCalls++;
    return Future.value(_fullMeal(id));
  }
}

void main() {
  // dummyMeals[0] sudah punya detail, dummyMeals[3] tidak.
  final withDetail = dummyMeals[0];
  final withoutDetail = dummyMeals[3];

  test('meal yang sudah punya detail tidak memanggil repository', () async {
    final repository = _SpyRepository();
    final provider = RecipeDetailProvider(repository);
    addTearDown(provider.dispose);

    await provider.load(withDetail);

    expect(provider.statusOf(withDetail.id), LoadStatus.success);
    expect(provider.detailOf(withDetail.id)?.name, 'Nasi Goreng Kampung');
    expect(repository.detailCalls, 0);
  });

  test('meal tanpa detail: loading lalu success', () async {
    final provider = RecipeDetailProvider(_SpyRepository());
    addTearDown(provider.dispose);
    final statuses = <LoadStatus>[];
    provider.addListener(() => statuses.add(provider.statusOf('4')));

    await provider.load(withoutDetail);

    expect(statuses, [LoadStatus.loading, LoadStatus.success]);
    expect(provider.detailOf('4')!.ingredients, isNotEmpty);
  });

  test('detail yang sudah dimuat dipakai ulang dari cache', () async {
    final repository = _SpyRepository();
    final provider = RecipeDetailProvider(repository);
    addTearDown(provider.dispose);

    await provider.load(withoutDetail);
    await provider.load(withoutDetail);

    expect(repository.detailCalls, 1);
  });

  test('detail tanpa bahan dan langkah berstatus empty', () async {
    final provider = RecipeDetailProvider(
      const FakeMealRepository(delay: Duration.zero),
    );
    addTearDown(provider.dispose);

    await provider.load(withoutDetail);

    expect(provider.statusOf('4'), LoadStatus.empty);
  });

  test('repository gagal menghasilkan status error dan pesan', () async {
    final provider = RecipeDetailProvider(
      const FakeMealRepository(delay: Duration.zero, shouldFail: true),
    );
    addTearDown(provider.dispose);

    await provider.load(withoutDetail);

    expect(provider.statusOf('4'), LoadStatus.error);
    expect(provider.errorOf('4'), isNotNull);
    expect(provider.detailOf('4'), isNull);
  });
}
