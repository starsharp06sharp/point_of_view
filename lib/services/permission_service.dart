import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Returns true if the app currently has full file system access.
  /// On Android 11+ this is `MANAGE_EXTERNAL_STORAGE` (a.k.a. "All files access").
  /// On older devices we fall back to the legacy storage permission.
  static Future<bool> hasFullAccess() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    return false;
  }

  /// Request "All files access" via the system settings page.
  /// Returns the resulting status after the user comes back.
  static Future<PermissionStatus> requestAllFilesAccess() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return status;
    return await Permission.storage.request();
  }

  static Future<bool> openSystemSettings() => openAppSettings();
}
