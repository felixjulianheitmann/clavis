import 'package:clavis/blocs/page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => PageBloc()),
      ],
      child: Clavis(),
    ),
  );
}

class Clavis extends StatelessWidget {
  const Clavis({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "clavis",
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
      home: const ClavisHome(),
    );
  }
}
