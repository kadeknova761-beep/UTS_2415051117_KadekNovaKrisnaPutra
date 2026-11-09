import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/saved_recipe_provider.dart';
import 'package:resepku/repositories/fake_saved_recipe_repository.dart';
import 'package:resepku/screens/collection_screen.dart';

const _longName =
    'Resep dengan nama yang sangat panjang sekali sampai harus terpotong '
    'menjadi dua baris saja agar tidak overflow';

Future<SavedRecipeProvider> _pump(
  WidgetTester tester, {
  double width = 400,
  bool seed = true,
  bool withLongName = false,
  VoidCallback? onExplore,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final provider = SavedRecipeProvider(FakeSavedRecipeRepository());
  if (seed) {
    await provider.save(
      const Meal(id: '1', name: 'Beef Rendang', thumbnailUrl: ''),
      note: 'Enak',
      rating: 4,
    );
    await provider.save(
      const Meal(id: '2', name: 'Nasi Goreng', thumbnailUrl: ''),
      rating: 5,
    );
    if (withLongName) {
      await provider.save(
        const Meal(id: '3', name: _longName, thumbnailUrl: ''),
        note: 'Catatan yang juga cukup panjang supaya terpotong rapi',
        rating: 3,
      );
    }
  } else {
    await provider.load();
  }

  await tester.pumpWidget(
    ChangeNotifierProvider<SavedRecipeProvider>.value(
      value: provider,
      child: MaterialApp(home: CollectionScreen(onExplore: onExplore)),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  testWidgets('header menampilkan jumlah resep dan rata-rata rating', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Koleksi Saya'), findsOneWidget);
    expect(find.text('2 resep'), findsOneWidget);
    expect(find.text('Rata-rata 4,5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'geser kartu ke kiri membuka dialog dan menghapus bila disetujui',
    (tester) async {
      await _pump(tester);

      await tester.drag(find.text('Beef Rendang'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Hapus dari koleksi?'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Beef Rendang'), findsNothing);
      expect(find.text('Nasi Goreng'), findsOneWidget);
      expect(find.text('1 resep'), findsOneWidget);
    },
  );

  testWidgets('geser lalu batal tidak menghapus resep', (tester) async {
    await _pump(tester);

    await tester.drag(find.text('Beef Rendang'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Beef Rendang'), findsOneWidget);
    expect(find.text('2 resep'), findsOneWidget);
  });

  testWidgets('koleksi kosong menampilkan ajakan dan tombol jelajahi', (
    tester,
  ) async {
    var explored = 0;
    await _pump(tester, seed: false, onExplore: () => explored++);

    expect(find.text('Belum ada resep tersimpan.'), findsOneWidget);

    await tester.tap(find.text('Jelajahi resep'));
    expect(explored, 1);
  });

  testWidgets('koleksi kosong tanpa onExplore tidak menampilkan tombol', (
    tester,
  ) async {
    await _pump(tester, seed: false);

    expect(find.text('Belum ada resep tersimpan.'), findsOneWidget);
    expect(find.text('Jelajahi resep'), findsNothing);
  });

  for (final width in [320.0, 400.0, 800.0, 1200.0]) {
    testWidgets('tidak overflow di lebar $width dengan nama panjang', (
      tester,
    ) async {
      await _pump(tester, width: width, withLongName: true);

      expect(find.text('3 resep'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
