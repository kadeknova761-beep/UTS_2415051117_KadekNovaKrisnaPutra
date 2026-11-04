import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/load_status.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/saved_recipe_provider.dart';
import 'package:resepku/repositories/fake_saved_recipe_repository.dart';

void main() {
  const meal = Meal(id: '1', name: 'Beef Rendang', thumbnailUrl: '');

  test('load pada koleksi kosong menghasilkan empty', () async {
    final provider = SavedRecipeProvider(FakeSavedRecipeRepository());

    await provider.load();

    expect(provider.status, LoadStatus.empty);
  });

  test('save menambah item dan status success', () async {
    final provider = SavedRecipeProvider(FakeSavedRecipeRepository());

    final error = await provider.save(meal, note: 'Enak', rating: 5);

    expect(error, isNull);
    expect(provider.status, LoadStatus.success);
    expect(provider.isSaved('1'), true);
    expect(provider.items.first.note, 'Enak');
  });

  test('save dua kali mengembalikan pesan duplikat', () async {
    final provider = SavedRecipeProvider(FakeSavedRecipeRepository());
    await provider.save(meal);

    final error = await provider.save(meal);

    expect(error, 'Resep sudah ada di koleksi.');
    expect(provider.items, hasLength(1));
  });

  test('load error saat repository gagal', () async {
    final provider = SavedRecipeProvider(
      FakeSavedRecipeRepository(shouldFail: true),
    );

    await provider.load();

    expect(provider.status, LoadStatus.error);
    expect(provider.error, isNotNull);
  });
}
