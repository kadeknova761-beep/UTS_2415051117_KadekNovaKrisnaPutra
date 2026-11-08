import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/main.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';
import 'package:resepku/repositories/fake_profile_repository.dart';
import 'package:resepku/widgets/floating_nav_bar.dart';

const _meals = FakeMealRepository(delay: Duration.zero);

void main() {
  Future<void> setScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpApp(
    WidgetTester tester,
    FakeProfileRepository profiles,
  ) async {
    await setScreen(tester);
    await tester.pumpWidget(
      ResepKuApp(repository: _meals, profileRepository: profiles),
    );
    await tester.pumpAndSettle();
  }

  Finder navLabel(String label) {
    return find.descendant(
      of: find.byType(FloatingNavBar),
      matching: find.text(label),
    );
  }

  testWidgets('tanpa profil, aplikasi menampilkan layar pengisian profil', (
    tester,
  ) async {
    await pumpApp(tester, FakeProfileRepository());

    expect(find.text('Selamat datang di ResepKu'), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsNothing);
  });

  testWidgets('validasi menolak isian kosong', (tester) async {
    await pumpApp(tester, FakeProfileRepository());

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.text('Nama wajib diisi.'), findsOneWidget);
    expect(find.text('NIM wajib diisi.'), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsNothing);
  });

  testWidgets('mengisi profil membuka aplikasi dan tampil di tab Profil', (
    tester,
  ) async {
    await pumpApp(tester, FakeProfileRepository());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Budi Santoso');
    await tester.enterText(fields.at(1), '1234567890');
    await tester.enterText(fields.at(2), 'PTI 5A');
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingNavBar), findsOneWidget);

    await tester.tap(navLabel('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('PTI 5A'), findsOneWidget);
  });

  testWidgets('Keluar menghapus profil dan kembali ke layar pengisian', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeProfileRepository(initial: FakeProfileRepository.sample),
    );

    await tester.tap(navLabel('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari profil?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Keluar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di ResepKu'), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsNothing);
  });
}
