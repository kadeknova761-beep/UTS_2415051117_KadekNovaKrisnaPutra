import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/main.dart';
import 'package:resepku/screens/recipe_detail_screen.dart';

void main() {
  Future<void> setScreen(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder navLabel(String label) {
    return find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );
  }

  testWidgets('compact memakai NavigationBar, wide memakai NavigationRail', (
    tester,
  ) async {
    await setScreen(tester, 400);
    await tester.pumpWidget(const ResepKuApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await setScreen(tester, 1200);
    await tester.pumpWidget(const ResepKuApp());
    await tester.pump();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('berpindah tab lewat navigasi utama', (tester) async {
    await setScreen(tester, 400);
    await tester.pumpWidget(const ResepKuApp());

    await tester.tap(navLabel('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('2415051117'), findsOneWidget);

    await tester.tap(navLabel('Koleksi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada resep tersimpan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list ke detail membawa data resep', (tester) async {
    await setScreen(tester, 400);
    await tester.pumpWidget(const ResepKuApp());

    await tester.tap(find.text('Nasi Goreng Kampung'));
    await tester.pumpAndSettle();

    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    expect(find.text('Nasi Goreng Kampung'), findsOneWidget);
    expect(find.text('Bahan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
