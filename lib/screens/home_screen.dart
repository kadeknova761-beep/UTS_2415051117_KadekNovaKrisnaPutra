import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_recipe_banner.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';
import 'recipe_detail_screen.dart';
import 'recipe_list_screen.dart';

/// Beranda: pencarian cepat, resep unggulan, kategori, dan rekomendasi.
///
/// Grid rekomendasi berubah jumlah kolomnya menurut lebar layar,
/// dan isi dibatasi lebar maksimum di layar lebar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _maxContentWidth = 1100;

  void _openList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RecipeListScreen(title: 'Daftar resep'),
      ),
    );
  }

  void _openDetail(BuildContext context, Meal meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: const _BrandTitle()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final expanded = Breakpoints.isExpanded(constraints.maxWidth);
          final columns = Breakpoints.gridColumns(constraints.maxWidth);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    'Mau masak apa hari ini?',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    onTap: () {
                      provider.clearFilters();
                      _openList(context);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari resep...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatured(context, provider, expanded),
                  const SizedBox(height: 24),
                  Text('Kategori', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _buildCategories(context, provider),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rekomendasi',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          _openList(context);
                        },
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRecommendations(context, provider, columns),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Banner resep unggulan: resep pertama dari daftar rekomendasi.
  Widget _buildFeatured(
    BuildContext context,
    RecipeProvider provider,
    bool expanded,
  ) {
    switch (provider.recommendationsStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return SizedBox(
          height: expanded ? 210 : 190,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        );
      case LoadStatus.error:
      case LoadStatus.empty:
        // Pesan error atau kosong ditampilkan di bagian Rekomendasi.
        return const SizedBox.shrink();
      case LoadStatus.success:
        final meal = provider.recommendations.first;
        return FeaturedRecipeBanner(
          meal: meal,
          large: expanded,
          onTap: () => _openDetail(context, meal),
        );
    }
  }

  Widget _buildCategories(BuildContext context, RecipeProvider provider) {
    switch (provider.categoriesStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const SizedBox(
          height: 44,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      case LoadStatus.error:
        return Row(
          children: [
            Expanded(
              child: Text(provider.categoriesError ?? 'Gagal memuat kategori.'),
            ),
            TextButton(
              onPressed: provider.loadCategories,
              child: const Text('Coba lagi'),
            ),
          ],
        );
      case LoadStatus.empty:
        return const Text('Belum ada kategori.');
      case LoadStatus.success:
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return CategoryChip(
                label: category.name,
                onTap: () {
                  provider.selectCategory(category.name);
                  _openList(context);
                },
              );
            },
          ),
        );
    }
  }

  Widget _buildRecommendations(
    BuildContext context,
    RecipeProvider provider,
    int columns,
  ) {
    switch (provider.recommendationsStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const StateView(type: StateViewType.loading);
      case LoadStatus.error:
        return StateView(
          type: StateViewType.error,
          message: provider.recommendationsError,
          onRetry: provider.loadRecommendations,
        );
      case LoadStatus.empty:
        return const StateView(
          type: StateViewType.empty,
          message: 'Belum ada rekomendasi.',
        );
      case LoadStatus.success:
        // Resep pertama sudah tampil di banner.
        final meals = provider.recommendations.skip(1).toList();
        if (meals.isEmpty) return const SizedBox.shrink();
        return _buildGrid(context, meals, columns);
    }
  }

  /// Grid di dalam ListView induk (tidak scroll sendiri).
  Widget _buildGrid(BuildContext context, List<Meal> meals, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return RecipeCard(meal: meal, onTap: () => _openDetail(context, meal));
      },
    );
  }
}

/// Judul AppBar: lencana ikon dan nama aplikasi.
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(Icons.restaurant_menu, size: 18, color: Colors.white),
          ),
        ),
        SizedBox(width: 10),
        Text('ResepKu'),
      ],
    );
  }
}
