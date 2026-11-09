import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/recipe_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';
import 'package:resepku/screens/recipe_list_screen.dart';
import 'package:resepku/widgets/category_chip.dart';

void main() {
  Future<void> pumpList(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) =>
            RecipeProvider(const FakeMealRepository(delay: Duration.zero))
              ..init(),
        child: const MaterialApp(home: RecipeListScreen(title: 'Cari resep')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan header, chip Semua, dan jumlah resep', (
    tester,
  ) async {
    await pumpList(tester);

    expect(find.text('Cari resep'), findsOneWidget);
    expect(find.text('Temukan resep favoritmu'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('6 resep'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('memilih kategori memfilter dan Semua mengembalikan', (
    tester,
  ) async {
    await pumpList(tester);

    await tester.tap(find.widgetWithText(CategoryChip, 'Beef'));
    await tester.pumpAndSettle();
    expect(find.text('1 resep di kategori Beef'), findsOneWidget);

    await tester.tap(find.widgetWithText(CategoryChip, 'Semua'));
    await tester.pumpAndSettle();
    expect(find.text('6 resep'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pencarian tanpa hasil menampilkan empty state', (tester) async {
    await pumpList(tester);

    await tester.enterText(find.byType(TextField), 'tidak-ada-resep-ini');
    // Pencarian memakai debounce, beri waktu sebelum menunggu selesai.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Resep tidak ditemukan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
