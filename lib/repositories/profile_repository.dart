import '../models/user_profile.dart';

/// Kontrak sumber data profil pengguna.
abstract class ProfileRepository {
  /// Null jika profil belum diisi.
  Future<UserProfile?> getProfile();

  Future<void> saveProfile(UserProfile profile);

  Future<void> clearProfile();
}
