import 'dart:math';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/users_bloc.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/form_validators.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final api = Helpers.getApi(context);
    final screenSize = MediaQuery.of(context).size;
    final formWidth = min(screenSize.width * 0.9, 400.0);

    Widget body;
    if (api == null) {
      body = Center(child: CircularProgressIndicator());
    } else {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SizedBox(width: formWidth, child: AddUserForm())],
        ),
      );
    }

    return BlocProvider(
      create:
          (ctx) => UsersBloc(ctx.read<UserRepository>())..add(UsersSubscribe()),
      child: ClavisScaffold(
        title: translate.action_add_user,
        showDrawer: false,
        actions: [],
        body: body,
      ),
    );
  }
}

class AddUserForm extends StatefulWidget {
  const AddUserForm({super.key});

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final api = Helpers.getApi(context);
    if (api == null) return Center(child: CircularProgressIndicator());

    final usernameField = TextFormField(
      controller: _usernameCtrl,
      decoration: InputDecoration(label: Text(translate.username_label)),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );
    final passwordField = TextFormField(
      controller: _passwordCtrl,
      obscureText: true,
      decoration: InputDecoration(label: Text(translate.password_label)),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: FormValidators.nonNullEmpty(translate),
    );
    final passwordConfirmField = TextFormField(
      controller: _passwordConfirmCtrl,
      obscureText: true,
      decoration: InputDecoration(
        label: Text(translate.password_confirm_label),
      ),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: (v) => _passwordCheck(translate, v, _passwordCtrl.text),
    );
    final firstNameField = TextFormField(
      controller: _firstNameCtrl,
      decoration: InputDecoration(
        label: Text(translate.page_user_details_firstname),
      ),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );
    final lastNameField = TextFormField(
      controller: _lastNameCtrl,
      decoration: InputDecoration(
        label: Text(translate.page_user_details_lastname),
      ),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );
    final emailField = TextFormField(
      controller: _emailCtrl,
      decoration: InputDecoration(
        label: Text(translate.page_user_details_email),
      ),
      onFieldSubmitted: (_) => _onSubmit(context, api),
      validator: FormValidators.nonNullEmptyMail(translate),
    );

    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersAdded) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          Widget buttonContent = Text(translate.action_register);
          if (state is UsersAdding) {
            buttonContent = CircularProgressIndicator();
          }
          return Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              children: [
                usernameField,
                passwordField,
                passwordConfirmField,
                firstNameField,
                lastNameField,
                emailField,
                FilledButton(
                  onPressed: () => _onSubmit(context, api),
                  child: buttonContent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSubmit(BuildContext context, ApiClient api) {
    if (!_formKey.currentState!.validate()) return;

    final registration = RegisterUserDto(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
    );

    context.read<UsersBloc>().add(Add(api: api, registration: registration));
  }
}

String? _passwordCheck(
  AppLocalizations translate,
  String? confirmation,
  String password,
) {
  final isEmpty = FormValidators.nonNullEmpty(translate)(confirmation);
  if (isEmpty != null) return isEmpty;

  if (confirmation != null && password == confirmation) return null;
  if (password.length < 8) return translate.validation_password_too_short;
  return translate.validation_password_confirm_different;
}
