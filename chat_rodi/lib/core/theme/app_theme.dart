import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared light and dark themes for ChatRodi.
abstract final class AppTheme {
  static const _primary = Color(0xFFFF6600);

  static ThemeData get dark => _create(
        brightness: Brightness.dark,
        background: const Color(0xFF0D0D0D),
        surface: const Color(0xFF1A1A1A),
        text: const Color(0xFFFFFFFF),
      );

  static ThemeData get light => _create(
        brightness: Brightness.light,
        background: const Color(0xFFFFFFFF),
        surface: const Color(0xFFF5F5F5),
        text: const Color(0xFF000000),
      );

  static ThemeData _create({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
      primary: _primary,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: text,
    );
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(
        brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(bodyColor: text, displayColor: text),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: text.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }
}
