
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/login_form_bloc.dart';
import 'package:clavis/src/pages/login/form_fields.dart';
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

  final LoginFormz _state = LoginFormz();

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final host = _hostEditCtrl.text;
    final user = _userEditCtrl.text;
    final pass = _passEditCtrl.text;
    if (context.mounted) {
      context.read<LoginFormBloc>().add(Submit(host:host, user:user, pass:pass,));
    }
  }

  String? _validateHost(String? input) {
    if(input == null) return 
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final hostField = Builder(
      builder: (context) {
        final host = 
        return TextFormField(
          controller: _hostEditCtrl,
          decoration: InputDecoration(icon: Icon(Icons.web), labelText: translate.hostname_label),
          validator: (value) => _state.host.validator(value ?? '')?.name,
          onFieldSubmitted: (_) => _submit(context),
        );
      }
    );
    final userField = TextFormField(
      controller: _userEditCtrl,
      decoration: InputDecoration(icon: Icon(Icons.person), labelText: translate.username_label),
      validator: (value) => _state.user.validator(value ?? '')?.name,
      onFieldSubmitted: (_) => _submit(context),
    );
    final passField = TextFormField(
      controller: _passEditCtrl,
      decoration: InputDecoration(icon: Icon(Icons.password), labelText: translate.password_label),
      obscureText: true,
      validator: (value) => _state.pass.validator(value ?? '')?.name,
      onFieldSubmitted: (_) => _submit(context),
    );

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
}
}
