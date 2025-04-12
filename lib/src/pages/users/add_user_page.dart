import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/pages/users/user_detail_form.dart';
import 'package:flutter/material.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return ClavisScaffold(
      title: translate.action_add_user,
      showDrawer: false,
      actions: [],
      body: Center(
        child: Column(
          children: [
            UserForm(type: UserFormType.addNew),
            FilledButton(
              style: ButtonStyle(),
              onPressed: () {
                
              },
              child: Text(translate.action_register),
            ),
          ],
        ),
      ),
    );
  }
}
