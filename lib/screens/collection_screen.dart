import 'package:flutter/material.dart';

import '../widgets/state_view.dart';

/// Koleksi resep tersimpan. Masih placeholder; diisi data dari database
/// pada tahap integrasi Supabase.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Saya')),
      body: const StateView(
        type: StateViewType.empty,
        message: 'Belum ada resep tersimpan.',
      ),
    );
  }
}
