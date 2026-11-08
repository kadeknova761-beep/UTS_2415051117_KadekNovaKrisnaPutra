import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/core/dummy_data.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/recipe_detail_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';
import 'package:resepku/screens/recipe_detail_screen.dart';

void main() {
  // dummyMeals[0] sudah punya bahan dan langkah.
  final meal = dummyMeals[0];

  Future<void> pumpDetail(WidgetTester tester, double width, Meal meal) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RecipeDetailProvider(
          const FakeMealRepository(delay: Duration.zero),
        ),
        child: MaterialApp(home: RecipeDetailScreen(meal: meal)),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [400.0, 800.0, 1200.0]) {
    testWidgets('detail tampil tanpa overflow di lebar $width', (tester) async {
      await pumpDetail(tester, width, meal);

      expect(find.text('Nasi Goreng Kampung'), findsOneWidget);
      expect(find.text('Bahan'), findsOneWidget);
      expect(find.text('Langkah memasak'), findsOneWidget);
      expect(find.text('Simpan ke koleksi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mencentang bahan mencoret teksnya', (tester) async {
    await pumpDetail(tester, 400, meal);

    expect(
      tester.widget<Text>(find.text('Nasi putih')).style?.decoration,
      isNot(TextDecoration.lineThrough),
    );

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(
      tester.widget<Text>(find.text('Nasi putih')).style?.decoration,
      TextDecoration.lineThrough,
    );
  });
}
