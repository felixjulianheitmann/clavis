import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_page.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/game_info_card.dart';
import 'package:clavis/src/util/user_tile.dart';
import 'package:clavis/src/util/value_pair_column.dart';
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
              UserMeBloc(context.read<UserRepository>())..add(Subscribe()),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [_UserMeInfo(), Divider(), _RecentlyPlayed()]),
      ),
    );
  }
}

class _RecentlyPlayed extends StatelessWidget {
  const _RecentlyPlayed();

  static const _cardHeight = 150.0;

  List<Widget> _progressCards(List<Progress> progresses) {
    return progresses
        .map((p) {
          if (p.game == null) return null;
          return GameInfoCard(
            gameId: p.game!.id,
            height: _cardHeight,
            child: ValuePairColumn(
              labels: ["min played"],
              icons: [Icons.hourglass_bottom_outlined],
              values: ["${p.minutesPlayed}"],
              height: 25,
            ),
          );
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
          children: [
            UserTile(user: state.user),
          ],
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
