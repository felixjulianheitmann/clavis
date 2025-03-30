import 'package:clavis/blocs/page_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:clavis/constants.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:clavis/widgets/games/page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppPageSwitcher extends StatelessWidget {
  const AppPageSwitcher({super.key});

  Widget _body(activePage) {
    switch (activePage) {
      case Constants.usersPageKey:
        return GamesPage(); // TODO: make it user page
      case Constants.settingsPageKey:
        return GamesPage(); // TODO: make it settings page
      case Constants.gamesPageKey:
      default:
        return GamesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageBloc, PageState>(
      builder: (context, state) {
        return ClavisScaffold(
          body: _body(state.activePage),
        );
      },
    );
  }
}
