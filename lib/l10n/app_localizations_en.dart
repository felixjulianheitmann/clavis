// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'clavis';

  @override
  String get games_title => 'Games';

  @override
  String get users_title => 'Users';

  @override
  String get settings_title => 'Settings';

  @override
  String get username_label => 'Username';

  @override
  String get password_label => 'Password';

  @override
  String get hostname_label => 'Hostname';

  @override
  String get validation_error_field_empty => 'Field must not be empty';

  @override
  String get action_login => 'Login';

  @override
  String size_bytes(Object size) {
    return '$size B';
  }

  @override
  String size_kilobytes(Object size) {
    return '$size kB';
  }

  @override
  String size_megabytes(Object size) {
    return '$size MB';
  }

  @override
  String size_gigabytes(Object size) {
    return '$size GB';
  }

  @override
  String size_terabytes(Object size) {
    return '$size TB';
  }

  @override
  String get settings_app_title => 'Application';

  @override
  String get settings_gamevault_title => 'Gamevault';

  @override
  String get settings_autolaunch_title => 'Launch clavis on boot';

  @override
  String get settings_autolaunch_subtitle => 'Not yet useful - why would you autostart this?';

  @override
  String get settings_theme_select_title => 'Select Theme';

  @override
  String get settings_theme_select_subtitle => 'Light, dark or OLED mode';

  @override
  String get settings_theme_tooltip_system => 'System';

  @override
  String get settings_theme_tooltip_light => 'Light';

  @override
  String get settings_theme_tooltip_dark => 'Dark';

  @override
  String get settings_download_dir_title => 'Download Directory';

  @override
  String get settings_download_dir_not_selected => 'No download directory selected, yet';

  @override
  String get settings_download_dir_select_title => 'Select download directory';

  @override
  String get action_close => 'Close';

  @override
  String get action_dismiss => 'Dismiss';

  @override
  String get users_no_users_available => 'No users available';

  @override
  String get users_unknown_role => 'Unknown Role';

  @override
  String get drawer_admin_area => 'Admin Area';
}
