import 'dart:async';

import 'package:clavis/src/types.dart';
import 'package:collection/collection.dart';
import 'package:gamevault_client_sdk/api.dart';

class GameRepoException extends ClavisException {
  GameRepoException(super.msg, {super.innerException, super.stack})
    : super(prefix: "GameRepoException");
}

class GameRepository {
  GameRepository()
    : _gamesListCtrl = StreamController<GamevaultGames>.broadcast() {
    Future(() async {
      await for (final g in _gamesListCtrl.stream.handleError((_) {
        /* errors are caught by the bloc */
      }, test: (error) => error is ClavisException)) {
        _games = g;
      }
    });
  }

  GamevaultGames? _games;

  final StreamController<GamevaultGames> _gamesListCtrl;

  Stream<GamevaultGames> get gameListStream async* {
    if (_games != null) {
      yield _games!;
    }
    yield* _gamesListCtrl.stream;
  }

  Stream<GamevaultGame> gameStream(num gameId) async* {
    final initial = game(gameId);
    if (initial != null) yield initial;
    await for (final gameList in _gamesListCtrl.stream.handleError((_) {
      /* errors are caught by the bloc */
    }, test: (error) => error is ClavisException)) {
      final game = gameList.firstWhereOrNull((g) => g.id == gameId);
      if (game != null) yield game;
    }
  }

  GamevaultGames? get games => _games;
  GamevaultGame? game(num gameId) {
    return _games?.firstWhereOrNull((g) => g.id == gameId);
  }

  Future<void> getGames(ApiClient api) async {
    final GetGames200Response? games;
    try {
      games = await GameApi(api).getGames();
    } catch (e, s) {
      _gamesListCtrl.addError(
        GameRepoException(
          "error querying games list",
          innerException: e,
          stack: s,
        ),
      );
      return;
    }
    if (games == null) {
      _gamesListCtrl.addError(
        GameRepoException(
          "games list query returned null",
          stack: StackTrace.current,
        ),
      );
      return;
    }
    _gamesListCtrl.add(games.data);
  }

  Future<void> getGame(ApiClient api, num id) async {
    final GamevaultGame? game;
    try {
      game = await GameApi(api).getGameByGameId(id);
    } catch (e, s) {
      _gamesListCtrl.addError(
        GameRepoException(
          "error querying game - id: $id",
          innerException: e,
          stack: s,
        ),
      );
      return;
    }
    if (game == null) {
      _gamesListCtrl.addError(
        GameRepoException(
          "game query returned null - id: $id",
          stack: StackTrace.current,
        ),
      );
      return;
    }

    final games = _games;
    if (games == null) {
      // game list not yet loaded
      _gamesListCtrl.add([game]);
      return;
    }

    final idx = games.indexWhere((g) => g.id == game!.id);
    if (idx <= 0) {
      // game not yet in gamelist?
      _gamesListCtrl.add(games + [game]);
      return;
    }

    games[idx] = game;
    _gamesListCtrl.add(games);
  }
}
