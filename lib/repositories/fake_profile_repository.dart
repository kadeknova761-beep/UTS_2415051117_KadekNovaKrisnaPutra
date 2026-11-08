import '../core/exceptions.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

/// Profil in-memory untuk tes dan pengembangan tanpa penyimpanan nyata.
class FakeProfileRepository implements ProfileRepository {
  /// Profil contoh, dipakai tes agar aplikasi langsung masuk ke Beranda.
  static const UserProfile sample = UserProfile(
    name: 'Kadek Nova Krisna Putra',
    nim: '2415051117',
    className: 'PTI 5C',
  );

  final bool shouldFail;
  UserProfile? _profile;

  FakeProfileRepository({UserProfile? initial, this.shouldFail = false})
    : _profile = initial;

  void _failIfNeeded() {
    if (shouldFail) {
      throw const AppException('Gagal mengakses data profil (simulasi).');
    }
  }

  @override
  Future<UserProfile?> getProfile() async {
    _failIfNeeded();
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _failIfNeeded();
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    _failIfNeeded();
    _profile = null;
  }
}
