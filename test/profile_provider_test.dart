import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/load_status.dart';
import 'package:resepku/models/user_profile.dart';
import 'package:resepku/providers/profile_provider.dart';
import 'package:resepku/repositories/fake_profile_repository.dart';

void main() {
  const profile = UserProfile(
    name: 'Budi Santoso',
    nim: '2415051117',
    className: 'PTI 5C',
  );

  group('UserProfile.initials', () {
    test('mengambil huruf pertama dari dua kata pertama', () {
      expect(
        const UserProfile(name: 'Kadek Nova Krisna Putra', nim: '1').initials,
        'KN',
      );
      expect(const UserProfile(name: 'budi', nim: '1').initials, 'B');
      expect(const UserProfile(name: '   ', nim: '1').initials, '?');
    });
  });

  group('ProfileProvider', () {
    test('load tanpa profil menghasilkan status empty', () async {
      final provider = ProfileProvider(FakeProfileRepository());

      await provider.load();

      expect(provider.status, LoadStatus.empty);
      expect(provider.profile, isNull);
    });

    test('load dengan profil tersimpan menghasilkan status success', () async {
      final provider = ProfileProvider(FakeProfileRepository(initial: profile));

      await provider.load();

      expect(provider.status, LoadStatus.success);
      expect(provider.profile?.name, 'Budi Santoso');
    });

    test('load gagal menghasilkan status error beserta pesannya', () async {
      final provider = ProfileProvider(FakeProfileRepository(shouldFail: true));

      await provider.load();

      expect(provider.status, LoadStatus.error);
      expect(provider.error, isNotNull);
    });

    test('save menyimpan profil dan mengubah status ke success', () async {
      final provider = ProfileProvider(FakeProfileRepository());
      await provider.load();

      final error = await provider.save(profile);

      expect(error, isNull);
      expect(provider.status, LoadStatus.success);
      expect(provider.profile?.nim, '2415051117');
    });

    test('save gagal mengembalikan pesan dan tidak mengubah status', () async {
      final provider = ProfileProvider(FakeProfileRepository(shouldFail: true));

      final error = await provider.save(profile);

      expect(error, isNotNull);
      expect(provider.status, LoadStatus.initial);
      expect(provider.profile, isNull);
    });

    test('clear menghapus profil dan kembali ke status empty', () async {
      final provider = ProfileProvider(FakeProfileRepository(initial: profile));
      await provider.load();

      final error = await provider.clear();

      expect(error, isNull);
      expect(provider.status, LoadStatus.empty);
      expect(provider.profile, isNull);
    });
  });
}
