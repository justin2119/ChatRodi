import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user's selected appearance mode for the current app session.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void setThemeMode(ThemeMode mode) => state = mode;
}

/// Settings for model and generation controls, kept in Riverpod app state.
final defaultModelProvider = StateProvider<String>((ref) => 'Auto');
final temperatureProvider = StateProvider<double>((ref) => 0.7);
