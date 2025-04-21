import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';

class DownloadCardBase extends StatelessWidget {
  const DownloadCardBase({
    super.key,
    required this.operation,
    required this.children,
    this.overlay,
  });
  final DownloadOp operation;
  final List<Widget> children;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _BackgroundBanner(game: operation.game),
          overlay ?? SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [Helpers.cover(operation.game, 50)] + children,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundBanner extends StatelessWidget {
  const _BackgroundBanner({required this.game});

  final GamevaultGame game;

  static const _bannerOpacity = 0.6;

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = game.metadata?.background?.sourceUrl;
    Widget background;
    if (backgroundUrl != null) {
      background = CacheImage(imageUrl: backgroundUrl);
    } else {
      background = SizedBox.shrink();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: Opacity(opacity: _bannerOpacity, child: background),
    );
  }
}
