import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/pages/users/add_user_page.dart';
import 'package:flutter/material.dart';

class AddUserAction extends StatelessWidget {
  const AddUserAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context)!.action_add_user,
      child: IconButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddUserPage()),
            ),
        icon: Icon(Icons.add),
      ),
    );
  }
}
