import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/blocs/page_bloc.dart';
import 'package:clavis/constants.dart';
import 'package:clavis/widgets/app_title.dart';
import 'package:clavis/widgets/games/page.dart';
import 'package:clavis/widgets/settings/settings_page.dart';
import 'package:clavis/src/pages/login/login_page.dart';
import 'package:clavis/widgets/users/root_page.dart';
import 'package:flutter/material.dart';
import 'package:clavis/widgets/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClavisScaffold extends StatelessWidget {
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

  Widget _getBody(PageInfo activePage) {
    if (activePage.id == Constants.usersPageInfo().id) {
      return UsersPage();
    } else if (activePage.id == Constants.settingsPageInfo().id) {
      return SettingsPage();
    } else if (activePage.id == Constants.userMePageInfo().id) {
      return UsersPage();
    } else {
      return GamesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorState = context.select((ErrorBloc e) => e.state);
    if (errorState.hasError) {
      return ErrorWidget(errorState.error!);
    }

    final authState = context.select((AuthBloc a) => a.state);
    if (authState is! AuthSuccessState) {
      if (authState is AuthFailedState) {
        return LoginPage(errorMessage: authState.message);
      }
      return LoginPage();
    }

    return BlocBuilder<PageBloc, PageState>(
      builder: (context, state) {
        final scaffold = Scaffold(
          appBar:
              showAppBar
                  ? ClavisAppbar(
                    title: title,
                    actions: actions ?? state.activePage.appbarActions,
                  )
                  : null,
          drawer: showDrawer ? SidebarDrawer() : null,
          body: body ?? _getBody(state.activePage),
        );
        if (state.activePage.blocs.isEmpty) {
          return scaffold;
        }

        final providers =
            state.activePage.blocs
                .map((bloc) => BlocProvider(create: (_) => bloc))
                .toList();
        return MultiBlocProvider(providers: providers, child: scaffold);
      },
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
