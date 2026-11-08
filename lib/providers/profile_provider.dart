import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/load_status.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';

/// State profil pengguna.
///
/// Arti status: loading = sedang membaca, success = profil ada,
/// empty = profil belum diisi, error = gagal membaca.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  LoadStatus _status = LoadStatus.initial;
  UserProfile? _profile;
  String? _error;
  bool _disposed = false;

  LoadStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _notify();

    try {
      final profile = await _repository.getProfile();
      _profile = profile;
      _status = profile == null ? LoadStatus.empty : LoadStatus.success;
    } on Exception catch (error) {
      _error = _messageOf(error);
      _status = LoadStatus.error;
    }
    _notify();
  }

  /// Menyimpan profil. Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> save(UserProfile profile) async {
    try {
      await _repository.saveProfile(profile);
      _profile = profile;
      _status = LoadStatus.success;
      _error = null;
      _notify();
      return null;
    } on Exception catch (error) {
      return _messageOf(error);
    }
  }

  /// Menghapus profil lokal. Mengembalikan pesan error, atau null.
  Future<String?> clear() async {
    try {
      await _repository.clearProfile();
      _profile = null;
      _status = LoadStatus.empty;
      _error = null;
      _notify();
      return null;
    } on Exception catch (error) {
      return _messageOf(error);
    }
  }

  String _messageOf(Exception error) {
    if (error is AppException) return error.message;
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
