import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get appTitle;

  /// No description provided for @calcError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get calcError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get sectionTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @sectionFileBrowser.
  ///
  /// In en, this message translates to:
  /// **'File browser'**
  String get sectionFileBrowser;

  /// No description provided for @showHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files / folders'**
  String get showHiddenTitle;

  /// No description provided for @showHiddenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items starting with \".\", e.g. .thumbnails'**
  String get showHiddenSubtitle;

  /// No description provided for @sectionUnlockSequence.
  ///
  /// In en, this message translates to:
  /// **'Unlock sequence'**
  String get sectionUnlockSequence;

  /// No description provided for @currentSequence.
  ///
  /// In en, this message translates to:
  /// **'Current: {sequence}'**
  String currentSequence(String sequence);

  /// No description provided for @draftPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Use the keypad below'**
  String get draftPlaceholder;

  /// No description provided for @clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @saveSequence.
  ///
  /// In en, this message translates to:
  /// **'Save sequence'**
  String get saveSequence;

  /// No description provided for @sequenceSaved.
  ///
  /// In en, this message translates to:
  /// **'Unlock sequence saved'**
  String get sequenceSaved;

  /// No description provided for @sequenceLengthError.
  ///
  /// In en, this message translates to:
  /// **'Length must be between {min} and {max}'**
  String sequenceLengthError(int min, int max);

  /// No description provided for @sequenceCharsError.
  ///
  /// In en, this message translates to:
  /// **'Only 0-9 / + - × ÷ % = ± . AC are allowed'**
  String get sequenceCharsError;

  /// No description provided for @sequenceHelp.
  ///
  /// In en, this message translates to:
  /// **'Allowed characters: 0-9 + - × ÷ % = ± . AC. Press the same key sequence on the calculator to unlock silently; matching is windowed, so the sequence can be hidden at the end of a longer expression.'**
  String get sequenceHelp;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required'**
  String get permissionTitle;

  /// No description provided for @permissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'To browse images inside hidden folders (including directories starting with .), this app needs the \"All files access\" permission.'**
  String get permissionExplanation;

  /// No description provided for @permissionGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get permissionGrant;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get permissionOpenSettings;

  /// No description provided for @permissionHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: on Android 11+, the system opens the \"All files access\" list. Find \"Calculator\" and toggle it on, then return to this app.'**
  String get permissionHint;

  /// No description provided for @folderPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get folderPickerTitle;

  /// No description provided for @folderPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{folders} folders · {images} images · {sortLabel}'**
  String folderPickerSubtitle(int folders, int images, String sortLabel);

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortTooltip;

  /// No description provided for @homeStorageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go to primary storage'**
  String get homeStorageTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @immersivePreview.
  ///
  /// In en, this message translates to:
  /// **'Immersive preview'**
  String get immersivePreview;

  /// No description provided for @noAccessibleContent.
  ///
  /// In en, this message translates to:
  /// **'No accessible content here.\nPlease check that \"All files access\" permission is granted.'**
  String get noAccessibleContent;

  /// No description provided for @emptyHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get emptyHere;

  /// No description provided for @parentFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go up one level'**
  String get parentFolderSubtitle;

  /// No description provided for @gallerySubtitleNoZoom.
  ///
  /// In en, this message translates to:
  /// **'{images} images · {sortLabel}'**
  String gallerySubtitleNoZoom(int images, String sortLabel);

  /// No description provided for @gallerySubtitleZoom.
  ///
  /// In en, this message translates to:
  /// **'{images} images · {sortLabel} · {columns} columns'**
  String gallerySubtitleZoom(int images, String sortLabel, int columns);

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No recognizable images in this folder.\n(Supported: jpg/jpeg/png/gif/webp/bmp/heic/heif)'**
  String get noImages;

  /// No description provided for @sortMenuNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name ascending (A→Z)'**
  String get sortMenuNameAsc;

  /// No description provided for @sortMenuNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name descending (Z→A)'**
  String get sortMenuNameDesc;

  /// No description provided for @sortMenuModifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Modified descending (new→old)'**
  String get sortMenuModifiedDesc;

  /// No description provided for @sortMenuModifiedAsc.
  ///
  /// In en, this message translates to:
  /// **'Modified ascending (old→new)'**
  String get sortMenuModifiedAsc;

  /// No description provided for @sortLabelNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name · Asc'**
  String get sortLabelNameAsc;

  /// No description provided for @sortLabelNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name · Desc'**
  String get sortLabelNameDesc;

  /// No description provided for @sortLabelModifiedAsc.
  ///
  /// In en, this message translates to:
  /// **'Modified · Asc'**
  String get sortLabelModifiedAsc;

  /// No description provided for @sortLabelModifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Modified · Desc'**
  String get sortLabelModifiedDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'HK':
            return AppLocalizationsZhHk();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
