import 'package:flutter/material.dart';

/// Palette officielle de RodiumAi, centralisée pour conserver une identité
/// visuelle cohérente et faciliter toute évolution ultérieure des couleurs.
abstract final class AppColors {
  /// Émeraude RodiumAi (#00C9A7) : couleur d'accent, associée aux actions
  /// principales et aux états positifs sans surcharger l'interface.
  static const Color emerald = Color(0xFF00C9A7);

  /// Ardoise profonde (#0F172A) : fond sombre principal, confortable en faible
  /// luminosité et suffisamment contrasté avec les contenus.
  static const Color deepSlate = Color(0xFF0F172A);
  static const Color background = deepSlate;

  /// Surface (#1E293B) : distinction discrète des cartes et conteneurs sur le
  /// fond profond, sans introduire de couleur concurrente.
  static const Color surface = Color(0xFF1E293B);
  static const Color container = surface;

  /// Texte primaire (#F8FAFC) : contraste élevé pour les contenus essentiels.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Bordure subtile (#334155) : séparateurs visibles mais non dominants.
  static const Color subtleBorder = Color(0xFF334155);
}
