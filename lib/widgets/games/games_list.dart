import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:gamevault_web/widgets/games/game_card.dart';

class GamesList extends StatelessWidget {
  const GamesList({super.key, required this.games});

  static const spacing = 12.0;
  final GetGames200Response games;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final children =
            games.data.map((game) => GameCard(game: game)).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Wrap(spacing: spacing, children: children),
        );
      },
    );
  }
}
