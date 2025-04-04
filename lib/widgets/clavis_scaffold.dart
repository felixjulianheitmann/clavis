import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/constants.dart';
import 'package:clavis/widgets/app_title.dart';
import 'package:clavis/widgets/games/page.dart';
import 'package:clavis/widgets/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:clavis/widgets/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClavisScaffold extends StatelessWidget {
  const ClavisScaffold({
    super.key,
    this.body,
    this.actions,
    this.showDrawer = true,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final bool showDrawer;
  final Widget? body;
  final List<Widget>? actions;

  Widget _getBody(PageInfo activePage) {
    if (activePage.id == Constants.usersPageInfo().id) {
      return GamesPage(); // TODO: make it user page
    } else if (activePage.id == Constants.settingsPageInfo().id) {
      return SettingsPage();
    } else {
      return GamesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageBloc, PageState>(
      builder: (context, state) {
        return Scaffold(
          appBar:
              showAppBar
                  ? ClavisAppbar(
                    actions: actions ?? state.activePage.appbarActions,
                  )
                  : null,
          drawer: showDrawer ? SidebarDrawer() : null,
          body: body ?? _getBody(state.activePage),
        );
      },
    );
  }
}

class ClavisAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ClavisAppbar({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: AppTitle(), actions: actions
    );
  }
}
