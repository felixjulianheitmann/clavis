import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/util/helpers.dart';
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
          Spacer(),
          Divider(),
          Text(translate.drawer_admin_area),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final visible =
                  state is AuthSuccessState &&
                  state.me.role == GamevaultUserRoleEnum.n3;
              // admin access
              return Visibility(
                visible: visible,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(translate.users_title),
                  onTap: () => _setPage(context, Constants.usersPageInfo()),
                ),
              );
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          return ListTile(
            leading: SizedBox.square(
              dimension: 24,
              child: Helpers.avatar(state.me),
            ),
            title: Text(Helpers.userTitle(state.me)),
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
