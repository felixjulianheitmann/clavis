import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return Center(
      child: 
      Column(children: [
        TextField(decoration: InputDecoration(labelText: translate.hostname_label),),
        TextField(decoration: InputDecoration(labelText: translate.username_label),),
        TextField(decoration: InputDecoration(labelText: translate.password_label),obscureText: true),
      ],)
    );
  }
}