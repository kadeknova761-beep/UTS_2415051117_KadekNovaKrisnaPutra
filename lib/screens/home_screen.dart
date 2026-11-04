import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/dummy_data.dart';
import '../models/meal.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'recipe_list_screen.dart';

/// Beranda: pencarian cepat, kategori, dan rekomendasi resep.
///
/// Compact : rekomendasi berupa daftar geser horizontal.
/// Expanded: rekomendasi berupa grid, isi dibatasi lebar maksimum.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _maxContentWidth = 1100;

  void _openList(BuildContext context, String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeListScreen(title: title)));
  }

  void _openDetail(BuildContext context, Meal meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    onTap: () => _openList(context, 'Semua resep'),
                    decoration: const InputDecoration(
                      hintText: 'Cari resep...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Kategori', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = dummyCategories[index];
                        return ActionChip(
                          label: Text(category.name),
                          onPressed: () => _openList(context, category.name),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Rekomendasi', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (expanded)
                    _buildRecommendationGrid(context, columns)
                  else
                    _buildRecommendationRow(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Layout compact: daftar geser horizontal.
  Widget _buildRecommendationRow(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dummyMeals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final meal = dummyMeals[index];
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
  Widget _buildRecommendationGrid(BuildContext context, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: dummyMeals.length,
      itemBuilder: (context, index) {
        final meal = dummyMeals[index];
        return RecipeCard(meal: meal, onTap: () => _openDetail(context, meal));
      },
    );
  }
}
