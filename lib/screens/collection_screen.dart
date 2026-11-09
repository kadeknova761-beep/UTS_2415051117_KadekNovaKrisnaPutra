import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/load_status.dart';
import '../models/saved_recipe.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/meal_image.dart';
import '../widgets/page_header.dart';
import '../widgets/state_view.dart';
import 'recipe_note_screen.dart';

/// Koleksi resep tersimpan, datanya dari database (Supabase) lewat
/// [SavedRecipeProvider]. Ketuk kartu untuk mengubah catatan dan rating,
/// ikon tempat sampah atau geser ke kiri untuk menghapus.
class CollectionScreen extends StatelessWidget {
  /// Dipanggil tombol "Jelajahi resep" pada tampilan kosong.
  final VoidCallback? onExplore;

  const CollectionScreen({super.key, this.onExplore});

  static const double _maxContentWidth = 760;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedRecipeProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildHeader(SavedRecipeProvider provider) {
    final success = provider.status == LoadStatus.success;
    final items = provider.items;
    final ratings = items.map((item) => item.rating).whereType<int>().toList();
    final average = ratings.isEmpty
        ? null
        : ratings.reduce((a, b) => a + b) / ratings.length;

    return PageHeader(
      title: 'Koleksi Saya',
      subtitle: 'Resep yang kamu simpan',
      maxWidth: _maxContentWidth,
      bottom: success
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderStat(
                  icon: Icons.bookmark,
                  label: '${items.length} resep',
                ),
                if (average != null)
                  _HeaderStat(
                    icon: Icons.star_rounded,
                    label: 'Rata-rata ${_formatAverage(average)}',
                  ),
              ],
            )
          : null,
    );
  }

  String _formatAverage(double value) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
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
        return _EmptyCollection(onExplore: onExplore);
      case LoadStatus.success:
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: RefreshIndicator(
              onRefresh: provider.load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                itemCount: provider.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = provider.items[index];
                  return Dismissible(
                    key: ValueKey(recipe.id ?? recipe.mealId),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    // Dialog konfirmasi yang sama dengan tombol hapus.
                    // Item selalu kembali ke posisi semula; bila jadi
                    // dihapus, daftar dibangun ulang oleh provider.
                    confirmDismiss: (_) async {
                      await _confirmDelete(context, recipe);
                      return false;
                    },
                    child: _SavedTile(
                      recipe: recipe,
                      onEdit: () => _edit(context, recipe),
                      onDelete: () => _confirmDelete(context, recipe),
                    ),
                  );
                },
              ),
            ),
          ),
        );
    }
  }

  Future<void> _edit(BuildContext context, SavedRecipe recipe) async {
    // Diambil sebelum await agar tidak memakai context setelah jeda async.
    final provider = context.read<SavedRecipeProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final input = await RecipeNoteScreen.open(
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

/// Pil statistik di header.
class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Latar yang terlihat saat kartu digeser untuk dihapus.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 28),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
}

/// Tampilan saat koleksi masih kosong.
class _EmptyCollection extends StatelessWidget {
  final VoidCallback? onExplore;

  const _EmptyCollection({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onExplore = this.onExplore;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 44,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada resep tersimpan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Simpan resep favoritmu dari halaman detail.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            if (onExplore != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onExplore,
                icon: const Icon(Icons.search),
                label: const Text('Jelajahi resep'),
              ),
            ],
          ],
        ),
      ),
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
    final theme = Theme.of(context);
    final rating = recipe.rating;

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: const Color(0x26000000),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: MealImage(
                    url: recipe.thumbnailUrl ?? '',
                    iconSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.mealName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (recipe.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        recipe.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(height: 8),
                      _RatingBadge(rating: rating),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus dari koleksi',
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.primary,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lencana rating berwarna kuning-emas.
class _RatingBadge extends StatelessWidget {
  final int rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AppTheme.accent.withValues(alpha: 0.28),
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: AppTheme.accent),
            const SizedBox(width: 4),
            Text(
              '$rating',
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
