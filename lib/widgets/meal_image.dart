import 'package:flutter/material.dart';

/// Gambar resep dengan placeholder saat kosong, memuat, atau gagal
/// (reusable widget #3). Harus ditaruh di parent yang ukurannya terbatas.
class MealImage extends StatelessWidget {
  final String url;
  final double iconSize;

  const MealImage({super.key, required this.url, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: iconSize,
        color: scheme.onSurfaceVariant,
      ),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : placeholder;
      },
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
