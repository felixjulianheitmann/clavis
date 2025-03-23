import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';
import 'package:gamevault_web/model/credentials.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  static const loginFormWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: loginFormWidth, child: LoginForm()));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _hostEditCtrl = TextEditingController();
  final _userEditCtrl = TextEditingController();
  final _passEditCtrl = TextEditingController();

  String? _fieldValidator(value) {
    final translate = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return translate.validation_error_field_empty;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(labelText: translate.hostname_label),
              controller: _hostEditCtrl,
              validator: _fieldValidator,
              onFieldSubmitted:
                  (value) => context.read<AuthBloc>().add(
                    AuthHostChangedEvent(host: value),
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: _userEditCtrl,
              decoration: InputDecoration(labelText: translate.username_label),
              validator: _fieldValidator,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: 
          TextFormField(
              controller: _passEditCtrl,
              decoration: InputDecoration(labelText: translate.password_label),
              obscureText: true,
              validator: _fieldValidator,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed:
                  () async => context.read<AuthBloc>().add(
                    AuthCredChangedEvent(
                      newCreds: Credentials(
                        user: _userEditCtrl.text,
                        pass: _passEditCtrl.text,
                      ),
                    ),
                  ),
              child: Text(translate.action_login),
            ),
          ),
        ],
      )
    );
  }
}