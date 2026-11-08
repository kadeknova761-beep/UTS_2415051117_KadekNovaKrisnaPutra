import 'package:flutter/material.dart';

import '../core/app_theme.dart';
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
                    const Positioned(top: 10, right: 10, child: _SavedBadge()),
                ],
              ),
            ),
            // Tinggi tetap agar tinggi gambar seragam di semua kartu,
            // berapa pun panjang judulnya.
            SizedBox(
              height: 92,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
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

/// Penanda resep yang sudah ada di koleksi.
class _SavedBadge extends StatelessWidget {
  const _SavedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.favorite, size: 18, color: AppTheme.primary),
    );
  }
}
