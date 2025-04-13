import 'dart:math';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/util/form_validators.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gamevault_client_sdk/api.dart';


typedef ValidateFunc = bool Function();
typedef ActionButtonBuilderFunc =
    Widget Function(BuildContext context, ValidateFunc validateForm, GamevaultUser user);

class UserForm extends StatefulWidget {
  const UserForm({super.key, this.id});
  final num? id;

  @override
  State<UserForm> createState() => _UserFormState();
}


class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

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

    final user;
    if (widget.id == null) {
      user = context.select((UserMeBloc u) {
      if (u.state is Ready) return (u.state as Ready).user.user;
    });
    } else {
      user = context.select((UserBloc u) {
        if (u.state is Ready) return (u.state as Ready).user.user;
      });
    }

    if (user != null) {
      remoteUsername = user.username;
      remoteFirstName = user.firstName;
      remoteLastName = user.lastName;
      remoteEmail = user.email;
    }

    final usernameField = TextEdit(
      formKey: _formKey,
      userId: widget.id,
      controller: _usernameCtrl,
      label: translate.page_user_details_username,
      remoteValue: remoteUsername,
      submitter: (v) => _userSubmit(v, context, api),
      valueGetter: (user) => user.username,
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );

    final firstnameField = TextEdit(
      formKey: _formKey,
      userId: widget.id,
      controller: _firstNameCtrl,
      label: translate.page_user_details_firstname,
      remoteValue: remoteFirstName,
      submitter: (v) => Edited(api: api, firstName: v),
      valueGetter: (user) => user.firstName,
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );

    final lastnameField = TextEdit(
      formKey: _formKey,
      userId: widget.id,
      controller: _lastNameCtrl,
      label: translate.page_user_details_lastname,
      remoteValue: remoteLastName,
      submitter: (v) => Edited(api: api, lastName: v),
      valueGetter: (user) => user.lastName,
      validator: FormValidators.nonNullEmptyAlphabet(translate),
    );

    final emailField = TextEdit(
      formKey: _formKey,
      userId: widget.id,
      controller: _emailCtrl,
      label: translate.page_user_details_email,
      remoteValue: remoteEmail,
      submitter: (v) => Edited(api: api, email: v),
      valueGetter: (user) => user.email,
      validator: FormValidators.nonNullEmptyMail(translate),
    );

    return SizedBox(
      width: min(MediaQuery.of(context).size.width, 400),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
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
      ),
    );
  }
}

class TextEdit extends StatefulWidget {
  const TextEdit({
    super.key,
    required this.userId,
    required this.formKey,
    required this.controller,
    required this.label,
    required this.remoteValue,
    required this.submitter,
    required this.valueGetter,
    this.validator,
  });

  final GlobalKey<FormState> formKey;
  final num? userId;
  final TextEditingController controller;
  final String label;
  final String? remoteValue;
  final Edited Function(String) submitter;
  final String? Function(GamevaultUser) valueGetter;
  final String? Function(String? text)? validator;

  @override
  State<TextEdit> createState() => _TextEditState();
}

class _TextEditState extends State<TextEdit> {
  bool _isModified = false;

  @override
  Widget build(BuildContext context) {

    void Function(String)? onChanged;
    if (widget.remoteValue != null) {
      if (widget.controller.text == '' && !_isModified) {
        widget.controller.text = widget.remoteValue ?? '';
      }
      onChanged =
          (v) => setState(
            () => _isModified = widget.remoteValue != widget.controller.text,
          );
    }
    
    final field = TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      onChanged: onChanged,
      onFieldSubmitted: (v) {
        if (widget.formKey.currentState!.validate()) {
          final userUpdate = widget.submitter(v);
          Helpers.getUserSpecificBloc(context, widget.userId).add(userUpdate);
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: _isModified ? Icon(Icons.pending) : null,
      ),
    );


    return UserSpecificBlocListener(
      id: widget.userId,
      listener: (context, state) {
        if (state is Ready) {
          // check on state updates
          setState(() {
            final remote = widget.valueGetter(state.user.user);
            _isModified = remote != null && remote != widget.controller.text;
          });
        }
      },
      child: field,
    );
  }
}
