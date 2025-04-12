import 'dart:math';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_validator/email_validator.dart';
import 'package:gamevault_client_sdk/api.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key, required this.user});

  final GamevaultUser user;

  @override
  State<UserForm> createState() => _UserFormState();
}

String? Function(String?) _forbidEmpty(String emptyMessage) {
  return (String? text) {
    if (text == null || text.isEmpty) {
      return emptyMessage;
    }
    return null;
  };
}

String? _validateMail(String? text, invalidMailMessage) {
  // empty field is allowed
  if (text == null || text.isEmpty) return null;

  if (!EmailValidator.validate(text)) {
    return invalidMailMessage;
  }
  return null;
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    final usernameField = TextEdit(
      label: translate.page_user_details_username,
      submitter: (v) => Edited(username: v),
      valueGetter: (user) => widget.user.username,
      validator: _forbidEmpty(translate.validation_error_field_empty),
    );

    final firstnameField = TextEdit(
      label: translate.page_user_details_firstname,
      submitter: (v) => Edited(firstName: v),
      valueGetter: (user) => widget.user.firstName,
    );

    final lastnameField = TextEdit(
      label: translate.page_user_details_lastname,
      submitter: (v) => Edited(lastName: v),
      valueGetter: (user) => widget.user.lastName,
    );

    final emailField = TextEdit(
      label: translate.page_user_details_email,
      submitter: (v) => Edited(email: v),
      valueGetter: (user) => widget.user.email,
      validator: (v) => _validateMail(v, translate.validation_invalid_mail),
    );

    return SizedBox(
      width: min(MediaQuery.of(context).size.width, 400),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              usernameField,
              firstnameField,
              lastnameField,
              emailField,
            ],
          ),
        ),
      ),
    );
  }
}

class TextEdit extends StatefulWidget {
  const TextEdit({
    super.key,
    required this.label,
    required this.submitter,
    required this.valueGetter,
    this.validator,
  });

  final String label;
  final Edited Function(String) submitter;
  final String? Function(GamevaultUser) valueGetter;
  final String? Function(String? text)? validator;

  @override
  State<TextEdit> createState() => _TextEditState();
}

class _TextEditState extends State<TextEdit> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isModified = false;

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserBloc u) {
      if (u is Ready) return (u.state as Ready).user.user;
    });

    void Function(String)? onChanged;
    if (user != null) {
      onChanged =
          (v) => setState(
            () => _isModified = widget.valueGetter(user) != _ctrl.text,
          );
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is Ready) {
          // check on state updates
          setState(() {
            final remote = widget.valueGetter(state.user.user);
            _isModified = remote != null && remote != _ctrl.text;
          });
        }
      },
      child: Form(
        key: _formKey,
        child: TextFormField(
          validator: widget.validator,
          controller: _ctrl,
          onChanged: onChanged,
          onFieldSubmitted: (v) {
            if (_formKey.currentState!.validate()) {
              final userUpdate = widget.submitter(v);
              context.read<UserBloc>().add(userUpdate);
            }
          },
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: _isModified ? Icon(Icons.pending) : null,
          ),
        ),
      ),
    );
  }
}
