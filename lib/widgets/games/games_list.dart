import 'package:clavis/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/game_card.dart';

class GamesList extends StatefulWidget {
  const GamesList({super.key, required this.games});

  static const spacing = 12.0;
  final List<GamevaultGame> games;

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  double _gameCardWidth = GameCard.defaultWidth;

  @override
  void initState() {
    super.initState();
    Preferences.getGameCardWidth().then((w) {
      if (w != null) {
        setState(() => _gameCardWidth = w);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.games.sort((a, b) {
      if (a.title == null) {
        return 1;
      } else if (b.title == null) {
        return -1;
      } else {
        return a.title!.compareTo(b.title!);
      }
    });
    final children =
        widget.games
            .map((game) => GameCard(game: game, width: _gameCardWidth))
            .toList();

    return Expanded(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: GamesList.spacing,
                children: children,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: SizedBox(
                height: 32,
                width: 320,
                child: Slider(
                  value: _gameCardWidth,
                  max: GameCard.maxWidth,
                  min: GameCard.minWidth,
                  onChanged: (w) async {
                    setState(() => _gameCardWidth = w);
                  },
                  onChangeEnd:
                      (w) async => await Preferences.setGameCardWidth(w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
