import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Chip kategori berbentuk pil (reusable widget #5).
///
/// Aktif: latar marun dan teks putih. Tidak aktif: latar abu muda.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppTheme.primary : AppTheme.surfaceMuted,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                label,
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : AppTheme.ink,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
