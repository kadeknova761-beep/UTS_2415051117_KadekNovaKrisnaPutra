import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/app_theme.dart';
import 'package:resepku/widgets/category_chip.dart';

void main() {
  Color chipColor(WidgetTester tester) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(CategoryChip),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.color!;
  }

  testWidgets('menampilkan label dan memanggil onTap', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(label: 'Beef', onTap: () => taps++),
        ),
      ),
    );

    expect(find.text('Beef'), findsOneWidget);

    await tester.tap(find.text('Beef'));
    expect(taps, 1);
  });

  testWidgets('warna berbeda untuk chip aktif dan tidak aktif', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryChip(label: 'Beef')),
      ),
    );
    expect(chipColor(tester), AppTheme.surfaceMuted);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoryChip(label: 'Beef', selected: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(chipColor(tester), AppTheme.primary);
  });
}
