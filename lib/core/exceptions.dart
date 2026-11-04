/// Error aplikasi dengan pesan yang aman ditampilkan ke pengguna.
///
/// Jenis error yang lebih spesifik (jaringan, API, database) ditambahkan
/// pada tahap error handling.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}
