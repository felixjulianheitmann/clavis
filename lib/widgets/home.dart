import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:clavis/widgets/startup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clavis/blocs/auth_bloc.dart';

class ClavisHome extends StatelessWidget {
  const ClavisHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          return ClavisScaffold();
        } else if (state is AuthFailedState) {
          return StartupPage(errorMessage: state.message);
        } else {
          return StartupPage();
        }
      },
    );
  }
}
