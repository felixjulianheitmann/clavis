import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/games_list.dart';
import 'package:clavis/widgets/query_builder.dart';

class SearchState {
  SearchState({required this.open, this.content = ''});
  bool open;
  String content;
}

class SearchEvent {}

class SearchOpenedEvent extends SearchEvent {}

class SearchClosedEvent extends SearchEvent {}

class SearchChangedEvent extends SearchEvent {
  SearchChangedEvent({required this.text});
  String text;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState(open: false)) {
    on<SearchOpenedEvent>((event, emit) => emit(SearchState(open: true)));
    on<SearchClosedEvent>((event, emit) => emit(SearchState(open: false)));
    on<SearchChangedEvent>(
      (event, emit) => emit(SearchState(open: true, content: event.text)),
    );
  }
}

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Querybuilder(
        query: (api) => GameApi(api).getGames(),
      builder: (ctx, games) {
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            var gameList = (games as GetGames200Response).data;
            if (state.content.isNotEmpty) {
              gameList.where(
                (g) =>
                    g.title != null &&
                    g.title!.toLowerCase().startsWith(
                      state.content.toLowerCase(),
                    ),
              );
            }
            return GamesList(games: gameList);
          },
        );
      },
    );
  }
}
