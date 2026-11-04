import 'package:flutter/material.dart';

import '../core/dummy_data.dart';
import '../widgets/recipe_card.dart';
import 'recipe_list_screen.dart';

/// Beranda: pencarian cepat, kategori, dan rekomendasi resep.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openList(BuildContext context, String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeListScreen(title: title)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ResepKu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mau masak apa hari ini?', style: theme.textTheme.headlineSmall),
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
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dummyMeals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 170,
                  child: RecipeCard(meal: dummyMeals[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
