import 'package:clavis/src/blocs/games_list_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/games/game_card.dart';
import 'package:clavis/src/pages/games/game_progress_card.dart';
import 'package:clavis/src/pages/users/user_detail_page.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/headline_divider.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/user_tile.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UserMePage extends StatelessWidget {
  const UserMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserMeBloc(context.read<UserRepository>())..add(UserSubscribe()),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserMeInfo(),
            HeadlineDivider(text: "Bookmarks"),
            _Bookmarks(),
            HeadlineDivider(text: "Recently played"),
            _RecentlyPlayed(),
          ],
        ),
      ),
    );
  }
}

class _Bookmarks extends StatelessWidget {
  const _Bookmarks();

  @override
  Widget build(BuildContext context) {
    final me = Helpers.getMe(context);
    final api = Helpers.getApi(context);
    if (me == null || api == null) return CircularProgressIndicator();
    final bookmarks = me.user.bookmarkedGames.take(10).toList();
    bookmarks.sortBy((e) => e.sortTitle ?? "___");
    return BlocProvider(
      create:
          (context) =>
              GamesListBloc(gameRepo: context.read<GameRepository>())
                ..add(Subscribe())
                ..add(Reload(api: api)),
      child: Wrap(
        children:
            bookmarks.map((g) {
              return BlocBuilder<GamesListBloc, GamesListState>(
                builder: (context, state) {
                  if (state.games == null) return GameCard(game: g);

                  final game = state.games!.firstWhereOrNull(
                    (game) => game.id == g.id,
                  );
                  return GameCard(game: game ?? g);
                },
              );
            }).toList(),
      ),
    );
  }
}

class _RecentlyPlayed extends StatelessWidget {
  const _RecentlyPlayed();

  List<Widget> _progressCards(List<Progress> progresses) {
    return progresses
        .map((p) {
          if (p.game == null) return null;
          return GameProgressCard.decorated(gameId: p.game!.id);
        })
        .nonNulls
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserMeBloc, UserState>(
      builder: (context, state) {
        if (state is! Ready) return CircularProgressIndicator();

        final progressCards = _progressCards(state.user.user.progresses);
        return Column(children: progressCards);
      },
    );
  }
}

class _UserMeInfo extends StatelessWidget {
  const _UserMeInfo();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserMeBloc, UserState>(
      builder: (context, state) {
        if (state is! Ready) return CircularProgressIndicator();
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [Expanded(child: UserTile(user: state.user))],
        );
      },
    );
  }
}

class UserEditAction extends StatelessWidget {
  const UserEditAction({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(id: null)),
      );
    }

    return IconButton(onPressed: onPressed, icon: Icon(Icons.edit));
  }
}
