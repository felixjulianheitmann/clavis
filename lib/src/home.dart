import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClavisHome extends StatelessWidget {
  const ClavisHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Unauthenticated) {
          return LoginPage(errorMessage: state.message);
        } else {
          return ClavisScaffold();
        }
      },
    );
  }
}
