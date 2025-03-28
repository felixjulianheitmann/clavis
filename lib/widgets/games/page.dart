import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/games_list.dart';
import 'package:clavis/widgets/query_builder.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Querybuilder(
        query: (api) => GameApi(api).getGames(),
        builder: (ctx, games) {
          return GamesList(games: games);
      },
    );
  }
}
