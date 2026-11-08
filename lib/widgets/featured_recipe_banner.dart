import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/meal.dart';
import 'meal_image.dart';

/// Banner resep unggulan di Beranda (reusable widget #6).
///
/// [large] dipakai di layar lebar: banner dan foto lebih besar.
class FeaturedRecipeBanner extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final bool large;

  const FeaturedRecipeBanner({
    super.key,
    required this.meal,
    this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = large ? 210.0 : 190.0;
    final imageSize = large ? 160.0 : 112.0;

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFC94D), AppTheme.accent],
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilihan hari ini',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.ink.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                        FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          child: const Text('Lihat resep'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: MealImage(url: meal.thumbnailUrl, iconSize: 48),
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
