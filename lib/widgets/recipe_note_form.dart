import 'package:flutter/material.dart';

import '../core/validators.dart';

/// Hasil form catatan dan rating.
class SaveRecipeInput {
  final String note;
  final int rating;

  const SaveRecipeInput({required this.note, required this.rating});
}

/// Form catatan dan rating. Dipakai untuk menyimpan resep baru dan
/// mengubah resep yang sudah tersimpan. Validasi memakai [Validators].
class RecipeNoteForm extends StatefulWidget {
  final String mealName;
  final String initialNote;
  final int? initialRating;
  final ValueChanged<SaveRecipeInput> onSubmit;

  const RecipeNoteForm({
    super.key,
    required this.mealName,
    required this.onSubmit,
    this.initialNote = '',
    this.initialRating,
  });

  @override
  State<RecipeNoteForm> createState() => _RecipeNoteFormState();
}

class _RecipeNoteFormState extends State<RecipeNoteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  int? _rating;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();
    widget.onSubmit(
      SaveRecipeInput(note: _noteController.text.trim(), rating: _rating!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.mealName, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
            validator: Validators.note,
          ),
          const SizedBox(height: 16),
          Text('Rating', style: theme.textTheme.titleMedium),
          FormField<int>(
            initialValue: widget.initialRating,
            validator: Validators.rating,
            onSaved: (value) => _rating = value,
            builder: (field) {
              final selected = field.value ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (
                        var i = Validators.minRating;
                        i <= Validators.maxRating;
                        i++
                      )
                        IconButton(
                          tooltip: 'Rating $i',
                          icon: Icon(
                            i <= selected ? Icons.star : Icons.star_border,
                          ),
                          onPressed: () => field.didChange(i),
                        ),
                    ],
                  ),
                  if (field.hasError)
                    Text(
                      field.errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
