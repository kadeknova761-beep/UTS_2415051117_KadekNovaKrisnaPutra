import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/meal.dart';
import 'package:resepku/providers/profile_provider.dart';
import 'package:resepku/providers/saved_recipe_provider.dart';
import 'package:resepku/repositories/fake_profile_repository.dart';
import 'package:resepku/repositories/fake_saved_recipe_repository.dart';
import 'package:resepku/screens/profile_screen.dart';

Future<void> _pumpProfile(
  WidgetTester tester, {
  double width = 400,
  double height = 900,
  bool withSaved = true,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final saved = SavedRecipeProvider(FakeSavedRecipeRepository());
  if (withSaved) {
    await saved.save(
      const Meal(id: '1', name: 'Beef Rendang', thumbnailUrl: ''),
      rating: 4,
    );
    await saved.save(
      const Meal(id: '2', name: 'Nasi Goreng', thumbnailUrl: ''),
      rating: 5,
    );
  } else {
    await saved.load();
  }

  final profile = ProfileProvider(
    FakeProfileRepository(initial: FakeProfileRepository.sample),
  );
  await profile.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>.value(value: profile),
        ChangeNotifierProvider<SavedRecipeProvider>.value(value: saved),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 400.0, 800.0, 1200.0]) {
    testWidgets('profil tampil tanpa overflow di lebar $width', (tester) async {
      await _pumpProfile(tester, width: width);

      expect(find.text('Kadek Nova Krisna Putra'), findsOneWidget);
      expect(find.text('2415051117'), findsOneWidget);
      expect(find.text('PTI 5C'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('menampilkan jumlah resep dan rata-rata rating', (tester) async {
    await _pumpProfile(tester);

    expect(find.text('Tersimpan'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Rating rata-rata'), findsOneWidget);
    expect(find.text('4,5'), findsOneWidget);
  });

  testWidgets('koleksi kosong menampilkan 0 dan strip', (tester) async {
    await _pumpProfile(tester, withSaved: false);

    expect(find.text('0'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('batal pada dialog keluar tidak menghapus profil', (
    tester,
  ) async {
    await _pumpProfile(tester);

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari profil?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari profil?'), findsNothing);
    expect(find.text('Kadek Nova Krisna Putra'), findsOneWidget);
  });
}
