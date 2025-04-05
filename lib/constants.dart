import 'package:clavis/blocs/search_bloc.dart';
import 'package:clavis/widgets/games/games_search.dart';
import 'package:clavis/widgets/util/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageInfo {
  const PageInfo({
    required this.id,
    this.appbarActions = const [],
    this.blocs = const [],
  });
  final String id;
  final List<Widget> appbarActions;
  final List<Bloc> blocs;
}

abstract class Constants {
  static PageInfo gamesPageInfo() => PageInfo(
    id: "games",
    appbarActions: [GamesSearch()],
    blocs: [SearchBloc()],
  );

  static PageInfo usersPageInfo() => PageInfo(id: "users");
  static PageInfo userMePageInfo() => PageInfo(id: "userMe");
  static PageInfo settingsPageInfo() =>
      PageInfo(id: "settings", appbarActions: [LogoutAction()]);
}