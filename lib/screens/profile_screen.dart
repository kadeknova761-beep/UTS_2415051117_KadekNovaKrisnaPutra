import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../widgets/state_view.dart';
import 'profile_setup_screen.dart';

/// Profil pengguna (dari penyimpanan lokal) dan informasi aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Scaffold(
        body: StateView(
          type: StateViewType.empty,
          message: 'Profil belum diisi.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    profile.initials,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('NIM'),
                      subtitle: Text(profile.nim),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Kelas'),
                      subtitle: Text(
                        profile.className.isEmpty ? '-' : profile.className,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openEdit(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ubah profil'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.restaurant_menu),
                      title: Text('Tentang aplikasi'),
                      subtitle: Text(
                        'ResepKu: katalog resep dengan koleksi pribadi. '
                        'Project UTS Pemrograman Mobile.',
                      ),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Versi'),
                      subtitle: Text('1.0.0'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
