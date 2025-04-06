import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/widgets/app_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/constants.dart';
import 'package:gamevault_client_sdk/api.dart';

void _setPage(BuildContext context, PageInfo page) {
  final pageChanger = context.read<PageBloc>();
  pageChanger.add(PageChangedEvent(page));
  Navigator.pop(context);
}

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

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
                        () => showLicensePage(
                          context: context,
                          applicationIcon: Image.asset(
                            'assets/Key-Logo_Diagonal.png',
                          ),
                          applicationName: translate.app_title,
                          applicationLegalese: "Felix Bruns",
                        ),
                    icon: Icon(Icons.info),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.gamepad),
            title: Text(translate.games_title),
            onTap: () => _setPage(context, Constants.gamesPageInfo()),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(translate.users_title),
            onTap: () => _setPage(context, Constants.usersPageInfo()),
          ),
          Spacer(),
          Divider(),
          _UserMeTile(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(translate.settings_title),
            onTap: () => _setPage(context, Constants.settingsPageInfo()),
          ),
        ],
      ),
    );
  }
}

class _UserMeTile extends StatelessWidget {
  const _UserMeTile();

  String _userTitle(GamevaultUser user) {
    if (user.firstName == null && user.lastName == null) {
      return user.username;
    } else if (user.firstName != null) {
      return user.firstName!;
    } else if (user.lastName != null) {
      return user.lastName!;
    } else {
      return "${user.firstName} ${user.lastName}";
    }
  }

  Widget _userIcon(GamevaultUser user) {
    if (user.avatar?.sourceUrl != null) {
      return CircleAvatar(child: Image.network(user.avatar!.sourceUrl!));
    }
    return Icon(Icons.person);
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          return ListTile(
            leading: _userIcon(state.me),
            title: Text(_userTitle(state.me)),
            onTap: () => _setPage(context, Constants.userMePageInfo()),
          );
        }

        return ListTile(
          leading: Icon(Icons.login),
          title: Text(translate.action_login),
        );
      },
    );
  }
}
