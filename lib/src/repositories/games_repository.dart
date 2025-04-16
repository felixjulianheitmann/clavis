import 'dart:async';

import 'package:clavis/src/types.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:gamevault_client_sdk/api.dart';

class GameRepository {
  GameRepository()
    : _gamesListCtrl = StreamController<GamevaultGames>.broadcast(),
      _activeGameCtrl = StreamController<GamevaultGame>.broadcast() {
    Future(() async {
      await for (final g in _activeGameCtrl.stream) {
        _activeGame = g;
      }
    }).onError((error, stackTrace) {
      log.e("active game setter errored out", error: error, stackTrace: stackTrace);
    },);
        Future(() async {
      await for (final g in _gamesListCtrl.stream) {
        _games = g;
      }
    }).onError((error, stackTrace) {
      log.e("game list setter errored out", error: error, stackTrace: stackTrace);
    },);
  }

  GamevaultGames? _games;
  GamevaultGame? _activeGame;

  final StreamController<GamevaultGames> _gamesListCtrl;
  final StreamController<GamevaultGame> _activeGameCtrl;

  Stream<GamevaultGames> get gameListStream async* {
    if (_games != null) {
      yield _games!;
    }
    yield* _gamesListCtrl.stream;
  }

  Stream<GamevaultGame> get activeGameStream async* {
    if (_activeGame != null) {
      yield _activeGame!;
    }
    yield* _activeGameCtrl.stream;
  }

  GamevaultGames? get games => _games;
  GamevaultGame? get activeGame => _activeGame;

  Future<void> getGames(ApiClient api) async {
    final GetGames200Response? games;
    try {
      games = await GameApi(api).getGames();
      if (games == null) {
        return log.e("games list query returned null");
      }
    } catch (e) {
      return log.e("error querying games list", error: e);
    }

    _gamesListCtrl.add(games.data);
  }

  Future<void> getGame(ApiClient api, num id) async {
    final GamevaultGame? game;
    try {
      game = await GameApi(api).getGameByGameId(id);
      if (game == null) {
        return log.e("game query returned null - id: $id");
      }
    } catch (e) {
      return log.e("error querying game - id: $id", error: e);
    }

    _activeGameCtrl.add(game);
  }

}
