import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/saved_recipe_provider.dart';
import 'package:resepku/repositories/fake_saved_recipe_repository.dart';
import 'package:resepku/screens/collection_screen.dart';

Future<SavedRecipeProvider> _pumpScreen(WidgetTester tester) async {
  final provider = SavedRecipeProvider(FakeSavedRecipeRepository());
  await provider.save(
    const Meal(id: '1', name: 'Beef Rendang', thumbnailUrl: ''),
    rating: 4,
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<SavedRecipeProvider>.value(
      value: provider,
      child: const MaterialApp(home: CollectionScreen()),
    ),
  );
  return provider;
}

void main() {
  testWidgets('menghapus resep lewat dialog konfirmasi', (tester) async {
    await _pumpScreen(tester);
    expect(find.text('Beef Rendang'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari koleksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada resep tersimpan.'), findsOneWidget);
  });

  testWidgets('batal pada dialog tidak menghapus resep', (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.byTooltip('Hapus dari koleksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Beef Rendang'), findsOneWidget);
  });

  testWidgets('mengubah rating lewat sheet edit', (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('Beef Rendang'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rating 2'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });
}
