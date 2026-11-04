import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';
import 'recipe_detail_screen.dart';
import 'recipe_list_screen.dart';

/// Beranda: pencarian cepat, kategori, dan rekomendasi resep.
///
/// Compact : rekomendasi berupa daftar geser horizontal.
/// Expanded: rekomendasi berupa grid, isi dibatasi lebar maksimum.
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
      appBar: AppBar(title: const Text('ResepKu')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final expanded = Breakpoints.isExpanded(constraints.maxWidth);
          final columns = Breakpoints.gridColumns(constraints.maxWidth);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 24),
                  Text('Kategori', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _buildCategories(context, provider),
                  const SizedBox(height: 24),
                  Text('Rekomendasi', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _buildRecommendations(context, provider, expanded, columns),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context, RecipeProvider provider) {
    switch (provider.categoriesStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const SizedBox(
          height: 40,
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
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ActionChip(
                label: Text(category.name),
                onPressed: () {
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
    bool expanded,
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
        return expanded
            ? _buildRecommendationGrid(
                context,
                provider.recommendations,
                columns,
              )
            : _buildRecommendationRow(context, provider.recommendations);
    }
  }

  /// Layout compact: daftar geser horizontal.
  Widget _buildRecommendationRow(BuildContext context, List<Meal> meals) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return SizedBox(
            width: 170,
            child: RecipeCard(
              meal: meal,
              onTap: () => _openDetail(context, meal),
            ),
          );
        },
      ),
    );
  }

  /// Layout expanded: grid di dalam ListView induk (tidak scroll sendiri).
  Widget _buildRecommendationGrid(
    BuildContext context,
    List<Meal> meals,
    int columns,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return RecipeCard(meal: meal, onTap: () => _openDetail(context, meal));
      },
    );
  }
}
