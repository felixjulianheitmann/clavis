import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/login_form_bloc.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final host = _hostEditCtrl.text;
    final user = _userEditCtrl.text;
    final pass = _passEditCtrl.text;
    if (context.mounted) {
      context.read<AuthBloc>().add(
        Login(creds: Credentials(host: host, user: user, pass: pass))
      );
    }
  }

  String? Function(String?) nonEmptyValidator(AppLocalizations translate) {
    return (String? input) {
      if (input == null) return translate.validation_error_field_empty;
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final hostField = TextFormField(
      controller: _hostEditCtrl,
      decoration: InputDecoration(
        icon: Icon(Icons.web),
        labelText: translate.hostname_label,
      ),
      validator: nonEmptyValidator(translate),
      onFieldSubmitted: (_) => _submit(context),
    );
    final userField = TextFormField(
      controller: _userEditCtrl,
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: translate.username_label,
      ),
      validator: nonEmptyValidator(translate),
      onFieldSubmitted: (_) => _submit(context),
    );
    final passField = TextFormField(
      controller: _passEditCtrl,
      decoration: InputDecoration(
        icon: Icon(Icons.password),
        labelText: translate.password_label,
      ),
      obscureText: true,
      validator: nonEmptyValidator(translate),
      onFieldSubmitted: (_) => _submit(context),
    );

    return BlocProvider(
      create:
          (context) => LoginFormBloc(
            authRepo: context.read<AuthRepository>(),
            prefRepo: context.read<PrefRepo>(),
          )..add(SubscribeSettings()),
      child: BlocListener<LoginFormBloc, LoginFormBlocState>(
        listener: (context, state) {
          if (_hostEditCtrl.text.isEmpty) _hostEditCtrl.text = state.host;
          if (_userEditCtrl.text.isEmpty) _userEditCtrl.text = state.user;
          if (_passEditCtrl.text.isEmpty) _passEditCtrl.text = state.pass;
        },
        child: Form(
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
        ),
      ),
    );
  }
}
