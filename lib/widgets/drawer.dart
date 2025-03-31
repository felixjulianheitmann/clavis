import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/widgets/about_page.dart';
import 'package:clavis/widgets/app_title.dart';
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
      child: Column(
        // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppTitle(),
                  IconButton(
                    onPressed:
                    () => showLicensePage(context: context, applicationIcon: Image.asset('assets/Key-Logo_Diagonal.png'))
                        // () => Navigator.push(
                        //   context,

                        //   MaterialPageRoute(
                        //     builder: (ctx) => const AboutPage(),
                        //   ),
                        // ),
                    icon: Icon(Icons.info),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.gamepad),
            title: Text(translate.games_title),
            onTap: () => setPage(context, Constants.gamesPageKey),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(translate.users_title),
            onTap: () => setPage(context, Constants.usersPageKey),
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(translate.settings_title),
            onTap: () => setPage(context, Constants.settingsPageKey),
          ),
        ],
      ),
    );
  }
}
