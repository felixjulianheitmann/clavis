import 'package:clavis/src/blocs/search_bloc.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/games_list_bloc.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clavis/src/pages/games/games_list.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (ctx) {
        return GamesListBloc(gameRepo: ctx.read<GameRepository>())
          ..add(Subscribe());
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(child: CircularProgressIndicator());
          }
          final api = state.api;

          return BlocBuilder<GamesListBloc, GamesListState>(
            builder: (context, state) {
              if (state.games == null) {
                final gamesListBloc = context.read<GamesListBloc>();
                Future(() => gamesListBloc.add(Reload(api: api)));
                return Center(child: CircularProgressIndicator());
              }
              return GamesPanel(games: state.games!);
            },
          );
        },
      ),
    );
  }
}

class GamesPanel extends StatelessWidget {
  const GamesPanel({super.key, required this.games});

  final GamevaultGames games;

  @override
  Widget build(BuildContext context) {
    var filtered = context.select((SearchBloc s) => s.filter(games));

    return Column(
      children: [
        _LetterScroller(
          onPressed:
              (c) => context.read<SearchBloc>().add(LetterChanged(letter: c)),
        ),
        GamesList(games: filtered),
      ],
    );
  }
}

class _LetterScroller extends StatefulWidget {
  const _LetterScroller({required this.onPressed});
  final void Function(int? c) onPressed;

  static const letterSize = 48.0;

  @override
  State<_LetterScroller> createState() => __LetterScrollerState();
}

class __LetterScrollerState extends State<_LetterScroller> {
  static const _letters = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  List<bool> _toggleStates = List<bool>.filled(_letters.length, false);

  void _onPressed(int idx) {
    // update toggle buttons - only keep one active
    final active = !_toggleStates[idx];
    setState(() {
      _toggleStates = List<bool>.filled(_letters.length, false);
      _toggleStates[idx] = !active;
    });

    if (active) {
      // letters are all untoggled
      widget.onPressed(null);
    } else {
      // search for specific letter
      widget.onPressed(_letters.runes.elementAt(idx));
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
