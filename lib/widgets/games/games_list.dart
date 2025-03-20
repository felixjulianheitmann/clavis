import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/openapi.dart';
import 'package:gamevault_web/widgets/games/game_card.dart';

class GamesList extends StatelessWidget {
  const GamesList({super.key, required this.games});

  static const spacing = 12.0;
  final List<(GameMetadata, GamevaultGame)> games;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return GridView.extent(
          maxCrossAxisExtent: GameCard.width,
          childAspectRatio: GameCard.aspect,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          children:
              games.map((game) {
                return GameCard(metadata: game.$1, game: game.$2);
              }).toList(),
        );
      },
    );
  }
}
