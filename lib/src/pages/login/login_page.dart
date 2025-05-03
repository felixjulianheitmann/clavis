import 'package:clavis/src/blocs/error_bloc.dart';
import 'package:clavis/src/pages/login/login_form.dart';
import 'package:clavis/src/util/app_title.dart';
import 'package:clavis/src/util/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Login page that is displayed whenever authentication couldn't be performed
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const loginFormWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ErrorBloc, ErrorState>(
        listener: (context, state) {
          if (!state.hasError) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(errorSnack(context, state.error!));
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: LoginPanel(
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
    required this.loginFormWidth,
  });

  final double loginFormWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTitle(fontSize: 64, withIcon: true),
        SizedBox(width: loginFormWidth, child: Card(child: LoginForm())),
      ],
    );
  }
}
