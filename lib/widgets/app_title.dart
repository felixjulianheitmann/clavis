import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.fontSize = 32.0, this.withIcon = false});

  final double fontSize;
  final bool withIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: withIcon,
          child: Image.asset('assets/Key-Logo_Diagonal.png', scale: 0.8),
        ),
        Text(
          AppLocalizations.of(context)!.app_title,
          style: TextStyle(fontFamily: 'Jersey10', fontSize: fontSize),
        ),
      ],
    );
  }
}
