import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class _GamesErrCode extends ClavisErrCode {
  @override
  String localize(AppLocalizations translate) => translate.error_game_api;
}

class GamesListState {
  const GamesListState({this.games});
  final List<GamevaultGame>? games;
}

sealed class GamesListEvent {}

final class Subscribe extends GamesListEvent {}

final class Reload extends GamesListEvent {
  Reload({required this.api});
  final ApiClient api;
}

class GamesListBloc extends Bloc<GamesListEvent, GamesListState> {
  final GameRepository _gameRepo;
  final ErrorRepository _errorRepo;

  GamesListBloc({
    required GameRepository gameRepo,
    required ErrorRepository errorRepo,
  }) : _gameRepo = gameRepo,
       _errorRepo = errorRepo,
       super(GamesListState()) {
    on<Subscribe>(_onSubscribe);
    on<Reload>((event, _) async => await _gameRepo.getGames(event.api));
  }

  Future<void> _onSubscribe(
    Subscribe state,
    Emitter<GamesListState> emit,
  ) async {
    await emit.onEach(
      _gameRepo.gameListStream,
      onData: (games) {
        emit(GamesListState(games: games));
      },
      onError: (e, _) {
        if (e is ClavisException) {
          _errorRepo.setError(ClavisError(_GamesErrCode(), e));
        }
      },
    );
  }
}
