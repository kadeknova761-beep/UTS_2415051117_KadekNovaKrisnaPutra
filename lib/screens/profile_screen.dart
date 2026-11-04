import 'package:flutter/material.dart';

/// Profil mahasiswa dan informasi aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _name = 'Kadek Nova Krisna Putra';
  static const String _nim = '2415051117';
  static const String _className = 'PTI 5C';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    'KN',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              const Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.badge_outlined),
                      title: Text('NIM'),
                      subtitle: Text(_nim),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.school_outlined),
                      title: Text('Kelas'),
                      subtitle: Text(_className),
                    ),
                  ],
                ),
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
