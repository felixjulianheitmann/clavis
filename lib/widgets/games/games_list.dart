import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:gamevault_web/widgets/games/game_card.dart';
import 'package:gamevault_web/widgets/query_builder.dart';

class GamesList extends StatelessWidget {
  const GamesList({super.key, required this.games});

  static const spacing = 12.0;
  final List<(GameMetadata, GamevaultGame)> games;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Querybuilder(
          query: (api) => GameApi(api).getGames(),
          builder: (ctx, games) {
            return GridView.extent(
              padding: EdgeInsets.all(8),
              maxCrossAxisExtent: GameCard.width,
              childAspectRatio: GameCard.aspect,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              children:
                  (games as GetGames200Response).data.map((game) {
                    return GameCard(game: game);
                  }).toList(),
            );
          },
        );
      },
    );
  }
}
