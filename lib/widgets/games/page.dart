import 'package:clavis/blocs/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/games_list.dart';
import 'package:clavis/widgets/query_builder.dart';


class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Querybuilder(
        query: (api) => GameApi(api).getGames(),
      builder: (ctx, gameResponse) {
        final games = (gameResponse as GetGames200Response).data;
        ctx.read<SearchBloc>().add(SearchGamesAvailableEvent(games: games));
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchWithGamesState) {
              return GamesList(games: state.getFiltered());
            }
            return GamesList(games: games);
          },
        );
      },
    );
  }
}
