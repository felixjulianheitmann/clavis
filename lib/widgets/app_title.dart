import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.fontSize = 32.0});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.app_title,
      style: TextStyle(fontFamily: 'Jersey10', fontSize: fontSize),
    );
  }
}
