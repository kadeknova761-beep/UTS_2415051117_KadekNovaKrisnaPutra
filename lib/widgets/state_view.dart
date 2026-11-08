import 'package:flutter/material.dart';

enum StateViewType { loading, error, empty }

/// Tampilan untuk state loading, error, dan empty (reusable widget #2).
class StateView extends StatelessWidget {
  final StateViewType type;
  final String? message;
  final VoidCallback? onRetry;

  /// Mengganti ikon bawaan untuk state error atau empty.
  final IconData? icon;

  const StateView({
    super.key,
    required this.type,
    this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final IconData? defaultIcon = switch (type) {
      StateViewType.loading => null,
      StateViewType.error => Icons.cloud_off,
      StateViewType.empty => Icons.search_off,
    };
    final iconData = icon ?? defaultIcon;

    final String text =
        message ??
        switch (type) {
          StateViewType.loading => 'Memuat data...',
          StateViewType.error => 'Terjadi kesalahan.',
          StateViewType.empty => 'Data tidak ditemukan.',
        };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == StateViewType.loading || iconData == null)
              const CircularProgressIndicator()
            else
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.08),
                ),
                child: Icon(iconData, size: 40, color: scheme.primary),
              ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (type == StateViewType.error && onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
