// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Calculator';

  @override
  String get calcError => 'Error';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get sectionFileBrowser => 'File browser';

  @override
  String get showHiddenTitle => 'Show hidden files / folders';

  @override
  String get showHiddenSubtitle =>
      'Items starting with \".\", e.g. .thumbnails';

  @override
  String get sectionUnlockSequence => 'Unlock sequence';

  @override
  String currentSequence(String sequence) {
    return 'Current: $sequence';
  }

  @override
  String get draftPlaceholder => 'Use the keypad below';

  @override
  String get clearTooltip => 'Clear';

  @override
  String get saveSequence => 'Save sequence';

  @override
  String get sequenceSaved => 'Unlock sequence saved';

  @override
  String sequenceLengthError(int min, int max) {
    return 'Length must be between $min and $max';
  }

  @override
  String get sequenceCharsError => 'Only 0-9 / + - × ÷ % = ± . AC are allowed';

  @override
  String get sequenceHelp =>
      'Allowed characters: 0-9 + - × ÷ % = ± . AC. Press the same key sequence on the calculator to unlock silently; matching is windowed, so the sequence can be hidden at the end of a longer expression.';

  @override
  String get permissionTitle => 'Storage permission required';

  @override
  String get permissionExplanation =>
      'To browse images inside hidden folders (including directories starting with .), this app needs the \"All files access\" permission.';

  @override
  String get permissionGrant => 'Grant permission';

  @override
  String get permissionOpenSettings => 'Open system settings';

  @override
  String get permissionHint =>
      'Tip: on Android 11+, the system opens the \"All files access\" list. Find \"Calculator\" and toggle it on, then return to this app.';

  @override
  String get folderPickerTitle => 'Select folder';

  @override
  String folderPickerSubtitle(int folders, int images, String sortLabel) {
    return '$folders folders · $images images · $sortLabel';
  }

  @override
  String get sortTooltip => 'Sort by';

  @override
  String get homeStorageTooltip => 'Go to primary storage';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get immersivePreview => 'Immersive preview';

  @override
  String get noAccessibleContent =>
      'No accessible content here.\nPlease check that \"All files access\" permission is granted.';

  @override
  String get emptyHere => 'Nothing here';

  @override
  String get parentFolderSubtitle => 'Go up one level';

  @override
  String gallerySubtitleNoZoom(int images, String sortLabel) {
    return '$images images · $sortLabel';
  }

  @override
  String gallerySubtitleZoom(int images, String sortLabel, int columns) {
    return '$images images · $sortLabel · $columns columns';
  }

  @override
  String get noImages =>
      'No recognizable images in this folder.\n(Supported: jpg/jpeg/png/gif/webp/bmp/heic/heif)';

  @override
  String get sortMenuNameAsc => 'Name ascending (A→Z)';

  @override
  String get sortMenuNameDesc => 'Name descending (Z→A)';

  @override
  String get sortMenuModifiedDesc => 'Modified descending (new→old)';

  @override
  String get sortMenuModifiedAsc => 'Modified ascending (old→new)';

  @override
  String get sortLabelNameAsc => 'Name · Asc';

  @override
  String get sortLabelNameDesc => 'Name · Desc';

  @override
  String get sortLabelModifiedAsc => 'Modified · Asc';

  @override
  String get sortLabelModifiedDesc => 'Modified · Desc';

  @override
  String get imageInfoTooltip => 'Info';

  @override
  String get imageInfoTitle => 'Image info';

  @override
  String get imageInfoCloseTooltip => 'Close';

  @override
  String get imageInfoLoading => 'Loading…';

  @override
  String get imageInfoUnknown => '—';

  @override
  String get imageInfoPath => 'Path';

  @override
  String get imageInfoType => 'Type';

  @override
  String get imageInfoResolution => 'Resolution';

  @override
  String get imageInfoSize => 'Size';

  @override
  String get imageInfoCreated => 'Created';

  @override
  String get imageInfoModified => 'Modified';

  @override
  String get imageInfoLocation => 'Location';

  @override
  String get imageInfoCamera => 'Camera';

  @override
  String get imageInfoCameraParams => 'Parameters';

  @override
  String imageInfoResolutionValue(int width, int height) {
    return '$width × $height';
  }
}
