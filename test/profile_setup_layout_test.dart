import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/user_profile.dart';
import 'package:resepku/providers/profile_provider.dart';
import 'package:resepku/repositories/fake_profile_repository.dart';
import 'package:resepku/screens/profile_setup_screen.dart';

Future<void> _pumpSetup(
  WidgetTester tester,
  Size size, {
  UserProfile? initial,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ProfileProvider(FakeProfileRepository()),
      child: MaterialApp(home: ProfileSetupScreen(initial: initial)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(320, 480), Size(400, 900), Size(1200, 800)]) {
    testWidgets('layar sambutan tanpa overflow di ukuran $size', (
      tester,
    ) async {
      await _pumpSetup(tester, size);

      expect(find.text('Selamat datang di ResepKu'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mode ubah profil memakai AppBar dan tombol Simpan', (
    tester,
  ) async {
    await _pumpSetup(
      tester,
      const Size(400, 900),
      initial: FakeProfileRepository.sample,
    );

    expect(find.text('Ubah profil'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.text('Selamat datang di ResepKu'), findsNothing);
    expect(find.text('Kadek Nova Krisna Putra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
