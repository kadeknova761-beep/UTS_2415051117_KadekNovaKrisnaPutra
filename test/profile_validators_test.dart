import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/profile_validators.dart';

void main() {
  group('ProfileValidators.name', () {
    test('menolak kosong, terlalu pendek, dan terlalu panjang', () {
      expect(ProfileValidators.name(null), isNotNull);
      expect(ProfileValidators.name('   '), isNotNull);
      expect(ProfileValidators.name('Ab'), isNotNull);
      expect(ProfileValidators.name('A' * 51), isNotNull);
    });

    test('menerima nama yang wajar', () {
      expect(ProfileValidators.name('Budi Santoso'), isNull);
    });
  });

  group('ProfileValidators.nim', () {
    test('menolak kosong, bukan angka, dan panjang tidak sesuai', () {
      expect(ProfileValidators.nim(null), isNotNull);
      expect(ProfileValidators.nim(''), isNotNull);
      expect(ProfileValidators.nim('abc123'), isNotNull);
      expect(ProfileValidators.nim('12345'), isNotNull);
      expect(ProfileValidators.nim('1' * 21), isNotNull);
    });

    test('menerima NIM berisi angka dengan panjang wajar', () {
      expect(ProfileValidators.nim('2415051117'), isNull);
    });
  });

  group('ProfileValidators.className', () {
    test('opsional, hanya dibatasi panjangnya', () {
      expect(ProfileValidators.className(null), isNull);
      expect(ProfileValidators.className(''), isNull);
      expect(ProfileValidators.className('PTI 5C'), isNull);
      expect(ProfileValidators.className('A' * 21), isNotNull);
    });
  });
}
