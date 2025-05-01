import 'package:clavis/src/repositories/games_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

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
  final num id;

  GameBloc({required GameRepository gameRepo, required this.id})
    : _gameRepo = gameRepo,
      super(GameLoading()) {
    on<GameSubscribe>((event, emit) async {
      await emit.onEach(
        _gameRepo.gameStream(id),
        onData: (game) {
          emit(GameReady(game));
        },
      );
    });
    on<GameReload>((e, _) => _gameRepo.getGame(e.api, id));
  }
}
