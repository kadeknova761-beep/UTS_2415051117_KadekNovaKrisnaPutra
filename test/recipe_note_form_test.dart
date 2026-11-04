import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/widgets/recipe_note_form.dart';

Future<void> _pumpForm(
  WidgetTester tester,
  void Function(SaveRecipeInput) onSubmit,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RecipeNoteForm(mealName: 'Nasi Goreng', onSubmit: onSubmit),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('submit tanpa rating menampilkan pesan error', (tester) async {
    SaveRecipeInput? result;
    await _pumpForm(tester, (value) => result = value);

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Pilih rating 1 sampai 5.'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('catatan lebih dari 200 karakter ditolak', (tester) async {
    await _pumpForm(tester, (_) {});

    await tester.tap(find.byTooltip('Rating 3'));
    await tester.enterText(find.byType(TextFormField), 'a' * 201);
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Catatan maksimal 200 karakter.'), findsOneWidget);
  });

  testWidgets('input valid mengembalikan catatan dan rating', (tester) async {
    SaveRecipeInput? result;
    await _pumpForm(tester, (value) => result = value);

    await tester.tap(find.byTooltip('Rating 4'));
    await tester.enterText(find.byType(TextFormField), '  Enak sekali  ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.rating, 4);
    expect(result!.note, 'Enak sekali');
  });

  testWidgets('nilai awal terisi saat mode edit', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecipeNoteForm(
              mealName: 'Nasi Goreng',
              initialNote: 'Catatan lama',
              initialRating: 3,
              onSubmit: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Catatan lama'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(3));
  });
}
