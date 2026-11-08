import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/models/user_profile.dart';
import 'package:resepku/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('read tanpa data mengembalikan null', () async {
    expect(await ProfileService().read(), isNull);
  });

  test('write lalu read mengembalikan profil yang sama', () async {
    final service = ProfileService();

    await service.write(
      const UserProfile(
        name: 'Budi Santoso',
        nim: '2415051117',
        className: 'PTI 5C',
      ),
    );
    final result = await service.read();

    expect(result?.name, 'Budi Santoso');
    expect(result?.nim, '2415051117');
    expect(result?.className, 'PTI 5C');
  });

  test('clear menghapus profil', () async {
    final service = ProfileService();
    await service.write(
      const UserProfile(name: 'Budi Santoso', nim: '2415051117'),
    );

    await service.clear();

    expect(await service.read(), isNull);
  });
}
