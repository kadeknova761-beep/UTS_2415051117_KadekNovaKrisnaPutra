import 'package:flutter/material.dart';

/// Tema aplikasi ResepKu: merah marun dengan aksen kuning-emas.
/// Dark mode ditambahkan pada tahap berikutnya.
class AppTheme {
  AppTheme._();

  // Palet warna.
  static const Color primary = Color(0xFF9B0A12);
  static const Color primaryDark = Color(0xFF6F060C);
  static const Color accent = Color(0xFFFFB41F);
  static const Color background = Color(0xFFFAF7F5);
  static const Color surfaceMuted = Color(0xFFF1EDEC);
  static const Color ink = Color(0xFF1E1A1A);
  static const Color inkSoft = Color(0xFF6B6361);

  static const String fontFamily = 'Poppins';

  static const TextTheme _textTheme = TextTheme(
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: inkSoft,
    ),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  static OutlineInputBorder _inputBorder(BorderSide side) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: side,
    );
  }

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFDAD6),
          onPrimaryContainer: primaryDark,
          secondary: accent,
          onSecondary: ink,
          secondaryContainer: const Color(0xFFFFE7B0),
          onSecondaryContainer: const Color(0xFF3A2800),
          surface: Colors.white,
          onSurface: ink,
          onSurfaceVariant: inkSoft,
          surfaceContainerHighest: surfaceMuted,
          outline: const Color(0xFF9C9391),
          outlineVariant: const Color(0xFFE4DEDC),
          error: const Color(0xFFBA1A1A),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: _textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: const Color(0x26000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: inkSoft),
        prefixIconColor: primary,
        border: _inputBorder(BorderSide.none),
        enabledBorder: _inputBorder(BorderSide.none),
        focusedBorder: _inputBorder(
          const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: _inputBorder(
          const BorderSide(color: Color(0xFFBA1A1A), width: 1.2),
        ),
        focusedErrorBorder: _inputBorder(
          const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          side: const BorderSide(color: primary, width: 1.4),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primary,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : ink,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE4DEDC),
        space: 1,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(iconColor: primary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: primary,
        elevation: 0,
        indicatorColor: Colors.white.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(
          color: Colors.white.withValues(alpha: 0.72),
        ),
        selectedLabelTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}
