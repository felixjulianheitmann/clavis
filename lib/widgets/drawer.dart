import 'package:clavis/blocs/page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:clavis/constants.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  void setPage(BuildContext context, String page) {
    final pageChanger = context.read<PageBloc>();
    pageChanger.add(PageChangedEvent(page));
  }

  @override
  Widget build(BuildContext context) {
    var translate = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(translate.app_title),
          ),
          ListTile(
            title: Text(translate.games_title),
            onTap: () => setPage(context, Constants.gamesPageKey),
          ),
          ListTile(
            title: Text(translate.users_title),
            onTap: () => setPage(context, Constants.usersPageKey),
          ),
          ListTile(
            title: Text(translate.settings_title),
            onTap: () => setPage(context, Constants.settingsPageKey),
          ),
        ],
      ),
    );
  }
}
