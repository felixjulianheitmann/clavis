
import 'package:clavis/l10n/app_localizations.dart';
import 'package:gamevault_client_sdk/api.dart';

typedef GamevaultGames = List<GamevaultGame>;

abstract class ClavisErrCode {
  String localize(AppLocalizations translate);
}
