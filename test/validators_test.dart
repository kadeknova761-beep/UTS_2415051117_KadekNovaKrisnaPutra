import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/core/validators.dart';

void main() {
  group('Validators.note', () {
    test('kosong dianggap valid', () {
      expect(Validators.note(null), isNull);
      expect(Validators.note('   '), isNull);
    });

    test('tepat 200 karakter valid', () {
      expect(Validators.note('a' * 200), isNull);
    });

    test('lebih dari 200 karakter ditolak', () {
      expect(Validators.note('a' * 201), 'Catatan maksimal 200 karakter.');
    });
  });

  group('Validators.rating', () {
    test('null ditolak', () {
      expect(Validators.rating(null), 'Pilih rating 1 sampai 5.');
    });

    test('1 sampai 5 valid', () {
      for (var i = 1; i <= 5; i++) {
        expect(Validators.rating(i), isNull);
      }
    });

    test('di luar 1 sampai 5 ditolak', () {
      expect(Validators.rating(0), 'Rating harus 1 sampai 5.');
      expect(Validators.rating(6), 'Rating harus 1 sampai 5.');
    });
  });
}
