import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Thème global de RodiumAi. Les choix sont regroupés ici afin que les écrans
/// héritent des mêmes couleurs, règles de forme et conventions typographiques.
abstract final class AppTheme {
  /// Thème sombre privilégié pour réduire l'éblouissement et mettre en valeur
  /// l'accent émeraude de la marque.
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.emerald,
      onPrimary: AppColors.deepSlate,
      secondary: AppColors.emerald,
      onSecondary: AppColors.deepSlate,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFFF6B6B),
      onError: AppColors.deepSlate,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.subtleBorder,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        // Règle « Style Carré » : aucune bordure arrondie sur l'AppBar.
        // AppBarTheme expose `shape` (et non une propriété `borderRadius`) ;
        // cette forme rectangulaire garantit exactement un rayon nul.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.subtleBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.subtleBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.emerald, width: 1.5),
        ),
      ),
    );
  }
}
