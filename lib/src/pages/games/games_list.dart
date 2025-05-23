import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/src/pages/games/game_card.dart';

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
  Widget build(BuildContext context) {
    widget.games.sortBy((e) => e.sortTitle ?? '___');
    final children =
        widget.games
            .map((game) => GameCard(game: game, width: _gameCardWidth))
            .toList();

    return BlocListener<PrefBloc, PrefState>(
      listener: (context, state) {
        final w = state.prefs.gameCardWidth;
        if (w != null) setState(() => _gameCardWidth = w);
      },
      child: Expanded(
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
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
                        (w) async =>
                            context.read<PrefRepo>().setGameCardWidth(w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
