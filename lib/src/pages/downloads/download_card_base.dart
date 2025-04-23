import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:clavis/src/pages/games/game_page.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:clavis/src/util/focusable.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class DownloadCardBase extends StatelessWidget {
  const DownloadCardBase({
    super.key,
    required this.operation,
    required this.children,
    this.overlay,
    this.height,
  });
  final DownloadOp operation;
  final List<Widget> children;
  final Widget? overlay;
  final double? height;

  void _openGame(BuildContext context) {
    context.read<PageBloc>().add(PageChanged(Constants.gamesPageInfo()));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(game: operation.game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        margin: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BackgroundBanner(game: operation.game),
            overlay ?? SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children:
                    <Widget>[
                      GestureDetector(
                        onTap: () => _openGame(context),
                        child: Focusable(
                          child: Wrap(
                            children: [
                              Card.outlined(
                                clipBehavior: Clip.hardEdge,
                                child: Helpers.cover(operation.game, 120),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] +
                    children,
              ),
            ),
          ],
        ),
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
