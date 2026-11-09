import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/load_status.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/saved_recipe_provider.dart';
import '../widgets/page_header.dart';
import '../widgets/state_view.dart';
import 'profile_setup_screen.dart';

/// Profil pengguna (dari penyimpanan lokal), ringkasan koleksi,
/// dan informasi aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const double _maxContentWidth = 600;

  void _openEdit(BuildContext context) {
    final profile = context.read<ProfileProvider>().profile;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileSetupScreen(initial: profile)),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ProfileProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari profil?'),
        content: const Text(
          'Profil di perangkat ini akan dihapus dan kamu perlu mengisinya '
          'lagi. Resep di koleksimu tidak ikut dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Jika berhasil, ProfileGate otomatis kembali ke layar pengisian profil.
    final error = await provider.clear();
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String _average(List<int> ratings) {
    final value = ratings.reduce((a, b) => a + b) / ratings.length;
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Scaffold(
        body: StateView(
          type: StateViewType.empty,
          message: 'Profil belum diisi.',
        ),
      );
    }

    final saved = context.watch<SavedRecipeProvider>();
    final loaded =
        saved.status == LoadStatus.success || saved.status == LoadStatus.empty;
    final ratings = saved.items
        .map((item) => item.rating)
        .whereType<int>()
        .toList();
    final countText = loaded ? '${saved.items.length}' : '-';
    final averageText = ratings.isEmpty ? '-' : _average(ratings);

    return Scaffold(
      body: ListView(
        // Tanpa padding bawaan: PageHeader menangani area aman di atas.
        padding: EdgeInsets.zero,
        children: [
          PageHeader(
            title: 'Profil',
            maxWidth: _maxContentWidth,
            bottom: _ProfileHero(profile: profile),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bookmark,
                            value: countText,
                            label: 'Tersimpan',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_rounded,
                            value: averageText,
                            label: 'Rating rata-rata',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      children: [
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'NIM',
                          value: profile.nim,
                        ),
                        const _RowDivider(),
                        _InfoRow(
                          icon: Icons.school_outlined,
                          label: 'Kelas',
                          value: profile.className.isEmpty
                              ? '-'
                              : profile.className,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _openEdit(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ubah profil'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => _confirmSignOut(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.10,
                        ),
                        foregroundColor: AppTheme.primary,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                    ),
                    const SizedBox(height: 16),
                    const _SectionCard(
                      children: [
                        _InfoRow(
                          icon: Icons.restaurant_menu,
                          label: 'Tentang aplikasi',
                          value:
                              'ResepKu: katalog resep dengan koleksi pribadi. '
                              'Project UTS Pemrograman Mobile.',
                        ),
                        _RowDivider(),
                        _InfoRow(
                          icon: Icons.info_outline,
                          label: 'Versi',
                          value: '1.0.0',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar berinisial dan nama di dalam header marun.
class _ProfileHero extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                profile.initials,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );
}

/// Ikon di lingkaran kuning-emas tipis.
class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppTheme.primary),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(icon: icon),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
