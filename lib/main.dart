import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:clavis/blocs/download_bloc.dart';
import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/blocs/search_bloc.dart';
import 'package:clavis/blocs/settings_bloc.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/user_me_bloc.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:clavis/widgets/home.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clavis/l10n/app_localizations.dart';

void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(),
          dispose: (repo) => repo.dispose(),
        ),
        RepositoryProvider(create: (_) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (ctx) =>
                    AuthBloc(ctx.read<AuthRepository>())
                      ..add(AuthSubscriptionRequested()),
          ),
          BlocProvider(create: (_) => PageBloc()),
          BlocProvider(create: (_) => SettingsBloc()),
          BlocProvider(create: (_) => SearchBloc()),
          BlocProvider(create: (_) => ErrorBloc()),
          BlocProvider(create: (_) => DownloadBloc()),
          BlocProvider(
            create:
                (ctx) =>
                    UserMeBloc(ctx.read<UserRepository>(), ctx.read<AuthRepository>())
                      ..add(UserMeSubscribe()),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
          ],
          child: Clavis(),
        ),
      ),
    ),
  );
}

class Clavis extends StatelessWidget {
  const Clavis({super.key});

  Future<Widget> _initApp(BuildContext context) async {
    await Log.initLog();
    log.i("Starting application");

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
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? FlexThemeData.light().canvasColor
                : FlexThemeData.dark().canvasColor,
        screenFunction: () => _initApp(context),
      ),
    );
  }
}
