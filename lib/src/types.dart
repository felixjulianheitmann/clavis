
import 'package:clavis/l10n/app_localizations.dart';
import 'package:gamevault_client_sdk/api.dart';

typedef GamevaultGames = List<GamevaultGame>;

abstract class ClavisErrCode {
  String localize(AppLocalizations translate);
}

class ClavisException implements Exception {
  ClavisException(
    this.msg, {
    required this.prefix,
    this.innerException,
    this.stack,
  });

  final String msg;
  final Object? innerException;
  String prefix;
  StackTrace? stack;

  String get message => "$prefix: $msg";
  String get details => innerException.toString();
  bool get hasDetails => innerException != null;
  bool get hasStack => stack != null;

  @override
  String toString() {
    var text = message;
    if (hasDetails) text += "\n$details";
    if (hasStack) text += "\n\n${stack.toString()}";
    return text;
  }
}
