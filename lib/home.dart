import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gamevault_web/startup.dart';
import 'package:gamevault_web/widgets/drawer.dart';
import 'package:gamevault_web/widgets/games/page.dart';

class GamevaultHome extends StatefulWidget {
  const GamevaultHome({super.key});
  @override
  State<GamevaultHome> createState() => GamevaultHomeState();
}

class GamevaultHomeState extends State<GamevaultHome> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FutureBuilder(
          future: context.read<AuthBloc>().initialize(),
          builder: (context, snapshot) {
            Widget body = Center(child: SpinKitCircle(color: Colors.blue));
            final ready = !snapshot.hasError;
            if (!ready) {
              // error at logging in
              body = StartupPage();
            } else {
              // logged in
              body = GamesPage();
            } 

            return Scaffold(
              appBar:
                  ready
                      ? AppBar(
                        title: Text(AppLocalizations.of(context)!.app_title),
                      )
                      : null,
              drawer: SidebarDrawer(),
              body: body,
            );
          },
        );
      },
    );
  }
}
