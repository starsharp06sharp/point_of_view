import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether dot-prefixed files and folders are visible in the file
/// browser and gallery. Defaults to `true` (show) so existing users see the
/// same content after upgrade.
class HiddenFilesService {
  static const _kShowHidden = 'show_hidden';

  static final ValueNotifier<bool> show = ValueNotifier<bool>(true);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    show.value = prefs.getBool(_kShowHidden) ?? true;
  }

  static Future<void> setShow(bool value) async {
    if (show.value == value) return;
    show.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowHidden, value);
  }
}
