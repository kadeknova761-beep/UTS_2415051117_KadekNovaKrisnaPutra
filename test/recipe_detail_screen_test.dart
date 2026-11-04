import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/core/dummy_data.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/recipe_detail_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';
import 'package:resepku/repositories/meal_repository.dart';
import 'package:resepku/screens/recipe_detail_screen.dart';

/// Repository palsu yang selalu mengembalikan detail lengkap.
class _FullDetailRepository extends FakeMealRepository {
  const _FullDetailRepository() : super(delay: Duration.zero);

  @override
  Future<Meal> getMealDetail(String id) async {
    return const Meal(
      id: '4',
      name: 'Vegetable Curry',
      thumbnailUrl: '',
      category: 'Vegetarian',
      area: 'Indian',
      instructions: 'Tumis bumbu.\nMasukkan sayuran.',
      ingredients: [MealIngredient(name: 'Tomat', measure: '2 buah')],
    );
  }
}

Future<void> _pumpDetail(
  WidgetTester tester,
  MealRepository repository,
  Meal meal,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => RecipeDetailProvider(repository),
      child: MaterialApp(home: RecipeDetailScreen(meal: meal)),
    ),
  );
}

void main() {
  // dummyMeals[0] sudah punya detail, dummyMeals[3] tidak.
  final withDetail = dummyMeals[0];
  final withoutDetail = dummyMeals[3];

  testWidgets('resep tanpa detail memuat bahan dan langkah dari repository', (
    tester,
  ) async {
    await _pumpDetail(tester, const _FullDetailRepository(), withoutDetail);
    await tester.pumpAndSettle();

    expect(find.text('Bahan'), findsOneWidget);
    expect(find.text('Tomat'), findsOneWidget);
    expect(find.text('Langkah memasak'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menampilkan loading lalu empty state bila detail kosong', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      const FakeMealRepository(delay: Duration(milliseconds: 500)),
      withoutDetail,
    );
    await tester.pump();

    expect(find.text('Memuat data...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Detail resep belum tersedia.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menampilkan error dan tombol coba lagi', (tester) async {
    await _pumpDetail(
      tester,
      const FakeMealRepository(delay: Duration.zero, shouldFail: true),
      withoutDetail,
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat data (simulasi).'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resep yang sudah lengkap tampil tanpa memanggil repository', (
    tester,
  ) async {
    // Repository dibuat selalu gagal: bila dipanggil, error akan terlihat.
    await _pumpDetail(
      tester,
      const FakeMealRepository(delay: Duration.zero, shouldFail: true),
      withDetail,
    );
    await tester.pumpAndSettle();

    expect(find.text('Bahan'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
