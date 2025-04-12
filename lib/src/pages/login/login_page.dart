import 'package:clavis/src/blocs/login_form_bloc.dart';
import 'package:clavis/src/pages/login/login_form.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:clavis/src/util/app_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Login page that is displayed whenever authentication couldn't be performed
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.errorMessage});

  static const loginFormWidth = 300.0;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (ctx) => LoginFormBloc(
            prefRepo: ctx.read<PrefRepo>(),
            authRepo: ctx.read<AuthRepository>(),
          ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: LoginPanel(
                errorMessage: errorMessage,
                loginFormWidth: loginFormWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Content of the login page
/// Just the logo+title an optional error message card and the login form
class LoginPanel extends StatelessWidget {
  const LoginPanel({
    super.key,
    required this.errorMessage,
    required this.loginFormWidth,
  });

  final String? errorMessage;
  final double loginFormWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTitle(fontSize: 64, withIcon: true),
        Visibility(
          visible: errorMessage != null,
          child: Card(
            surfaceTintColor: Colors.orange,
            child: Text(errorMessage ?? ""),
          ),
        ),
        SizedBox(width: loginFormWidth, child: Card(child: LoginForm())),
      ],
    );
  }
}
