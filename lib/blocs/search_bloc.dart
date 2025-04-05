import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class SearchState {
  SearchState({required this.open, this.content = ''});
  final bool open;
  final String content;

  SearchState copy({bool? open, String? content}) {
    return SearchState(
      open: open ?? this.open,
      content: content ?? this.content,
    );
  }
}

class SearchWithGamesState extends SearchState {
  SearchWithGamesState({
    required this.games,
    super.content,
    super.open = false,
  });
  final List<GamevaultGame> games;

  @override
  SearchWithGamesState copy({
    bool? open,
    String? content,
    List<GamevaultGame>? games,
  }) {
    return SearchWithGamesState(
      open: open ?? this.open,
      content: content ?? this.content,
      games: games ?? this.games,
    );
  }

  bool _matches(String pattern, String? target) {
    return target != null &&
        target.contains(RegExp(pattern, caseSensitive: true));
  }

  List<GamevaultGame> getFiltered() {
    if (content.isEmpty) {
      return games;
    }

    return games.where((game) => _matches(content, game.title)).toList();
  }
}

class SearchEvent {}

class SearchGamesAvailableEvent extends SearchEvent {
  SearchGamesAvailableEvent({required this.games});
  final List<GamevaultGame> games;
}

class SearchOpenedEvent extends SearchEvent {}

class SearchClosedEvent extends SearchEvent {}

class SearchChangedEvent extends SearchEvent {
  SearchChangedEvent({required this.text});
  String text;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState(open: false)) {
    on<SearchGamesAvailableEvent>((event, emit) {
      emit(
        SearchWithGamesState(
          open: state.open,
          content: state.content,
          games: event.games,
        ),
      );
    });
    on<SearchOpenedEvent>((event, emit) => emit(state.copy(open: true)));
    on<SearchClosedEvent>((event, emit) => emit(state.copy(open: false)));
    on<SearchChangedEvent>(
      (event, emit) => emit(state.copy(content: event.text)),
    );
  }

  static List<GamevaultGame> search(String input, List<GamevaultGame> games) {
    return games
        .where(
          (game) => game.title != null && game.title!.contains("(?i)$input"),
        )
        .toList();
  }
}
