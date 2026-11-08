import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/widgets/floating_nav_bar.dart';

void main() {
  testWidgets(
    'menampilkan label, menandai item aktif, dan memanggil callback',
    (tester) async {
      const items = [
        NavItem('Beranda', Icons.home_outlined, Icons.home),
        NavItem('Cari', Icons.search_outlined, Icons.search),
      ];
      var selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              bottomNavigationBar: FloatingNavBar(
                items: items,
                selectedIndex: selected,
                onDestinationSelected: (index) =>
                    setState(() => selected = index),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Cari'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);

      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();

      expect(selected, 1);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tidak overflow di layar sempit dengan empat item', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavBar(
            items: const [
              NavItem('Beranda', Icons.home_outlined, Icons.home),
              NavItem('Cari', Icons.search_outlined, Icons.search),
              NavItem('Koleksi', Icons.bookmark_border, Icons.bookmark),
              NavItem('Profil', Icons.person_outline, Icons.person),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
