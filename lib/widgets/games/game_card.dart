import 'package:clavis/util/focusable.dart';
import 'package:clavis/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/game_page.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, this.width = defaultWidth});

  final GamevaultGame game;
  final double width;
  static const defaultWidth = 150.0;
  static const aspectRatio = 1.3;
  static const minWidth = 50.0;
  static const maxWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GamePage(game: game)),
        );
      },
      child: Focusable(
        child: SizedBox(
          height: aspectRatio * width,
          width: width,
          child: Card(
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            child: Helpers.cover(game, width),
          ),
        ),
      ),
    );
  }
}
