import 'package:flutter/material.dart';

import '../core/dummy_data.dart';
import '../models/meal.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';

/// Daftar resep dalam bentuk grid. Sementara memakai data dummy.
class RecipeListScreen extends StatelessWidget {
  final String title;
  final List<Meal> meals;

  const RecipeListScreen({
    super.key,
    required this.title,
    this.meals = dummyMeals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: meals.isEmpty
          ? const StateView(
              type: StateViewType.empty,
              message: 'Resep tidak ditemukan.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                return RecipeCard(meal: meals[index]);
              },
            ),
    );
  }
}
