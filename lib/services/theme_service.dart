import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen [ThemeMode] and exposes it as a [ValueNotifier]
/// so the root [MaterialApp] can rebuild whenever it changes.
class ThemeService {
  static const _kMode = 'theme_mode';

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Read the persisted value (called once during app startup).
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    mode.value = _decode(prefs.getString(_kMode));
  }

  static Future<void> setMode(ThemeMode m) async {
    mode.value = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, _encode(m));
  }

  static String _encode(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  static ThemeMode _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String label(ThemeMode m) => switch (m) {
        ThemeMode.light => '明亮',
        ThemeMode.dark => '暗黑',
        ThemeMode.system => '跟随系统',
      };
}
