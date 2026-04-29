import 'package:shared_preferences/shared_preferences.dart';

import '../models/sort_option.dart';

class PrefsService {
  static const _kSort = 'sort_option';
  static const _kLastFolder = 'last_folder';
  static const _kLastBrowsedDir = 'last_browsed_dir';

  static Future<SortOption> readSort() async {
    final prefs = await SharedPreferences.getInstance();
    return SortOption.decode(prefs.getString(_kSort));
  }

  static Future<void> writeSort(SortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSort, option.encode());
  }

  /// Path of the folder the user last opened in the gallery view.
  static Future<String?> readLastFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastFolder);
  }

  static Future<void> writeLastFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastFolder, path);
  }

  /// Path the user was browsing inside the folder picker (for restore on next
  /// launch).
  static Future<String?> readLastBrowsedDir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastBrowsedDir);
  }

  static Future<void> writeLastBrowsedDir(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastBrowsedDir, path);
  }
}
