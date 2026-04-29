import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's locale choice. `null` means "follow the system" — if
/// the system language is one of [supported] (matched by language tag and,
/// when present, country tag) it is used; otherwise [fallback] is shown.
class LocaleService {
  static const _kLocale = 'app_locale';

  /// Locales the app actually ships translations for. Order is significant:
  /// it dictates which Chinese variant Flutter resolves to when only the
  /// language code is known (e.g. system reports just `zh`).
  static const List<Locale> supported = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
  ];

  /// Used when the system locale matches none of [supported].
  static const Locale fallback = Locale('en');

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locale.value = _decode(prefs.getString(_kLocale));
  }

  static Future<void> setLocale(Locale? value) async {
    if (_eq(locale.value, value)) return;
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, _encode(value));
    }
  }

  /// Resolve a `(deviceLocales, supported)` pair to the locale Flutter should
  /// use. For each device locale we try (in order): exact language+country
  /// match, then language-only match (a supported locale with no country
  /// constraint), then any locale sharing the language code. Falls back to
  /// [fallback] instead of `supported.first` when nothing matches.
  static Locale resolve(
    List<Locale>? deviceLocales,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocales == null || deviceLocales.isEmpty) return fallback;
    final supportedList = supportedLocales.toList(growable: false);
    for (final device in deviceLocales) {
      for (final s in supportedList) {
        if (s.languageCode == device.languageCode &&
            s.countryCode == device.countryCode) {
          return s;
        }
      }
      for (final s in supportedList) {
        if (s.languageCode == device.languageCode && s.countryCode == null) {
          return s;
        }
      }
      for (final s in supportedList) {
        if (s.languageCode == device.languageCode) {
          return s;
        }
      }
    }
    return fallback;
  }

  static String _encode(Locale l) =>
      l.countryCode == null ? l.languageCode : '${l.languageCode}_${l.countryCode}';

  static Locale? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (parts.length == 1) return Locale(parts[0]);
    return Locale(parts[0], parts[1]);
  }

  static bool _eq(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
