import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Penyimpanan profil di perangkat memakai SharedPreferences.
class ProfileService {
  static const String _nameKey = 'resepku.profile.name';
  static const String _nimKey = 'resepku.profile.nim';
  static const String _classKey = 'resepku.profile.class';

  /// Mengembalikan null jika profil belum pernah disimpan.
  Future<UserProfile?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final nim = prefs.getString(_nimKey);
    if (name == null || nim == null) return null;

    return UserProfile(
      name: name,
      nim: nim,
      className: prefs.getString(_classKey) ?? '',
    );
  }

  Future<void> write(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_nimKey, profile.nim);
    await prefs.setString(_classKey, profile.className);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_nimKey);
    await prefs.remove(_classKey);
  }
}
