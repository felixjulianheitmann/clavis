
import 'package:clavis/l10n/app_localizations.dart';
import 'package:gamevault_client_sdk/api.dart';

typedef GamevaultGames = List<GamevaultGame>;

abstract class ClavisErrCode {
  String localize(AppLocalizations translate);
}

class ClavisException implements Exception {
  ClavisException(this.msg, {this.innerException});

  final String msg;
  final Object? innerException;
  String prefix = "";
  StackTrace stack = StackTrace.current;

  String get message => "$prefix: $msg";
  String get details => innerException.toString();
  bool get hasDetails => innerException != null;
}
