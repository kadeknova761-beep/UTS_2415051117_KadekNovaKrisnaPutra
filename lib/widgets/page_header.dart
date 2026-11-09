import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Header marun bersudut bawah bulat untuk halaman utama
/// (reusable widget #7): judul, subjudul, dan konten tambahan di bawahnya.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Konten di bawah subjudul (kolom cari, pil statistik, dan sebagainya).
  final Widget? bottom;

  /// Menampilkan tombol kembali putih di sebelah judul.
  final bool showBack;

  final double maxWidth;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bottom,
    this.showBack = false,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    final bottom = this.bottom;

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
                      if (showBack) ...[
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(left: showBack ? 52 : 0),
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                  if (bottom != null) ...[const SizedBox(height: 16), bottom],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
