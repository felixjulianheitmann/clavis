import 'package:clavis/src/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:clavis/l10n/app_localizations.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({super.key, required this.error});
  final Object error;

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  @override
  Widget build(BuildContext context) {
    log.e("uncaught error occurred", error: widget.error);

    return Dialog(
      child: Center(child: Column(
        children: [
          Card(child: Text(widget.error.toString())),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.action_dismiss)),
        ],
      ))
    );
  }
}