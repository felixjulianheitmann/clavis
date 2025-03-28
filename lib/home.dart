import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:clavis/app_page_switcher.dart';
import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/startup.dart';

class ClavisHome extends StatelessWidget {
  const ClavisHome({super.key});

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
                body = AppPageSwitcher();
              } else if (state is AuthFailedState) {
                body = StartupPage(errorMessage: state.message);
              }
              // logged in
            }

            return body;
          },
        );
      },
    );
  }
}
