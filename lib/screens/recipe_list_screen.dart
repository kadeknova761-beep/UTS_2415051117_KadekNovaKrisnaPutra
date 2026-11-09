import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_view.dart';
import 'recipe_detail_screen.dart';

/// Katalog resep: header pencarian, filter kategori, dan grid responsif.
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
      body: Column(
        children: [
          _SearchHeader(
            title: widget.title,
            canPop: Navigator.of(context).canPop(),
            controller: _searchController,
            hasQuery: provider.query.isNotEmpty,
            maxWidth: _maxContentWidth,
            onChanged: (value) {
              _provider.onSearchChanged(value);
            },
            onClear: () {
              _provider.clearFilters();
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Column(
                  children: [
                    _buildChips(provider),
                    _buildSummary(provider),
                    Expanded(child: _buildBody(provider)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(RecipeProvider provider) {
    if (provider.categories.isEmpty) return const SizedBox(height: 8);

    final noFilter =
        provider.selectedCategory == null && provider.query.isEmpty;

    return SizedBox(
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: provider.categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: 'Semua',
              selected: noFilter,
              onTap: () {
                _provider.clearFilters();
              },
            );
          }

          final category = provider.categories[index - 1];
          final selected = provider.selectedCategory == category.name;
          return CategoryChip(
            label: category.name,
            selected: selected,
            onTap: () {
              _provider.selectCategory(selected ? null : category.name);
            },
          );
        },
      ),
    );
  }

  /// Ringkasan hasil di atas grid.
  Widget _buildSummary(RecipeProvider provider) {
    if (provider.mealsStatus != LoadStatus.success) {
      return const SizedBox.shrink();
    }

    final count = provider.meals.length;
    final query = provider.query.trim();
    final category = provider.selectedCategory;

    final String label;
    if (query.isNotEmpty) {
      label = '$count hasil untuk "$query"';
    } else if (category != null) {
      label = '$count resep di kategori $category';
    } else {
      label = '$count resep';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: AppTheme.inkSoft),
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
            final card = RecipeCard(meal: meal, onTap: () => _openDetail(meal));

            // Hanya kartu pertama yang dianimasikan agar tidak berat.
            if (index >= 6) return card;
            return _FadeInUp(key: ValueKey(meal.id), index: index, child: card);
          },
        );
      },
    );
  }
}

/// Header marun: judul, subjudul, dan kolom cari putih.
class _SearchHeader extends StatelessWidget {
  final String title;
  final bool canPop;
  final TextEditingController controller;
  final bool hasQuery;
  final double maxWidth;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.title,
    required this.canPop,
    required this.controller,
    required this.hasQuery,
    required this.maxWidth,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (canPop) ...[
                        const BackButton(color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: canPop ? 52 : 0),
                    child: Text(
                      'Temukan resep favoritmu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari resep...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      suffixIcon: hasQuery
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: onClear,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Memunculkan anak dengan fade dan geser ke atas satu kali.
class _FadeInUp extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeInUp({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 70),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
    );
  }
}
