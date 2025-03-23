import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gamevault_web/startup.dart';
import 'package:gamevault_web/widgets/drawer.dart';
import 'package:gamevault_web/widgets/games/page.dart';

class GamevaultHome extends StatelessWidget {
  const GamevaultHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FutureBuilder(
          future: context.read<AuthBloc>().initialize(),
          builder: (context, snapshot) {
            Widget body = Center(child: SpinKitCircle(color: Colors.blue));
            if (snapshot.hasError) {
              // error at logging in
              body = StartupPage();
            } else if (snapshot.hasData) {
              if (state.api == null) {
                context.read<AuthBloc>().add(
                  AuthChangedEvent(state: snapshot.data!),
                );
              }
              // logged in
              body = GamesPage();
            } 

            return Scaffold(
              appBar:
                  snapshot.hasData
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
