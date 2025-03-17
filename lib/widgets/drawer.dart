import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gamevault_web/widgets/games/page.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamesPage()),
              );
            },
          ),
          ListTile(title: Text(translate.users_title), onTap: () {}),
          ListTile(title: Text(translate.settings_title), onTap: () {}),
        ],
      ),
    );
  }
}
