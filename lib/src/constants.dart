import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/blocs/search_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/games/games_search.dart';
import 'package:clavis/src/pages/users/user_me_page.dart';
import 'package:clavis/src/pages/users/add_user_action.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/logout_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class Constants {
  static PageInfo gamesPageInfo() {
    return PageInfo(
      id: PageId.games,
      appbarActions: [GamesSearch()],
      blocs: [(_) => SearchBloc()],
    );
  }

  static PageInfo usersPageInfo() {
    return PageInfo(id: PageId.users, appbarActions: [AddUserAction()]);
  }

  static PageInfo userMePageInfo() {
    return PageInfo(
      id: PageId.userMe,
      appbarActions: [UserEditAction()],
      blocs: [
        (ctx) => UserMeBloc(ctx.read<UserRepository>())..add(Subscribe()),
      ],
    );
  }

  static PageInfo settingsPageInfo() {
    return PageInfo(id: PageId.settings, appbarActions: [LogoutAction()]);
  }

  static PageInfo downloadsPageInfo() {
    return PageInfo(id: PageId.downloads);
  }
}
