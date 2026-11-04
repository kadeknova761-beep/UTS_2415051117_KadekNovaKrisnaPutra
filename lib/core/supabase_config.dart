import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exceptions.dart';

/// Konfigurasi dan inisialisasi Supabase.
///
/// URL dan kunci dibaca dari file `.env` (tidak di-commit). Hanya kunci
/// publishable/anon yang dipakai; kunci secret (rahasia) tidak
/// boleh ada di aplikasi.
class SupabaseConfig {
  const SupabaseConfig._();

  /// Memuat `.env`, menginisialisasi Supabase, dan masuk sebagai
  /// pengguna anonim bila belum ada sesi.
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.maybeGet('SUPABASE_URL');
    final key = dotenv.maybeGet('SUPABASE_ANON_KEY');
    if (url == null || url.isEmpty || key == null || key.isEmpty) {
      throw const AppException(
        'SUPABASE_URL dan SUPABASE_ANON_KEY belum diisi di file .env.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: key);

    final auth = Supabase.instance.client.auth;
    if (auth.currentSession == null) {
      await auth.signInAnonymously();
    }
  }
}
