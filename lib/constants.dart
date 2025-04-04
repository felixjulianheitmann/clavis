import 'package:clavis/widgets/games/games_search.dart';
import 'package:clavis/widgets/games/page.dart';
import 'package:clavis/widgets/util/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageInfo {
  const PageInfo({
    required this.id,
    this.appbarActions = const [],
    this.providers = const [],
  });
  final String id;
  final List<Widget> appbarActions;
  final List<Bloc> providers;
}

abstract class Constants {
  static PageInfo gamesPageInfo() => PageInfo(
    id: "games",
    appbarActions: [GamesSearch()],
    providers: [SearchBloc()],
  );

  static PageInfo usersPageInfo() => PageInfo(id: "users");
  static PageInfo userMePageInfo() => PageInfo(id: "userMe");
  static PageInfo settingsPageInfo() =>
      PageInfo(id: "settings", appbarActions: [LogoutAction()]);
}