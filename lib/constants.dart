import 'package:clavis/widgets/util/logout_button.dart';
import 'package:flutter/material.dart';

class PageInfo {
  const PageInfo({required this.id, this.appbarActions = const []});
  final String id;
  final List<Widget> appbarActions;
}

abstract class Constants {
  static PageInfo gamesPageInfo() => PageInfo(
    id: "games",
    appbarActions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
  );

  static PageInfo usersPageInfo() => PageInfo(id: "users");
  static PageInfo userMePageInfo() => PageInfo(id: "userMe");
  static PageInfo settingsPageInfo() =>
      PageInfo(id: "settings", appbarActions: [LogoutAction()]);
}