import 'package:flutter/material.dart';

import '../widgets/recipe_note_form.dart';

/// Screen form catatan dan rating. Dipakai untuk Create (dari detail resep)
/// dan Edit (dari koleksi). Mengembalikan [SaveRecipeInput] lewat
/// Navigator.pop, atau null bila pengguna kembali tanpa menyimpan.
class RecipeNoteScreen extends StatelessWidget {
  final String mealName;
  final String title;
  final String initialNote;
  final int? initialRating;

  const RecipeNoteScreen({
    super.key,
    required this.mealName,
    this.title = 'Simpan ke koleksi',
    this.initialNote = '',
    this.initialRating,
  });

  static Future<SaveRecipeInput?> open(
    BuildContext context,
    String mealName, {
    String title = 'Simpan ke koleksi',
    String initialNote = '',
    int? initialRating,
  }) {
    return Navigator.of(context).push<SaveRecipeInput>(
      MaterialPageRoute(
        builder: (_) => RecipeNoteScreen(
          mealName: mealName,
          title: title,
          initialNote: initialNote,
          initialRating: initialRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            // Di layar lebar, form dibatasi agar tidak melebar penuh.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: RecipeNoteForm(
                mealName: mealName,
                initialNote: initialNote,
                initialRating: initialRating,
                onSubmit: (input) => Navigator.of(context).pop(input),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
