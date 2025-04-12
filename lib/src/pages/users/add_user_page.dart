import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:flutter/material.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClavisScaffold(
      title: AppLocalizations.of(context)!.action_add_user,
      showDrawer: false,
      actions: [],
      body: const Placeholder(),
    );
  }
}
