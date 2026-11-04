import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/dummy_data.dart';
import '../models/meal.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';
import 'recipe_detail_screen.dart';

/// Daftar resep dalam bentuk grid responsif. Sementara memakai data dummy.
class RecipeListScreen extends StatelessWidget {
  final String title;
  final List<Meal> meals;

  const RecipeListScreen({
    super.key,
    required this.title,
    this.meals = dummyMeals,
  });

  void _openDetail(BuildContext context, Meal meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: meals.isEmpty
          ? const StateView(
              type: StateViewType.empty,
              message: 'Resep tidak ditemukan.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = Breakpoints.gridColumns(constraints.maxWidth);

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return RecipeCard(
                      meal: meal,
                      onTap: () => _openDetail(context, meal),
                    );
                  },
                );
              },
            ),
    );
  }
}
