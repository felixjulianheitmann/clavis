
import 'package:clavis/l10n/app_localizations.dart';
import 'package:flutter_email_validator/email_validator.dart';

abstract class FormValidators {

static String? Function(String?) nonNullEmpty(AppLocalizations translate) {
  return (String? text) {
    if (text == null || text.isEmpty) {
      return translate.validation_error_field_empty;
    }
    return null;
  };
}

static const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

static String? Function(String?) alphabetOnly (AppLocalizations translate) {
  return (String? text) {
  final containsIllegalChars = text!.runes.any((c) {
      return !alphabet.contains(String.fromCharCode(c));
    });
    if (containsIllegalChars) return translate.validation_invalid_name;

    return null;
  };
}

static String? Function(String?) nonNullEmptyAlphabet (AppLocalizations translate) {
  return (String? text) {
    final emptyErr = nonNullEmpty(translate)(text);
    if (emptyErr != null) return emptyErr;

    return alphabetOnly(translate)(text);
  };
}

static String? Function(String?) nonNullEmptyMail(AppLocalizations translate) {
  return (String? text) {
    final emptyErr = nonNullEmpty(translate)(text);
    if (emptyErr != null) return emptyErr;

    if (!EmailValidator.validate(text!)) {
      return translate.validation_invalid_mail;
    }
    return null;
  };
}}