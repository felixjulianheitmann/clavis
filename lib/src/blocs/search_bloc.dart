import 'package:clavis/src/types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameFilterState {
  GameFilterState({required this.open, this.letter, this.content = ''});
  final bool open;
  final String content;
  final int? letter;

  GameFilterState copyWith({bool? open, String? content, int? letter = -1}) {
    return GameFilterState(
      open: open ?? this.open,
      content: content ?? this.content,
      letter: letter != -1 ? letter : this.letter,
    );
  }
}

class GameFilterEvent {}

class Opened extends GameFilterEvent {}

class Closed extends GameFilterEvent {}

class TextChanged extends GameFilterEvent {
  TextChanged({required this.text});
  String text;
}

class LetterChanged extends GameFilterEvent {
  LetterChanged({this.letter});
  int? letter;
}

class SearchBloc extends Bloc<GameFilterEvent, GameFilterState> {
  SearchBloc() : super(GameFilterState(open: false)) {
    on<Opened>((event, emit) => emit(state.copyWith(open: true)));
    on<Closed>((event, emit) => emit(state.copyWith(open: false, content: '')));
    on<TextChanged>((event, emit) => emit(state.copyWith(content: event.text)));
    on<LetterChanged>(
      (event, emit) => emit(state.copyWith(letter: event.letter)),
    );
  }

  bool _matches(String pattern, String? target) {
    return target != null &&
        target.contains(RegExp(pattern, caseSensitive: true));
  }

  GamevaultGames filter(GamevaultGames games) {
    bool searchBarInvalid = !state.open || state.content.isEmpty;
    bool letterFilterInactive = state.letter == null;
    if (searchBarInvalid && letterFilterInactive) return games;

    // filter by searchbar
    final searchFiltered =
        games.where((game) => _matches(state.content, game.title)).toList();
    if (state.letter == null) return searchFiltered;

    // also filter by starting letter
    var letterSet = String.fromCharCode(state.letter!);
    if (state.letter == '#'.codeUnits.first) {
      // search for all digits
      letterSet = '0123456789';
    }
    return searchFiltered.where((g) {
      return letterSet.runes.any((letterCode) {
        return g.title != null &&
            g.title!.startsWith(
              RegExp(String.fromCharCode(letterCode), caseSensitive: false),
            );
      });
    }).toList();
  }
}
