import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';
import 'package:gamevault_web/home.dart';
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
      home: BlocProvider(
        create: (BuildContext ctx) => AuthBloc(),
        child: const GamevaultHome(),
      ),
    );
  }
}

