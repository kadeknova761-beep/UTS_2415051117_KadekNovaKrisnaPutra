import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../models/meal.dart';
import '../widgets/meal_image.dart';

/// Detail satu resep. Data diterima lewat konstruktor (passing data).
///
/// Compact : gambar di atas, info di bawah.
/// Expanded: gambar di kiri, info di kanan.
class RecipeDetailScreen extends StatelessWidget {
  final Meal meal;

  const RecipeDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail resep')),
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
          final info = _DetailInfo(meal: meal);

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

  const _DetailInfo({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = meal.category;
    final area = meal.area;
    final steps = meal.steps;

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
        if (!meal.hasDetail && meal.ingredients.isEmpty)
          Text(
            'Detail lengkap akan dimuat dari API.',
            style: theme.textTheme.bodyMedium,
          ),
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
