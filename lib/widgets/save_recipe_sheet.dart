import 'package:flutter/material.dart';

import '../core/validators.dart';

/// Hasil form simpan resep.
class SaveRecipeInput {
  final String note;
  final int rating;

  const SaveRecipeInput({required this.note, required this.rating});
}

/// Bottom sheet berisi form catatan dan rating untuk menyimpan resep.
/// Mengembalikan [SaveRecipeInput], atau null bila dibatalkan.
class SaveRecipeSheet extends StatefulWidget {
  final String mealName;

  const SaveRecipeSheet({super.key, required this.mealName});

  static Future<SaveRecipeInput?> show(BuildContext context, String mealName) {
    return showModalBottomSheet<SaveRecipeInput>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => SaveRecipeSheet(mealName: mealName),
    );
  }

  @override
  State<SaveRecipeSheet> createState() => _SaveRecipeSheetState();
}

class _SaveRecipeSheetState extends State<SaveRecipeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  int? _rating;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();
    Navigator.of(
      context,
    ).pop(SaveRecipeInput(note: _noteController.text.trim(), rating: _rating!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      // Naik mengikuti keyboard agar field tidak tertutup.
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simpan ke koleksi', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(widget.mealName, style: theme.textTheme.bodyMedium),
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
      ),
    );
  }
}
