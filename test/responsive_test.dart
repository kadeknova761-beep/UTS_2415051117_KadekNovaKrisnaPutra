import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/core/breakpoints.dart';
import 'package:resepku/main.dart';
import 'package:resepku/providers/recipe_provider.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';
import 'package:resepku/screens/recipe_list_screen.dart';

const _repository = FakeMealRepository(delay: Duration.zero);

void main() {
  test('Breakpoints.gridColumns menurut lebar', () {
    expect(Breakpoints.gridColumns(360), 2);
    expect(Breakpoints.gridColumns(599), 2);
    expect(Breakpoints.gridColumns(600), 3);
    expect(Breakpoints.gridColumns(999), 3);
    expect(Breakpoints.gridColumns(1000), 4);
  });

  Future<void> setScreen(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  int columnsOf(WidgetTester tester) {
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    return delegate.crossAxisCount;
  }

  testWidgets('List: kolom grid berubah menurut lebar tanpa overflow', (
    tester,
  ) async {
    final expected = <double, int>{400: 2, 800: 3, 1200: 4};

    for (final entry in expected.entries) {
      await setScreen(tester, entry.key);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(_repository)..init(),
          child: const MaterialApp(home: RecipeListScreen(title: 'Tes')),
        ),
      );
      await tester.pumpAndSettle();

      expect(columnsOf(tester), entry.value, reason: 'lebar ${entry.key}');
      expect(tester.takeException(), isNull, reason: 'lebar ${entry.key}');
    }
  });

  testWidgets('Home: compact memakai daftar, wide memakai grid', (
    tester,
  ) async {
    await setScreen(tester, 400);
    await tester.pumpWidget(const ResepKuApp(repository: _repository));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
    expect(tester.takeException(), isNull);

    await setScreen(tester, 1200);
    await tester.pumpWidget(const ResepKuApp(repository: _repository));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
