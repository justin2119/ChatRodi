import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the user's selected appearance mode and persists it across app launches.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(ThemeMode.dark) {
    unawaited(_loadSavedThemeMode());
  }

  static const _storageKey = 'theme_mode';
  final FlutterSecureStorage _storage;
  int _changeCount = 0;

  Future<void> _loadSavedThemeMode() async {
    try {
      final savedMode = await _storage.read(key: _storageKey);
      // Do not replace a user selection made while storage was being read.
      if (_changeCount == 0 && mounted && savedMode != null) {
        state = _decodeThemeMode(savedMode);
      }
    } catch (_) {
      // Keep the default mode if secure storage is unavailable.
    }
  }

  void setThemeMode(ThemeMode mode) {
    _changeCount++;
    state = mode;
    unawaited(_persistThemeMode(mode));
  }

  Future<void> _persistThemeMode(ThemeMode mode) async {
    try {
      await _storage.write(key: _storageKey, value: mode.name);
    } catch (_) {
      // A storage failure should not prevent changing the in-memory theme.
    }
  }

  ThemeMode _decodeThemeMode(String value) {
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}

/// Settings for model and generation controls, kept in Riverpod app state.
final defaultModelProvider = StateProvider<String>((ref) => 'claude-3-5-sonnet');
final temperatureProvider = StateProvider<double>((ref) => 0.7);
