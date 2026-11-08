/// Profil pengguna yang disimpan di perangkat (bukan di database).
class UserProfile {
  final String name;
  final String nim;

  /// Boleh kosong.
  final String className;

  const UserProfile({
    required this.name,
    required this.nim,
    this.className = '',
  });

  /// Inisial untuk avatar: huruf pertama dari dua kata pertama nama.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
