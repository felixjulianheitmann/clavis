import 'package:clavis/src/blocs/game_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:clavis/src/pages/games/game_page.dart';
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
    required this.child,
    required this.height,
    this.overlay,
  });
  final num gameId;
  final Widget child;
  final Widget? overlay;
  final double height;

  void _openGame(BuildContext context, GamevaultGame game) {
    context.read<PageBloc>().add(PageChanged(Constants.gamesPageInfo()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);
    if (api == null) return CircularProgressIndicator();

    return BlocProvider(
      create:
          (ctx) =>
              GameBloc(gameRepo: ctx.read<GameRepository>(), id: gameId)
                ..add(GameSubscribe(api: api)),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is! GameReady) return CircularProgressIndicator();
          final game = state.game;
          return SizedBox(
            height: height,
            child: Card(
              margin: EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _BackgroundBanner(game: game),
                  overlay ?? SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => _openGame(context, game),
                          child: Focusable(
                            child: Wrap(
                              children: [
                                Card.outlined(
                                  clipBehavior: Clip.hardEdge,
                                  child: Helpers.cover(game, height * 0.56),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
