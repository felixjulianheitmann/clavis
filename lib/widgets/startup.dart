import 'package:clavis/util/credential_store.dart';
import 'package:clavis/util/preferences.dart';
import 'package:clavis/widgets/app_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/model/credentials.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key, this.errorMessage});

  static const loginFormWidth = 300.0;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTitle(fontSize: 64, withIcon: true),
              errorMessage != null
                  ? Card(
                    surfaceTintColor: Colors.orange,
                    child: Text(errorMessage!),
                  )
                  : Container(),
              SizedBox(width: loginFormWidth, child: Card(child: LoginForm())),
            ],
          ),
        ),
      ),
    );
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
    final newEvent = AuthCredChangedEvent(
      newCreds: Credentials(user: user, pass: pass),
    );
    if (context.mounted) {
      context.read<AuthBloc>().add(newEvent);
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
