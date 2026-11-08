import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/load_status.dart';
import '../providers/profile_provider.dart';
import '../widgets/state_view.dart';
import 'app_shell.dart';
import 'profile_setup_screen.dart';

/// Penentu layar awal: pengisian profil bila belum ada, aplikasi bila ada.
class ProfileGate extends StatelessWidget {
  const ProfileGate({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const Scaffold(body: StateView(type: StateViewType.loading));
      case LoadStatus.error:
        return Scaffold(
          body: StateView(
            type: StateViewType.error,
            message: provider.error,
            onRetry: provider.load,
          ),
        );
      case LoadStatus.empty:
        return const ProfileSetupScreen();
      case LoadStatus.success:
        return const AppShell();
    }
  }
}
