import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/blocs/users_bloc.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/pages/users/user_detail_form.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final api = Helpers.getApi(context);

    Widget body;
    if (api == null) {
      body = Center(child: CircularProgressIndicator());
    } else {
      body = Center(
        child: Column(
          children: [
            UserForm(
              type: UserFormType.addNew,
              actionButtonBuilder: (context, validateForm, user) {
                return FilledButton(
                  style: ButtonStyle(),
                  onPressed: () {
                    if(!validateForm()) return;
                    context.read<UserBloc>().add(Add(api: api, user: user))
                  },
                  child: Text(translate.action_register),
                );
              },
            ),
          ],
        ),
      );
    }
    return ClavisScaffold(
      title: translate.action_add_user,
      showDrawer: false,
      actions: [],
      body: body,
    );
  }
}
