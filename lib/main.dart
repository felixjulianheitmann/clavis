import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamevault_web/widgets/drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const Gamevault());
}

class Gamevault extends StatelessWidget {
  const Gamevault({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamevault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('de')],
      home: const GamevaultHome(),
    );
  }
}

class GamevaultHome extends StatelessWidget {
  const GamevaultHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.app_title),
      ),
      drawer: SidebarDrawer(),
    );
  }
}
