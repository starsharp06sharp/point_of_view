import 'package:shared_preferences/shared_preferences.dart';

class SecretService {
  static const _kSecret = 'unlock_secret';
  static const String defaultSecret = '0000';

  /// Minimum / maximum length enforced by the settings screen.
  static const int minLength = 4;
  static const int maxLength = 12;

  /// Single-character storage for the calculator's `AC` button. Displayed as
  /// `AC` via [display].
  static const String acChar = 'C';

  /// Characters allowed inside an unlock sequence. Covers every value-bearing
  /// calculator key: digits, the four binary ops, equals, percent, sign,
  /// decimal point, and AC (encoded as a single `C`).
  static const String alphabet = '0123456789+-×÷%=±.$acChar';

  static bool isAllowed(String key) =>
      key.length == 1 && alphabet.contains(key);

  static bool isValid(String secret) =>
      secret.runes.every((r) => alphabet.contains(String.fromCharCode(r)));

  /// Render a stored secret using the calculator button labels (replaces the
  /// single `C` storage character with the familiar `AC`).
  static String display(String secret) => secret.replaceAll(acChar, 'AC');

  static Future<String> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSecret) ?? defaultSecret;
  }

  static Future<void> write(String secret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSecret, secret);
  }
}
