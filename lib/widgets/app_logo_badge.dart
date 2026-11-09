import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Lencana logo bulat putih (reusable widget #8) berisi logo ResepKu.
///
/// Dipakai di splash dan layar pengisian profil.
class AppLogoBadge extends StatelessWidget {
  final double size;

  const AppLogoBadge({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo_mark.png',
        fit: BoxFit.contain,
        // Cadangan bila aset belum terdaftar atau gagal dimuat.
        errorBuilder: (_, _, _) => Icon(
          Icons.restaurant_menu,
          size: size * 0.5,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
