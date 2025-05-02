import 'package:clavis/src/blocs/error_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:clavis/src/pages/downloads/active_dl_snackbar.dart';
import 'package:clavis/src/pages/downloads/downloads_page.dart';
import 'package:clavis/src/pages/users/user_me_page.dart';
import 'package:clavis/src/util/app_title.dart';
import 'package:clavis/src/pages/games/games_page.dart';
import 'package:clavis/src/pages/settings/settings_page.dart';
import 'package:clavis/src/pages/users/users_page.dart';
import 'package:clavis/src/util/error_snackbar.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:clavis/src/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClavisScaffold extends StatefulWidget {
  const ClavisScaffold({
    super.key,
    this.body,
    this.actions,
    this.title,
    this.showDrawer = true,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final bool showDrawer;
  final Widget? body;
  final List<Widget>? actions;
  final String? title;

  @override
  State<ClavisScaffold> createState() => _ClavisScaffoldState();
}

class _ClavisScaffoldState extends State<ClavisScaffold> {
  Widget _getBody(PageInfo activePage, bool isReady) {
    if (!isReady) return Center(child: CircularProgressIndicator());

    if (activePage.id == Constants.usersPageInfo().id) {
      return UsersPage();
    } else if (activePage.id == Constants.settingsPageInfo().id) {
      return SettingsPage();
    } else if (activePage.id == Constants.userMePageInfo().id) {
      return UserMePage();
    } else if (activePage.id == Constants.downloadsPageInfo().id) {
      return DownloadsPage();
    } else {
      return GamesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);
    final apiLoaded = api != null;

    final userMeLoaded = context.select((UserMeBloc u) => u.state is Ready);
    if (!userMeLoaded && apiLoaded) {
      context.read<UserMeBloc>().add(UserReload(api: api));
    }

    bool isReady = userMeLoaded && apiLoaded;

    return BlocListener<ErrorBloc, ErrorState>(
      listener: (context, state) {
        if (!state.hasError) return;
        ScaffoldMessenger.of(context).showSnackBar(errorSnack(state.error!));
      },
      child: BlocListener<PageBloc, PageState>(
        listener: (context, state) {
          if (state.dlSnack.visibility == DlSnackVisibility.visible) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(activeDlSnackbar(context));
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
        },
        child: BlocBuilder<PageBloc, PageState>(
          builder: (context, state) {
            final scaffold = Scaffold(
              appBar:
                  widget.showAppBar
                      ? ClavisAppbar(
                        title: widget.title,
                        actions:
                            widget.actions ?? state.activePage.appbarActions,
                      )
                      : null,
              drawer: widget.showDrawer ? SidebarDrawer() : null,
              body: widget.body ?? _getBody(state.activePage, isReady),
            );

            if (state.activePage.blocs.isEmpty) {
              return scaffold;
            }

            final providers =
                state.activePage.blocs
                    .map((bloc) => BlocProvider(create: bloc))
                    .toList();
            return MultiBlocProvider(providers: providers, child: scaffold);
          },
        ),
      ),
    );
  }
}

class ClavisAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ClavisAppbar({super.key, required this.actions, this.title});

  final List<Widget> actions;
  final String? title;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = AppTitle();
    if (title != null) titleWidget = Text(title!);

    return AppBar(title: titleWidget, actions: actions);
  }
}
