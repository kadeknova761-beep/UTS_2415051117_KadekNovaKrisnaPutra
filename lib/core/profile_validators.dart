/// Aturan validasi untuk form profil. Mengembalikan pesan error,
/// atau null jika isian valid.
class ProfileValidators {
  ProfileValidators._();

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama wajib diisi.';
    if (text.length < 3) return 'Nama minimal 3 karakter.';
    if (text.length > 50) return 'Nama maksimal 50 karakter.';
    return null;
  }

  static String? nim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi.';
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return 'NIM hanya boleh berisi angka.';
    }
    if (text.length < 6 || text.length > 20) {
      return 'NIM harus 6 sampai 20 digit.';
    }
    return null;
  }

  /// Kelas opsional, hanya dibatasi panjangnya.
  static String? className(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 20) return 'Kelas maksimal 20 karakter.';
    return null;
  }
}
