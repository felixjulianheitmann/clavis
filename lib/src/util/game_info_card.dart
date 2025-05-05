import 'package:clavis/src/blocs/game_bloc.dart';
import 'package:clavis/src/pages/games/game_page.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:clavis/src/util/focusable.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class GameInfoCard extends StatelessWidget {
  const GameInfoCard({
    super.key,
    required this.gameId,
    required this.height,
    required this.child,
    this.overlay,
  });
  final num gameId;
  final Widget? overlay;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);
    if (api == null) return CircularProgressIndicator();

    return BlocProvider(
      create:
          (ctx) =>
              GameBloc(
                  gameRepo: ctx.read<GameRepository>(),
                  errorRepo: ctx.read<ErrorRepository>(),
                  id: gameId,
                )
                ..add(GameSubscribe(api: api))
                ..add(GameReload(api: api, id: gameId)),
      child: SizedBox(
        height: height,
        child: Card(
          margin: EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          child: _CardContent(
            overlay: overlay,
            coverHeight: height * 0.56,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.overlay,
    required this.coverHeight,
    required this.child,
  });
  final Widget? overlay;
  final Widget child;
  final double coverHeight;

  void _openGame(BuildContext context, GamevaultGame game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is! GameReady) return CircularProgressIndicator();
        final game = state.game;

        return Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundBanner(game: game),
            overlay ?? SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Focusable(
                    onTap: () => _openGame(context, game),
                    builder: (context, focus) {
                      return focus(
                        Wrap(
                          children: [
                            Card.outlined(
                              clipBehavior: Clip.hardEdge,
                              child: Helpers.cover(game, coverHeight),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  child,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundBanner extends StatelessWidget {
  const _BackgroundBanner({required this.game});

  final GamevaultGame game;

  static const _bannerOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = game.metadata?.background?.sourceUrl;
    Widget background;
    if (backgroundUrl != null) {
      background = CacheImage(imageUrl: backgroundUrl, fit: BoxFit.cover);
    } else {
      background = SizedBox.shrink();
    }

    return Opacity(opacity: _bannerOpacity, child: background);
  }
}
