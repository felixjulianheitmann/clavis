import 'package:clavis/blocs/search_bloc.dart';
import 'package:clavis/widgets/games/games_search.dart';
import 'package:clavis/widgets/util/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PageId { games, users, userMe, settings }

class PageInfo {
  const PageInfo({
    required this.id,
    this.appbarActions = const [],
    this.blocs = const [],
  });
  final PageId id;
  final List<Widget> appbarActions;
  final List<Bloc> blocs;
}

abstract class Constants {
  static PageInfo gamesPageInfo() => PageInfo(
    id: PageId.games,
    appbarActions: [GamesSearch()],
    blocs: [SearchBloc()],
  );

  static PageInfo usersPageInfo() => PageInfo(id: PageId.users);
  static PageInfo userMePageInfo() => PageInfo(id: PageId.userMe);
  static PageInfo settingsPageInfo() =>
      PageInfo(id: PageId.settings, appbarActions: [LogoutAction()]);
}
