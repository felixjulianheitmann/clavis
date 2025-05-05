import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class _GameErrCode extends ClavisErrCode {
  @override
  String localize(AppLocalizations translate) => translate.error_game_api;
}

sealed class GameEvent {}

final class GameSubscribe extends GameEvent {
  GameSubscribe({required this.api});
  final ApiClient api;
}

final class GameReload extends GameEvent {
  GameReload({required this.api, required this.id});
  final ApiClient api;
  final num id;
}

sealed class GameState {}

class GameLoading extends GameState {}

class GameReady extends GameState {
  GameReady(this.game);
  final GamevaultGame game;
}

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository _gameRepo;
  final ErrorRepository _errorRepo;
  final num id;

  GameBloc({
    required GameRepository gameRepo,
    required errorRepo,
    required this.id,
  }) : _gameRepo = gameRepo,
       _errorRepo = errorRepo,
      super(GameLoading()) {
    on<GameSubscribe>((event, emit) async {
      await emit.onEach(
        _gameRepo.gameStream(id),
        onData: (game) {
          emit(GameReady(game));
        },
        onError: (e, _) {
          if (e is ClavisException) {
            _errorRepo.setError(ClavisError(_GameErrCode(), e));
          }
        },
      );
    });
    on<GameReload>((e, _) async => await _gameRepo.getGame(e.api, id));
  }
}
