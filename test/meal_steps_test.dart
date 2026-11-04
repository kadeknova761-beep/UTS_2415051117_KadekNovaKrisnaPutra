import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/models/meal.dart';

Meal _mealWith(String? instructions) {
  return Meal(
    id: '1',
    name: 'Tes',
    thumbnailUrl: '',
    instructions: instructions,
  );
}

void main() {
  group('Meal.steps', () {
    test('membuang nomor di awal baris', () {
      final meal = _mealWith(
        '1. Panaskan minyak.\r\n2) Tumis bawang.\nStep 3. Sajikan.',
      );

      expect(meal.steps, ['Panaskan minyak.', 'Tumis bawang.', 'Sajikan.']);
    });

    test('membuang baris yang hanya berisi nomor', () {
      final meal = _mealWith('STEP 1\nPanaskan minyak.\nSTEP 2\nSajikan.');

      expect(meal.steps, ['Panaskan minyak.', 'Sajikan.']);
    });

    test('tidak memotong angka yang menjadi bagian kalimat', () {
      final meal = _mealWith(
        '2 sendok makan gula.\n'
        'Panaskan oven 180 derajat.\n'
        'Tambahkan 1.5 cangkir air.',
      );

      expect(meal.steps, [
        '2 sendok makan gula.',
        'Panaskan oven 180 derajat.',
        'Tambahkan 1.5 cangkir air.',
      ]);
    });

    test('tanpa instruksi menghasilkan daftar kosong', () {
      final meal = _mealWith(null);

      expect(meal.steps, isEmpty);
      expect(meal.hasDetail, isFalse);
    });
  });
}
