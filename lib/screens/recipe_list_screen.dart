import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';
import 'recipe_detail_screen.dart';

/// Katalog resep: kolom pencarian, filter kategori, dan grid responsif.
///
/// Data dan filter berasal dari [RecipeProvider] sehingga dipakai bersama
/// oleh tab Cari dan halaman daftar yang dibuka dari Home.
class RecipeListScreen extends StatefulWidget {
  final String title;

  const RecipeListScreen({super.key, required this.title});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  static const double _maxContentWidth = 1100;

  late final RecipeProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = context.read<RecipeProvider>();
    _searchController.text = _provider.query;
    _provider.addListener(_syncSearchField);
  }

  /// Menjaga isi kolom cari tetap sama dengan filter di provider
  /// (misalnya saat kategori dipilih dari Home).
  void _syncSearchField() {
    final query = _provider.query;
    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_syncSearchField);
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Meal meal) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(meal: meal)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _provider.onSearchChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari resep...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _provider.clearFilters();
                            },
                          ),
                  ),
                ),
              ),
              if (provider.categories.isNotEmpty)
                SizedBox(
                  height: 62,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    itemCount: provider.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      final selected =
                          provider.selectedCategory == category.name;
                      return CategoryChip(
                        label: category.name,
                        selected: selected,
                        onTap: () {
                          _provider.selectCategory(
                            selected ? null : category.name,
                          );
                        },
                      );
                    },
                  ),
                ),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RecipeProvider provider) {
    switch (provider.mealsStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const StateView(type: StateViewType.loading);
      case LoadStatus.error:
        return StateView(
          type: StateViewType.error,
          message: provider.mealsError,
          onRetry: provider.loadMeals,
        );
      case LoadStatus.empty:
        return const StateView(
          type: StateViewType.empty,
          message: 'Resep tidak ditemukan.',
        );
      case LoadStatus.success:
        return _buildGrid(provider.meals);
    }
  }

  Widget _buildGrid(List<Meal> meals) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Breakpoints.gridColumns(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return RecipeCard(meal: meal, onTap: () => _openDetail(meal));
          },
        );
      },
    );
  }
}
