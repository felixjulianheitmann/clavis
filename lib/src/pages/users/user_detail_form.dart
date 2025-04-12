import 'dart:math';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_validator/email_validator.dart';
import 'package:gamevault_client_sdk/api.dart';

enum UserFormType { addNew, editExisting }

class UserForm extends StatefulWidget {
  const UserForm({super.key, required this.type});

  final UserFormType type;

  @override
  State<UserForm> createState() => _UserFormState();
}

String? Function(String?) _forbidEmpty(AppLocalizations translate) {
  return (String? text) {
    if (text == null || text.isEmpty) {
      return translate.validation_error_field_empty;
    }
    return null;
  };
}

String? Function(String?) _validateMail(AppLocalizations translate) {
  return (String? text) {
    final emptyErr = _forbidEmpty(translate)(text);
    if (emptyErr != null) return emptyErr;

    if (!EmailValidator.validate(text!)) {
      return translate.validation_invalid_mail;
    }
    return null;
  };
}

class _UserFormState extends State<UserForm> {
  Edited _userSubmit(String input, BuildContext context, ApiClient api) {
    context.read<PrefBloc>().add(SetUsername(username: input));
    return Edited(api: api, username: input);
  }
  
  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final api = Helpers.getApi(context);
    if (api == null) return Center(child: CircularProgressIndicator());
    
    String? remoteUsername;
    String? remoteFirstName;
    String? remoteLastName;
    String? remoteEmail;
    if (widget.type == UserFormType.editExisting) {
      // this is an edit user dialog -> update widget with remote values
      final user = context.select((UserBloc u) {
        if (u.state is Ready) return (u.state as Ready).user.user;
      });
      if (user != null) {
        remoteUsername = user.username;
        remoteFirstName = user.firstName;
        remoteLastName = user.lastName;
        remoteEmail = user.email;
      }
    }

    final usernameField = TextEdit(
      label: translate.page_user_details_username,
      remoteValue: remoteUsername,
      type: widget.type,
      submitter: (v) => _userSubmit(v, context, api),
      valueGetter: (user) => user.username,
      validator: _forbidEmpty(translate),
    );

    final firstnameField = TextEdit(
      label: translate.page_user_details_firstname,
      remoteValue: remoteFirstName,
      type: widget.type,
      submitter: (v) => Edited(api: api, firstName: v),
      valueGetter: (user) => user.firstName,
      validator: _forbidEmpty(translate),
    );

    final lastnameField = TextEdit(
      label: translate.page_user_details_lastname,
      remoteValue: remoteLastName,
      type: widget.type,
      submitter: (v) => Edited(api: api, lastName: v),
      valueGetter: (user) => user.lastName,
      validator: _forbidEmpty(translate),
    );

    final emailField = TextEdit(
      label: translate.page_user_details_email,
      remoteValue: remoteEmail,
      type: widget.type,
      submitter: (v) => Edited(api: api, email: v),
      valueGetter: (user) => user.email,
      validator: _validateMail(translate),
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
    required this.remoteValue,
    required this.type,
    required this.submitter,
    required this.valueGetter,
    this.validator,
  });

  final String label;
  final String? remoteValue;
  final UserFormType type;
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

    void Function(String)? onChanged;
    if (widget.remoteValue != null) {
      if (_ctrl.text == '' && !_isModified) {
        _ctrl.text = widget.remoteValue ?? '';
      }
      onChanged =
          (v) => setState(
            () => _isModified = widget.remoteValue != _ctrl.text,
          );
    }
    
    void Function(String)? onFieldSubmitted;
    if (widget.type == UserFormType.editExisting) {
      onFieldSubmitted = (v) {
        if (_formKey.currentState!.validate()) {
          final userUpdate = widget.submitter(v);
          context.read<UserBloc>().add(userUpdate);
        }
      };
    }

    final form = Form(
      key: _formKey,
      child: TextFormField(
        validator: widget.validator,
        controller: _ctrl,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: _isModified ? Icon(Icons.pending) : null,
        ),
      ),
    );

    if (widget.type == UserFormType.editExisting) {
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
        child: form,
      );
    } else {
      return form;
    }
  }

}
