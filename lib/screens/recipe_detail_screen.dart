import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../providers/recipe_detail_provider.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/meal_image.dart';
import '../widgets/state_view.dart';

/// Detail satu resep.
///
/// Data awal diterima lewat konstruktor (passing data dari list) sehingga
/// judul dan gambar langsung tampil. Bahan dan langkah dimuat lewat
/// [RecipeDetailProvider] bila belum tersedia.
///
/// Compact : gambar di atas, info di bawah.
/// Expanded: gambar di kiri, info di kanan.
class RecipeDetailScreen extends StatefulWidget {
  final Meal meal;

  const RecipeDetailScreen({super.key, required this.meal});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<RecipeDetailProvider>();
    // Ditunda sampai frame pertama selesai: provider memanggil
    // notifyListeners, dan itu tidak boleh terjadi saat widget dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) provider.load(widget.meal);
    });
  }

  Future<void> _save(Meal meal) async {
    final error = await context.read<SavedRecipeProvider>().save(meal);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Tersimpan di koleksi.')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeDetailProvider>();
    final id = widget.meal.id;
    // Pakai detail lengkap bila sudah ada, kalau belum pakai data dari list.
    final meal = provider.detailOf(id) ?? widget.meal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail resep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Simpan ke koleksi',
            onPressed: () => _save(meal),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final expanded = Breakpoints.isExpanded(constraints.maxWidth);

          final image = ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: MealImage(url: meal.thumbnailUrl, iconSize: 64),
            ),
          );
          final info = _DetailInfo(
            meal: meal,
            status: provider.statusOf(id),
            errorMessage: provider.errorOf(id),
            onRetry: () => provider.load(widget.meal),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: expanded
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: image),
                          const SizedBox(width: 24),
                          Expanded(flex: 3, child: info),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [image, const SizedBox(height: 16), info],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final Meal meal;
  final LoadStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _DetailInfo({
    required this.meal,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = meal.category;
    final area = meal.area;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (category != null) Chip(label: Text(category)),
            if (area != null) Chip(label: Text(area)),
          ],
        ),
        const SizedBox(height: 20),
        _buildBody(),
      ],
    );
  }

  Widget _buildBody() {
    // Data dari list sudah lengkap: tampilkan langsung tanpa menunggu.
    if (meal.ingredients.isNotEmpty || meal.steps.isNotEmpty) {
      return _DetailContent(meal: meal);
    }

    switch (status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const StateView(type: StateViewType.loading);
      case LoadStatus.error:
        return StateView(
          type: StateViewType.error,
          message: errorMessage,
          onRetry: onRetry,
        );
      case LoadStatus.empty:
      case LoadStatus.success:
        return const StateView(
          type: StateViewType.empty,
          message: 'Detail resep belum tersedia.',
        );
    }
  }
}

class _DetailContent extends StatelessWidget {
  final Meal meal;

  const _DetailContent({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = meal.steps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (meal.ingredients.isNotEmpty) ...[
          Text('Bahan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final item in meal.ingredients)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(item.name)),
                  Text(item.measure, textAlign: TextAlign.end),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
        if (steps.isNotEmpty) ...[
          Text('Langkah memasak', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 28, child: Text('${index + 1}.')),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
