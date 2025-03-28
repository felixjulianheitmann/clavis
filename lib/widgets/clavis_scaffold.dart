import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gamevault_web/widgets/drawer.dart';

class ClavisScaffold extends StatelessWidget {
    const ClavisScaffold({super.key, required this.body, this.showAppBar = true});

    final bool showAppBar;
    final Widget body;

    @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (showAppBar) {
      appBar = AppBar(
        title: Text(
          AppLocalizations.of(context)!.app_title,
          style: TextStyle(fontFamily: 'Jersey10'),
        ),
      );
    }
    return Scaffold(
              appBar: appBar,
              drawer: SidebarDrawer(),
              body: body,
            );
  }
}