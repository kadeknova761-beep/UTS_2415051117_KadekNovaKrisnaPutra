import '../core/exceptions.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'profile_repository.dart';

/// Implementasi profil berbasis penyimpanan lokal perangkat.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service;

  ProfileRepositoryImpl(this._service);

  @override
  Future<UserProfile?> getProfile() => _guard(_service.read);

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _guard(() => _service.write(profile));
  }

  @override
  Future<void> clearProfile() => _guard(_service.clear);

  /// Mengubah error penyimpanan menjadi pesan yang aman ditampilkan.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Exception {
      throw const AppException('Gagal mengakses data profil di perangkat.');
    }
  }
}
