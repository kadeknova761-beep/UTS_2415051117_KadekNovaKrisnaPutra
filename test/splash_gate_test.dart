import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/user_profile.dart';
import 'package:resepku/providers/profile_provider.dart';
import 'package:resepku/repositories/profile_repository.dart';
import 'package:resepku/screens/profile_gate.dart';
import 'package:resepku/screens/profile_setup_screen.dart';
import 'package:resepku/screens/splash_screen.dart';

/// Repository yang selesainya dikendalikan tes.
class _ControlledProfileRepository implements ProfileRepository {
  final Completer<UserProfile?> completer = Completer<UserProfile?>();

  @override
  Future<UserProfile?> getProfile() => completer.future;

  @override
  Future<void> saveProfile(UserProfile profile) async {}

  @override
  Future<void> clearProfile() async {}
}

void main() {
  testWidgets('splash tampil sampai profil selesai dibaca', (tester) async {
    final repository = _ControlledProfileRepository();
    final provider = ProfileProvider(repository)..load();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>.value(
        value: provider,
        child: const MaterialApp(home: ProfileGate()),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('ResepKu'), findsOneWidget);

    repository.completer.complete(null);
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
  });

  testWidgets('splash tidak overflow di layar kecil', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Katalog resep dengan koleksi pribadi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
