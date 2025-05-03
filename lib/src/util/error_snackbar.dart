import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SnackBar errorSnack(BuildContext context, ClavisError err) {
  final translate = AppLocalizations.of(context)!;
  void toClipboard() async {
    await Clipboard.setData(ClipboardData(text: err.err.toString()));
  }
  
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.error,
    action: SnackBarAction(
      label: translate.action_copy,
      onPressed: toClipboard,
    ),
    duration: Duration(minutes: 3),
    showCloseIcon: true,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
    content: ExpansionTile(
      title: Text(err.code.localize(translate), style: TextStyle(fontSize: 24)),
      backgroundColor: Theme.of(context).colorScheme.error,
      collapsedBackgroundColor: Theme.of(context).colorScheme.error,
      collapsedTextColor: Theme.of(context).colorScheme.onError,
      textColor: Theme.of(context).colorScheme.onError,
      dense: true,
      iconColor: Theme.of(context).colorScheme.onError,
      leading: Icon(Icons.info),
      showTrailingIcon: false,
      collapsedIconColor: Theme.of(context).colorScheme.onError,
      children: [Text(err.err.toString())],
    ),
  );
}
