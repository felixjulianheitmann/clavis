import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:clavis/blocs/download_bloc.dart';
import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/blocs/settings_bloc.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:clavis/widgets/games/page.dart';
import 'package:clavis/widgets/home.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => PageBloc()),
        BlocProvider(create: (_) => DownloadBloc()),
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => SearchBloc()),
      ],
      child: Clavis(),
    ),
  );
}

class Clavis extends StatelessWidget {
  const Clavis({super.key});

  Future<Widget> _initApp(BuildContext context) async {
    await Log.initLog();
    log.i("Starting application");
    final settings = await Preferences.getAppSettings();
    final authState = await AuthBloc.initialize();

    if (context.mounted) {
      log.i("Setting global states");
      context.read<SettingsBloc>().add(
        SettingsChangedEvent(settings: settings),
      );
      log.i(
        "Valid authentication credentials available: ${authState is AuthSuccessState}",
      );
      context.read<AuthBloc>().add(AuthChangedEvent(state: authState));
      if (authState is AuthSuccessState) {
        context.read<DownloadBloc>().add(
          DownloadAuthReceivedEvent(authState.api),
        );
      }
    }

    log.i("initialization finished");
    return ClavisHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((SettingsBloc s) {
      if (s.state is SettingsLoadedState) {
        return (s.state as SettingsLoadedState).settings.theme;
      }
      return ThemeMode.system;
    });

    return MaterialApp(
      title: "clavis",
      theme: FlexThemeData.light(),
      darkTheme: FlexThemeData.dark(),
      themeMode: theme,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('de')],
      home: AnimatedSplashScreen.withScreenFunction(
        splashTransition: SplashTransition.fadeTransition,
        animationDuration: Duration(milliseconds: 500),
        duration: 500,
        splash: 'assets/Key-Logo_Diagonal.png',
        splashIconSize: 5.0,
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? FlexThemeData.light().canvasColor
                : FlexThemeData.dark().canvasColor,
        screenFunction: () => _initApp(context),
      ),
    );
  }
}
