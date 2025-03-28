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
              body = StartupPage(
                errorMessage: "Unexpected error: ${snapshot.error!.toString()}",
              );
            } else if (snapshot.hasData) {
              if (snapshot.data! is AuthSuccessfulState) {
                context.read<AuthBloc>().add(
                  AuthChangedEvent(state: snapshot.data!),
                );
                body = GamesPage();
              } else if (state is AuthFailedState) {
                body = StartupPage(errorMessage: state.message);
              }
              // logged in
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
