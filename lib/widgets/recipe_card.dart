import 'package:flutter/material.dart';

import '../models/meal.dart';

/// Kartu resep yang dipakai di Home dan List (reusable widget #1).
class RecipeCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final bool isSaved;

  const RecipeCard({
    super.key,
    required this.meal,
    this.onTap,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [meal.category, meal.area].whereType<String>().join(' • ');

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(theme.colorScheme),
                  if (isSaved)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                ],
              ),
            ),
            // Tinggi tetap agar tinggi gambar seragam di semua kartu,
            // berapa pun panjang judulnya.
            SizedBox(
              height: 84,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme scheme) {
    final placeholder = Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: 40,
        color: scheme.onSurfaceVariant,
      ),
    );

    if (meal.thumbnailUrl.isEmpty) return placeholder;

    return Image.network(
      meal.thumbnailUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
