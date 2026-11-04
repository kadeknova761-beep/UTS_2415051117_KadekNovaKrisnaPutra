import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/widgets/save_recipe_sheet.dart';

Future<void> _openSheet(
  WidgetTester tester,
  void Function(SaveRecipeInput?) onResult,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                onResult(await SaveRecipeSheet.show(context, 'Nasi Goreng'));
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Buka'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('submit tanpa rating menampilkan pesan error', (tester) async {
    SaveRecipeInput? result;
    await _openSheet(tester, (value) => result = value);

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Pilih rating 1 sampai 5.'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('catatan lebih dari 200 karakter ditolak', (tester) async {
    await _openSheet(tester, (_) {});

    await tester.tap(find.byTooltip('Rating 3'));
    await tester.enterText(find.byType(TextFormField), 'a' * 201);
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Catatan maksimal 200 karakter.'), findsOneWidget);
  });

  testWidgets('input valid mengembalikan catatan dan rating', (tester) async {
    SaveRecipeInput? result;
    await _openSheet(tester, (value) => result = value);

    await tester.tap(find.byTooltip('Rating 4'));
    await tester.enterText(find.byType(TextFormField), '  Enak sekali  ');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.rating, 4);
    expect(result!.note, 'Enak sekali');
  });
}
