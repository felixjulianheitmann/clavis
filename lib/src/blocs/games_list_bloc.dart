import 'package:clavis/src/repositories/games_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

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
  
  GamesListBloc(
    {required GameRepository gameRepo }
  ) : 
  _gameRepo = gameRepo,
  super(GamesListState()) {
    on<Subscribe>(_onSubscribe);
    on<Reload>((event, _) => _gameRepo.getGames(event.api));
  }

  Future<void> _onSubscribe(Subscribe state, Emitter<GamesListState> emit) async {
    await emit.onEach(
      _gameRepo.gameListStream,
      onData: (games) {
      emit(GamesListState(games: games));
    },);

  }



}