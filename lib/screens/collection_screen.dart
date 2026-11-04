import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/load_status.dart';
import '../models/saved_recipe.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/meal_image.dart';
import '../widgets/state_view.dart';

/// Koleksi resep tersimpan, datanya dari database (Supabase) lewat
/// [SavedRecipeProvider].
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
            itemBuilder: (context, index) =>
                _SavedTile(recipe: provider.items[index]),
          ),
        );
    }
  }
}

class _SavedTile extends StatelessWidget {
  final SavedRecipe recipe;

  const _SavedTile({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final rating = recipe.rating;

    return Card(
      child: ListTile(
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
        trailing: rating == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 18),
                  const SizedBox(width: 2),
                  Text('$rating'),
                ],
              ),
      ),
    );
  }
}
