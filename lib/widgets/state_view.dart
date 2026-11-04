import 'package:flutter/material.dart';

enum StateViewType { loading, error, empty }

/// Tampilan untuk state loading, error, dan empty (reusable widget #2).
class StateView extends StatelessWidget {
  final StateViewType type;
  final String? message;
  final VoidCallback? onRetry;

  const StateView({super.key, required this.type, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final IconData? icon = switch (type) {
      StateViewType.loading => null,
      StateViewType.error => Icons.cloud_off,
      StateViewType.empty => Icons.search_off,
    };

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
            if (icon == null)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 56, color: theme.colorScheme.outline),
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
