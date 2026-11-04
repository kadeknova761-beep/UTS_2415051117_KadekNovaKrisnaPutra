/// Aturan validasi input form. Fungsi murni agar mudah dites.
/// Mengembalikan pesan error, atau null bila input valid.
class Validators {
  Validators._();

  static const int maxNoteLength = 200;
  static const int minRating = 1;
  static const int maxRating = 5;

  /// Catatan boleh kosong, tetapi tidak boleh lebih dari [maxNoteLength].
  static String? note(String? value) {
    if ((value ?? '').trim().length > maxNoteLength) {
      return 'Catatan maksimal $maxNoteLength karakter.';
    }
    return null;
  }

  /// Rating wajib dipilih dan harus 1 sampai 5.
  static String? rating(int? value) {
    if (value == null) return 'Pilih rating 1 sampai 5.';
    if (value < minRating || value > maxRating) {
      return 'Rating harus 1 sampai 5.';
    }
    return null;
  }
}
