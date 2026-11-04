/// Status pemuatan data yang dipakai provider dan screen.
enum LoadStatus {
  /// Belum pernah dimuat.
  initial,

  /// Sedang memuat.
  loading,

  /// Berhasil dan ada data.
  success,

  /// Berhasil, tetapi datanya kosong.
  empty,

  /// Gagal memuat.
  error,
}
