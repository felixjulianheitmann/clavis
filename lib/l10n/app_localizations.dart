import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// just the title of the app
  ///
  /// In en, this message translates to:
  /// **'clavis'**
  String get app_title;

  /// No description provided for @games_title.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games_title;

  /// No description provided for @users_title.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users_title;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @username_label.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username_label;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @hostname_label.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get hostname_label;

  /// No description provided for @validation_error_field_empty.
  ///
  /// In en, this message translates to:
  /// **'Field must not be empty'**
  String get validation_error_field_empty;

  /// No description provided for @action_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get action_login;

  /// No description provided for @size_bytes.
  ///
  /// In en, this message translates to:
  /// **'{size} B'**
  String size_bytes(Object size);

  /// No description provided for @size_kilobytes.
  ///
  /// In en, this message translates to:
  /// **'{size} kB'**
  String size_kilobytes(Object size);

  /// No description provided for @size_megabytes.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String size_megabytes(Object size);

  /// No description provided for @size_gigabytes.
  ///
  /// In en, this message translates to:
  /// **'{size} GB'**
  String size_gigabytes(Object size);

  /// No description provided for @size_terabytes.
  ///
  /// In en, this message translates to:
  /// **'{size} TB'**
  String size_terabytes(Object size);

  /// No description provided for @settings_app_title.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settings_app_title;

  /// No description provided for @settings_gamevault_title.
  ///
  /// In en, this message translates to:
  /// **'Gamevault'**
  String get settings_gamevault_title;

  /// No description provided for @settings_autolaunch_title.
  ///
  /// In en, this message translates to:
  /// **'Launch clavis on boot'**
  String get settings_autolaunch_title;

  /// No description provided for @settings_autolaunch_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Not yet useful - why would you autostart this?'**
  String get settings_autolaunch_subtitle;

  /// No description provided for @settings_theme_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get settings_theme_select_title;

  /// No description provided for @settings_theme_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, dark or OLED mode'**
  String get settings_theme_select_subtitle;

  /// No description provided for @settings_theme_tooltip_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_tooltip_system;

  /// No description provided for @settings_theme_tooltip_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_tooltip_light;

  /// No description provided for @settings_theme_tooltip_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_tooltip_dark;

  /// No description provided for @settings_download_dir_title.
  ///
  /// In en, this message translates to:
  /// **'Download Directory'**
  String get settings_download_dir_title;

  /// No description provided for @settings_download_dir_not_selected.
  ///
  /// In en, this message translates to:
  /// **'No download directory selected, yet'**
  String get settings_download_dir_not_selected;

  /// No description provided for @settings_download_dir_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select download directory'**
  String get settings_download_dir_select_title;

  /// No description provided for @action_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get action_close;

  /// No description provided for @action_dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get action_dismiss;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
