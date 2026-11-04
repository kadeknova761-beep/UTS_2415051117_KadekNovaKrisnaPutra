import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/load_status.dart';
import '../models/saved_recipe.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/meal_image.dart';
import '../widgets/save_recipe_sheet.dart';
import '../widgets/state_view.dart';

/// Koleksi resep tersimpan, datanya dari database (Supabase) lewat
/// [SavedRecipeProvider]. Ketuk kartu untuk mengubah catatan dan rating,
/// ikon tempat sampah untuk menghapus.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedRecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Saya')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(SavedRecipeProvider provider) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const StateView(type: StateViewType.loading);
      case LoadStatus.error:
        return StateView(
          type: StateViewType.error,
          message: provider.error,
          onRetry: provider.load,
        );
      case LoadStatus.empty:
        return const StateView(
          type: StateViewType.empty,
          message: 'Belum ada resep tersimpan.',
        );
      case LoadStatus.success:
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final recipe = provider.items[index];
              return _SavedTile(
                recipe: recipe,
                onEdit: () => _edit(context, recipe),
                onDelete: () => _confirmDelete(context, recipe),
              );
            },
          ),
        );
    }
  }

  Future<void> _edit(BuildContext context, SavedRecipe recipe) async {
    // Diambil sebelum await agar tidak memakai context setelah jeda async.
    final provider = context.read<SavedRecipeProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final input = await SaveRecipeSheet.show(
      context,
      recipe.mealName,
      title: 'Ubah catatan dan rating',
      initialNote: recipe.note,
      initialRating: recipe.rating,
    );
    if (input == null) return;

    final error = await provider.update(
      recipe,
      note: input.note,
      rating: input.rating,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Perubahan disimpan.')),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavedRecipe recipe) async {
    final provider = context.read<SavedRecipeProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus dari koleksi?'),
        content: Text('"${recipe.mealName}" akan dihapus dari koleksimu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await provider.remove(recipe);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Resep dihapus dari koleksi.')),
    );
  }
}

class _SavedTile extends StatelessWidget {
  final SavedRecipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavedTile({
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rating = recipe.rating;

    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: MealImage(url: recipe.thumbnailUrl ?? '', iconSize: 24),
          ),
        ),
        title: Text(recipe.mealName),
        subtitle: recipe.note.isEmpty ? null : Text(recipe.note),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rating != null) ...[
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 2),
              Text('$rating'),
            ],
            IconButton(
              tooltip: 'Hapus dari koleksi',
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
