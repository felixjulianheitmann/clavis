import 'package:clavis/blocs/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/games_list.dart';
import 'package:clavis/widgets/query_builder.dart';


class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<int>? _activeLetterFilter;

  List<GamevaultGame> _filterForLetter(
    List<GamevaultGame> games,
    List<int>? letterCodes,
  ) {
    if (letterCodes == null) {
      return games;
    }

    return games.where((g) {
      return letterCodes.any((letterCode) {
        return g.title != null &&
            g.title!.startsWith(
              RegExp(String.fromCharCode(letterCode), caseSensitive: false),
            );
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Querybuilder(
        query: (api) => GameApi(api).getGames(),
      builder: (ctx, gameResponse, error) {
        if (error != null) {
          return Center(child: Card(child: Text(error.toString())));
        }

        final games = gameResponse!.data;
        ctx.read<SearchBloc>().add(SearchGamesAvailableEvent(games: games));

        return Column(
          children: [
            _LetterScroller(
              onPressed: (c) => setState(() => _activeLetterFilter = c),
            ),
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is! SearchWithGamesState) {
                  return GamesList(games: games);
                }

                var filteredGames = state.getFiltered();
                filteredGames = _filterForLetter(
                  filteredGames,
                  _activeLetterFilter,
                );

                return GamesList(games: filteredGames);
              },
            ),
          ],
        );
      },
    );
  }
}

class _LetterScroller extends StatefulWidget {
  const _LetterScroller({required this.onPressed});
  final void Function(List<int>? c) onPressed;

  static const letterSize = 48.0;

  @override
  State<_LetterScroller> createState() => __LetterScrollerState();
}

class __LetterScrollerState extends State<_LetterScroller> {
  static const _letters = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  List<bool> _toggleStates = List<bool>.filled(_letters.length, false);

  void _onPressed(int idx) {
    // update toggle buttons - only keep one active
    final prev = _toggleStates[idx];
    setState(() {
      _toggleStates = List<bool>.filled(_letters.length, false);
      _toggleStates[idx] = !prev;
    });

    if (prev) {
      // letters are all untoggled
      widget.onPressed(null);
    } else if (idx == 0) {
      // '#' numbers
      widget.onPressed('0123456789'.runes.toList());
    } else {
      // search for specific letter
      widget.onPressed([_letters.runes.elementAt(idx)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> letterToggles =
        _letters.runes.map((c) => Text(String.fromCharCode(c))).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ToggleButtons(
        isSelected: _toggleStates,
        constraints: BoxConstraints.tight(
          Size.square(_LetterScroller.letterSize),
        ),
        onPressed: _onPressed,
        children: letterToggles,
      ),
    );
  }
}
