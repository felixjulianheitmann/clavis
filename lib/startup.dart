import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';
import 'package:gamevault_web/credential_store.dart';
import 'package:gamevault_web/model/credentials.dart';
import 'package:gamevault_web/preferences.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key, this.errorMessage});

  static const loginFormWidth = 300.0;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    List<Widget> col = [];
    if (errorMessage != null) {
      col.add(
        Card(surfaceTintColor: Colors.orange, child: Text(errorMessage!)),
      );
    }
    col.add(SizedBox(width: loginFormWidth, child: LoginForm()));
    return Center(child: Expanded(child: Column(children: col)));
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

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await Preferences.setHostname(_hostEditCtrl.text);
    final user = _userEditCtrl.text;
    final pass = _passEditCtrl.text;
    final newState = AuthCredChangedEvent(
      newCreds: Credentials(user: user, pass: pass),
    );
    if (context.mounted) {
      context.read<AuthBloc>().add(newState);
    }
  }

  Future<void> _initForm() async {
    final host = await Preferences.getHostname();
    if (host != null) {
      _hostEditCtrl.text = host;
    }
    final creds = await CredentialStore.read();
    if (creds != null) {
      _userEditCtrl.text = creds.user;
      _passEditCtrl.text = creds.pass;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final hostField = TextFormField(
      decoration: InputDecoration(labelText: translate.hostname_label),
      controller: _hostEditCtrl,
      validator: _fieldValidator,
      onFieldSubmitted: (_) => _submit(context),
    );
    final userField = TextFormField(
      controller: _userEditCtrl,
      decoration: InputDecoration(labelText: translate.username_label),
      validator: _fieldValidator,
      onFieldSubmitted: (_) => _submit(context),
    );
    final passField = TextFormField(
      controller: _passEditCtrl,
      decoration: InputDecoration(labelText: translate.password_label),
      obscureText: true,
      validator: _fieldValidator,
      onFieldSubmitted: (_) => _submit(context),
    );

    return FutureBuilder(
      future: _initForm(),
      builder: (ctx, snapshot) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10), child: hostField),
              Padding(padding: EdgeInsets.all(10), child: userField),
              Padding(padding: EdgeInsets.all(10), child: passField),
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  child: Text(translate.action_login),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
