import 'package:flutter/material.dart';

import '../models/meal.dart';
import 'meal_image.dart';

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
                  MealImage(url: meal.thumbnailUrl),
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
}
