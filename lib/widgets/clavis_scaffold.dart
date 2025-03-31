import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:clavis/widgets/drawer.dart';

class ClavisScaffold extends StatelessWidget {
  const ClavisScaffold({
    super.key,
    required this.body,
    this.showDrawer = true,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final bool showDrawer;
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
        actions: [],
      );
    }
    return Scaffold(
      appBar: appBar,
      drawer: showDrawer ? SidebarDrawer() : null,
      body: body,
    );
  }
}
